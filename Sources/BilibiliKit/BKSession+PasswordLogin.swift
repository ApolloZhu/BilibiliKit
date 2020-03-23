//
//  BKSession+PasswordLogin.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 4/14/19.
//  Copyright (c) 2017-2019 ApolloZhu. MIT License.
//

import Foundation
import BKSecurity

extension CharacterSet {
    /// https://stackoverflow.com/questions/41561853/couldnt-encode-plus-character-in-url-swift
    static let rfc3986Unreserved = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
}

private func encode(_ string: String) -> String {
    return string.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!
}

extension BKSession {
    private struct Wrapper: Decodable {
        let data: LoginInfo
        struct LoginInfo: Decodable {
            let token_info: TokenInfo
            struct TokenInfo: Decodable {
                let refresh_token: String
                let expires_in: Int
                let access_token: String
            }
            let cookie_info: CookieInfo
            struct CookieInfo: Decodable {
                let cookies: [Cookie]
                struct Cookie: Decodable {
                    let value: String
                    let name: String
                    let expires: Int
                }
            }
        }
    }
    /// Copyright (c) 2018 Ruoyang Xu.
    /// [MIT License](https://github.com/Hsury/Bilibili-Toolkit/blob/master/LICENSE).
    /// Copyright (c) 2017 Rsplwe.
    /// [MIT License](https://github.com.Rsplwe/BilibiliAccessKey/blob/master/LICENSE).
    public func login(_ username: String, password: String,
                      completionHandler handle: @escaping BKHandler<BKCookie>) {
        func get<T>(_ result: Result<T, BKError>) -> T? {
            switch result {
            case .success(let v):
                return v
            case .failure(let error):
                handle(.failure(error))
                return nil
            }
        }
        getPublicKey { [weak self] in
            guard let key = get($0),
                let pwd = get(BKSec.rsaEncrypt("\(key.hash)\(password)", with: key.key))
                else { return }
            let params = "actionKey=appkey&appkey=\(BKApp.appkey)&password=\(encode(pwd))&username=\(encode(username))"
            guard let sign = get(BKSec.md5Hex(params)) else { return }
            let url = "https://passport.bilibili.com/api/v3/oauth2/login?\(params)&sign=\(sign)" as URL
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let task = URLSession._bk.dataTask(with: request) {
                [weak self] dat, res, err in
                guard let data = dat, !data.isEmpty else {
                    return handle(.failure(.responseError(reason:
                        .urlSessionError(err, response: res))))
                }
                handle(Result { try JSONDecoder().decode(Wrapper.self, from: data) }
                    .mapError { BKError.parseError(reason: .jsonDecode(data, failure: $0)) }
                    .map { [weak self] in
                        let cookie = BKCookie(_sequence: $0.data.cookie_info.cookies
                            .lazy.map { "\($0.name)=\($0.value)" })!
                        self?.cookie = cookie
                        return cookie
                    }
                )
            }
            task.resume()
        }
    }
    
    private struct Encryption: Decodable {
        let hash: String
        let key: String
    }
    
    private func getPublicKey(completionHandler handle: @escaping BKHandler<Encryption>) {
        let url = "https://passport.bilibili.com/login?act=getkey" as URL
        let task = URLSession._bk.dataTask(with: url) { dat, res, err in
            guard let data = dat else {
                return handle(.failure(.responseError(reason: .urlSessionError(err, response: res))))
            }
            handle(Result { try JSONDecoder().decode(Encryption.self, from: data) }
                .mapError { BKError.parseError(reason: .jsonDecode(data, failure: $0)) })
        }
        task.resume()
    }
}
