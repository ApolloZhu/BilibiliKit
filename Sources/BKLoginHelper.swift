//
//  BKLoginHelper.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 9/30/17.
//

import Foundation
import Dispatch

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#endif

/// Manage login through QRCode
public class BKLoginHelper {
    /// Default login helper
    public static let `default` = BKLoginHelper()
    
    /// Initialize a new login helper.
    public init() { }
    
    #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
    /// A dummpy helper that does nothing but indicating an internal state.
    private static let dummyTimer = Timer()
    #else
    /// A dummpy helper that does nothing but indicating an internal state.
    private static let dummyTimer = Timer(timeInterval: 0, repeats: false) { _ in }
    #endif
    
    /// Schedule events to check current attempt's stage.
    private var timer: Timer? {
        willSet {
            timer?.invalidate()
        }
    }
    
    /// If an attempt is active.
    private var isRunLoopActive: Bool { return timer != nil }
    
    /// Interrupt current attempt.
    public func interrupt() { timer = nil }
    
    /// Run code to execute every second.
    ///
    /// - Parameter execute: code to run.
    private func everySecond(execute: @escaping () -> Void) {
        if #available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in execute() }
            timer?.fire()
        } else {
            timer = BKLoginHelper.dummyTimer
            func loop() {
                DispatchQueue.global(qos: .userInteractive)
                    .asyncAfter(deadline: DispatchTime.now() + 1)
                    { [weak self] in if self?.isRunLoopActive == true { execute();loop() } }
            }
            loop()
        }
    }
    
    /// Start an attempt to login.
    ///
    /// - Parameters:
    ///   - session: session to login into, default to `.shared`.
    ///   - handleLoginInfo: to display `LoginURL` to user.
    ///   - handleLoginState: to handle different stages in this process.
    public func login(session: BKSession = .shared,
                      handleLoginInfo: @escaping (LoginURL) -> Void,
                      handleLoginState: @escaping (LoginState) -> Void) {
        fetchLoginURL { [weak self] result in
            switch result {
            case .success(let url):
                handleLoginInfo(url)
                var process: () -> Void = { [weak self] in
                    guard let `self` = self, self.isRunLoopActive else { return }
                    self.fetchLoginInfo(oauthKey: url.oauthKey)
                    { [weak self] result in
                        guard let `self` = self, self.isRunLoopActive else { return }
                        switch result {
                        case .success(let state):
                            switch state {
                            case .succeeded(cookie: let cookie):
                                self.interrupt()
                                session.cookie = cookie
                            case .expired:
                                self.interrupt()
                            default:
                                heartbeat()
                            }
                            handleLoginState(state)
                        case .errored:
                            debugPrint(result)
                            heartbeat()
                        }
                    }
                }
                func heartbeat() {
                    DispatchQueue.global(qos: .userInitiated)
                        .asyncAfter(deadline: DispatchTime.now() + 3,
                                    execute: process)
                }
                self?.everySecond(execute: process)
            case .errored:
                debugPrint(result)
                handleLoginState(.errored)
            }
        }
    }
    
    private enum FetchResult<E>: CustomDebugStringConvertible {
        case success(result: E)
        case errored(data: Data?, response: URLResponse?, error: Swift.Error?)
        var debugDescription: String {
            switch self {
            case .success(result: let result): return "\(result)"
            case .errored(data: let data, response: let response, error: let error):
                var description = "Data: "
                if let data = data {
                    if let str = String(data: data, encoding: .utf8) {
                        description += str
                    } else {
                        description += "\(data)"
                    }
                } else {
                    description += "No Data"
                }
                description += "\nResponse: \(response?.description ?? "No Response")"
                description += "\nError: \(error?.localizedDescription ?? "No Error")"
                return description
            }
        }
    }
    
    private typealias FetchResultHandler<E> = (_ result: FetchResult<E>) -> Void
    
    // MARK: Login URL Fetching
    
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
    
    private func fetchLoginURL(handler: @escaping FetchResultHandler<LoginURL>) {
        let url: URL = "https://passport.bilibili.com/qrcode/getLoginUrl"
        let task = URLSession.bk.dataTask(with: url) { data, response, error in
            guard let body = data
                , let wrapper = try? JSONDecoder().decode(LoginURL.Wrapper.self, from: body)
                else { return handler(.errored(data: data,
                                               response: response,
                                               error: error)) }
            return handler(.success(result: wrapper.data))
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
    private func fetchLoginInfo(session: BKSession = .shared,
                                oauthKey: String,
                                handler: @escaping FetchResultHandler<LoginState>) {
        let url: URL = "https://passport.bilibili.com/qrcode/getLoginInfo"
        var request = session.postRequest(to: url)
        /// Content-Type: application/x-www-form-urlencoded
        request.httpBody = "oauthKey=\(oauthKey)".data(using: .utf8)
        let task = URLSession.bk.dataTask(with: request)
        { [weak self] data, response, error in
            guard self?.isRunLoopActive == true else { return }
            if let response = response as? HTTPURLResponse,
                let headerFields = response.allHeaderFields as? [String: String],
                let cookies = headerFields["Set-Cookie"] {
                guard let cookie = BKCookie(headerField: cookies) else {
                    debugPrint("Inconsistent Login Cookie State")
                    return handler(.errored(data: data, response: response, error: error))
                }
                return handler(.success(result: .succeeded(cookie: cookie)))
            }
            if let data = data, let info = try? JSONDecoder().decode(LoginInfo.self, from: data) {
                return handler(.success(result: LoginState.of(info)))
            } else {
                return handler(.errored(data: data, response: response, error: error))
            }
        }
        task.resume()
    }
}

