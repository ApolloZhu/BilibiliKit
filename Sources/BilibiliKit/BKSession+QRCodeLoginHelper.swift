//
//  BKSession+QRCodeLoginHelper.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 9/30/17.
//  Copyright (c) 2017-2020 ApolloZhu. MIT License.
//

import Foundation
import Dispatch

extension BKSession {
    public class QRCodeLoginHelper {
        /// Initialize a new login helper.
        public init() { }
        
        /// Schedule events to check current attempt's stage.
        private var timer: Timer? {
            willSet {
                timer?.invalidate()
            }
        }
    }
}

/// Manage login through QRCode
extension BKSession.QRCodeLoginHelper {
    /// Default login helper
    public static let `default` = BKSession.QRCodeLoginHelper()
    
    #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
    /// A dummpy helper that does nothing but indicating an internal state.
    private static let dummyTimer = Timer()
    #else
    /// A dummpy helper that does nothing but indicating an internal state.
    private static let dummyTimer = Timer(timeInterval: 0, repeats: false) { _ in }
    #endif
    
    /// If an attempt is active.
    fileprivate var isRunLoopActive: Bool { return timer != nil }
    
    /// Interrupt current attempt.
    public func interrupt() { timer = nil }
    
    /// Run code to execute every second.
    ///
    /// - Parameter execute: code to run.
    fileprivate func everySecond(execute: @escaping () -> Void) {
        if #available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
                _ in execute()
            }
            timer?.fire()
        } else {
            timer = BKSession.QRCodeLoginHelper.dummyTimer
            func loop() {
                DispatchQueue.global(qos: .userInteractive)
                    .asyncAfter(deadline: DispatchTime.now() + 1)
                    { [weak self] in if self?.isRunLoopActive == true { execute();loop() } }
            }
            loop()
        }
    }
}

extension BKSession {
    /// Start an attempt to login.
    ///
    /// - Parameters:
    ///   - handleLoginInfo: to display `LoginURL` to user.
    ///   - handleLoginState: to handle different stages in this process.
    public func login(withHelper helper: QRCodeLoginHelper = .default,
        handleLoginInfo: @escaping (QRCodeLoginHelper.LoginURL) -> Void,
        handleLoginState: @escaping (QRCodeLoginHelper.LoginState) -> Void)
    {
        helper.fetchLoginURL { [weak self] result in
            switch result {
            case .success(let url):
                handleLoginInfo(url)
                var process: () -> Void = { [weak self] in
                    guard helper.isRunLoopActive else { return }
                    helper.fetchLoginInfo(oauthKey: url.oauthKey)
                    { [weak self] result in
                        guard let self = self, helper.isRunLoopActive else { return }
                        switch result {
                        case .success(let state):
                            switch state {
                            case .succeeded(cookie: let cookie):
                                helper.interrupt()
                                self.cookie = cookie
                            case .expired:
                                helper.interrupt()
                            default:
                                heartbeat()
                            }
                            handleLoginState(state)
                        case .failure(let error):
                            debugPrint(error)
                            heartbeat()
                        }
                    }
                }
                func heartbeat() {
                    DispatchQueue.global(qos: .userInitiated)
                        .asyncAfter(deadline: DispatchTime.now() + 3,
                                    execute: process)
                }
                helper.everySecond(execute: process)
            case .failure(let error):
                debugPrint(error)
                handleLoginState(.errored)
            }
        }
    }
}

// MARK: Login URL Fetching
extension BKSession.QRCodeLoginHelper {
    /// Only valid for 3 minutes
    public struct LoginURL: Codable {
        /// This url directs user to the confirmation page.
        public let url: String
        /// This oauthKey keeps track of the current session.
        public let oauthKey: String
        
        struct Wrapper: Codable {
            let data: LoginURL
        }
    }
    
    fileprivate func fetchLoginURL(handler: @escaping BKHandler<LoginURL>) {
        let url: URL = "https://passport.bilibili.com/qrcode/getLoginUrl"
        let task = URLSession._bk.dataTask(with: url) { data, response, error in
            guard let data = data else {
                return handler(.failure(.responseError(
                    reason: .urlSessionError(error, response: response))))
            }
            handler(Result { try JSONDecoder().decode(LoginURL.Wrapper.self, from: data) }
                .mapError { BKError.parseError(reason: .jsonDecode(data, failure: $0)) }
                .map { $0.data })
        }
        task.resume()
    }
    
    // MARK: Login Info Fetching
    
    fileprivate struct LoginInfo: Codable {
        /// If has login info.
        /// Set-Cookie if true.
        let status: Bool
        /// Login process status.
        /// - See: LoginState.of(_:).
        let data: Int
        /// Login process status explaination.
        let message: String
    }
    
    public enum LoginState {
        case errored
        case started
        case needsConfirmation
        case succeeded(cookie: BKCookie)
        case expired
        case missingOAuthKey
        case unknown(status: Int)
        fileprivate static func of(_ info: LoginInfo) -> LoginState {
            switch info.data {
            case -1: return .missingOAuthKey
            case -2: return .expired
            case -4: return .started
            case -5: return .needsConfirmation
            default: return .unknown(status: info.data)
            }
        }
    }
    
    /// Fetchs the current stage during an attempt,
    /// needs to be regularly invoked during that process.
    ///
    /// - Parameters:
    ///   - session: session to login to, default to `.shared`.
    ///   - oauthKey: oauthKey indicating the current session.
    ///   - handler: code handling fetched login state.
    fileprivate func fetchLoginInfo(session: BKSession = .shared,
                                    oauthKey: String,
                                    handler: @escaping BKHandler<LoginState>) {
        let url: URL = "https://passport.bilibili.com/qrcode/getLoginInfo"
        var request = session.postRequest(to: url)
        /// Content-Type: application/x-www-form-urlencoded
        request.httpBody = "oauthKey=\(oauthKey)".data(using: .utf8)
        let task = URLSession._bk.dataTask(with: request)
        { [weak self] data, res, error in
            guard self?.isRunLoopActive == true else { return }
            if let response = res as? HTTPURLResponse,
                let headerFields = response.allHeaderFields as? [String: String],
                let cookies = headerFields["Set-Cookie"] {
                guard let cookie = BKCookie(headerField: cookies) else {
                    debugPrint("Inconsistent Login Cookie State")
                    return handler(.failure(.responseError(
                        reason: .urlSessionError(error, response: res))))
                }
                return handler(.success(.succeeded(cookie: cookie)))
            }
            guard let data = data else {
                return handler(.failure(.responseError(
                    reason: .urlSessionError(error, response: res))))
            }
            handler(Result { try JSONDecoder().decode(LoginInfo.self, from: data) }
                .mapError { .parseError(reason: .jsonDecode(data, failure: $0)) }
                .map { LoginState.of($0) })
        }
        task.resume()
    }
}
