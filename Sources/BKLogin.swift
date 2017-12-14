//
//  BKLogin.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 9/30/17.
//

import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)
    import UIKit
#endif

public class BKLogin {
    //    private  var _cookie: Cookie?
    public var cookie: BKCookie? {
        get {
            return  UserDefaults.standard.object(forKey: cacheKey) as? BKCookie
        }
        set {
            //            _cookie = newValue
            UserDefaults.standard.set(newValue, forKey: cacheKey)
        }
    }

    private var cacheKey: String { return "\(BKCookie.filename)-\(identifier)" }

    public let identifier: String
    public static let `default` = BKLogin(identifier: "DEFAULT")
    public init(identifier: String, cookie: BKCookie? = nil) {
        self.identifier = identifier
        self.cookie = cookie
    }
    
    public func logout() {
        timer = nil
        cookie = nil
    }
    
    public func login(withCookie cookie: BKCookie) {
        self.cookie = cookie
    }

    public func interruptLogin() {
        timer = nil
    }
    
    private var timer: Timer? {
        willSet {
            timer?.invalidate()
        }
    }

    private func everySecond(execute: @escaping () -> Void) {
        if #available(iOS 10.0, macOS 10.12, tvOS 10.0, watchOS 3.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in execute() }
            timer?.fire()
        } else {
            timer = Timer() // dummy timer
            func loop() {
                DispatchQueue.global(qos: .userInteractive)
                    .asyncAfter(deadline: DispatchTime.now() + 1)
                    { [weak self] in if self?.timer != nil { loop() } }
            }
            loop()
        }
    }

    public func login(handleLoginInfo: @escaping (LoginURL) -> Void, handleLoginState: @escaping (LoginState) -> Void) {
        fetchLoginURL { [weak self] result in
            switch result {
            case .success(let url):
                handleLoginInfo(url)
                func process() {
                    func heartbeat() {
                        DispatchQueue.global(qos: .userInitiated)
                            .asyncAfter(deadline: DispatchTime.now() + 3, execute: process)
                    }
                    self?.fetchLoginInfo(oauthKey: url.oauthKey) { result in
                        switch result {
                        case .success(let state):
                            switch state {
                            case .succeeded(cookie: let cookie):
                                self?.timer = nil
                                self?.login(withCookie: cookie)
                            case .expired:
                                self?.timer = nil
                            default:
                                heartbeat()
                            }
                            handleLoginState(state)
                        case .errored(response: let response, error: let error):
                            debugPrint("""
                                Response: \(response?.description ?? "No Response")
                                Error: \(error?.localizedDescription ?? "No Error")
                                """)
                            heartbeat()
                        }
                    }
                }
                self?.everySecond(execute: process)
            case .errored(response: let response, error: let error):
                fatalError("""
                    Response: \(response?.description ?? "No Response")
                    Error: \(error?.localizedDescription ?? "No Error")
                    """)
            }
        }
    }

    private enum FetchResult<E> {
        case success(result: E)
        case errored(response: URLResponse?, error: Swift.Error?)
    }

    private typealias FetchResultHandler<E> = (_ result: FetchResult<E>) -> Void

    // MARK: Login URL Fetching

    /// Only valid for 3 minutes
    public struct LoginURL: Codable {
        public let url: String
        public let oauthKey: String

        struct Wrapper: Codable {
            let data: LoginURL
        }

        /*
         func qrCode(inputCorrectionLevel: QRErrorCorrectLevel) -> UIImage? {
         let data = url.data(using: .utf8)
         guard let filter = CIFilter(name: "CIQRCodeGenerator")
         else { return nil }
         filter.setValue(data, forKey: "inputMessage")
         filter.setValue(inputCorrectionLevel.ciQRCodeGeneratorInputCorrectionLevel,
         forKey: "inputCorrectionLevel")
         guard let ciimage = filter.outputImage else { return nil }
         return UIImage(ciImage: ciimage)
         }
         */
    }

    private  func fetchLoginURL(handler: @escaping FetchResultHandler<LoginURL>) {
        let url = URL(string: "https://passport.bilibili.com/qrcode/getLoginUrl")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                let wrapper = try? JSONDecoder().decode(LoginURL.Wrapper.self, from: data)
                else { return handler(.errored(response: response, error: error)) }
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
        /// -4: not scaned.
        /// -5: not confirmed.
        /// -2: expired.
        /// -1: no auth key present.
        let data: Int
        /// Login process status explaination.
        let message: String
    }

    public enum LoginState {
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


    /// <#Description#>
    /// Needs to be constantly checked.
    ///
    /// - Parameters:
    ///   - oauthKey: <#oauthKey description#>
    ///   - handler: <#handler description#>
    private func fetchLoginInfo(oauthKey: String, handler: @escaping FetchResultHandler<LoginState>) {
        let url = URL(string: "https://passport.bilibili.com/qrcode/getLoginInfo")!
        var request = postRequest(to: url)
        /// Content-Type: application/x-www-form-urlencoded
        request.httpBody = "oauthKey=\(oauthKey)".data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse {
                if let headerFields = response.allHeaderFields as? [String: String],
                    let cookies = headerFields["Set-Cookie"] {
                    guard let cookie = BKCookie(headerField: cookies) else { fatalError("Logic Error") }
                    return handler(.success(result: .succeeded(cookie: cookie)))
                }
            } else if let data = data,
                let info = try? JSONDecoder().decode(LoginInfo.self, from: data) {
                return handler(.success(result: LoginState.of(info)))
            } else {
                return handler(.errored(response: response, error: error))
            }
        }
        task.resume()
    }


    private func postRequest(to url: URL, cookie: BKCookie? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("io.github.apollozhu.bilibilikit", forHTTPHeaderField: "User-Agent")
        if let cookieHeader = (cookie ?? self.cookie)?.asHeaderField {
            request.addValue(cookieHeader, forHTTPHeaderField: "Cookie")
        }
        return request
    }

}
