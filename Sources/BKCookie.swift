//
//  BKCookie.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 7/9/17.
//  Copyright (c) 2017-2019 ApolloZhu. MIT License.
//

import Foundation

/// Cookie required to post danmaku
public struct BKCookie: Codable, ExpressibleByDictionaryLiteral {
    /// Initialize a Cookie from a dictionary literal,
    /// fatalError if failed to provide all necessary components.
    ///
    /// - Parameter elements: with keys in CodingKeys and their values.
    public init(dictionaryLiteral elements: (String, String)...) {
        let get: (String) -> String? = { key in elements.first { $0.0 == key }?.1 }
        guard let str = get(CodingKeys.mid.stringValue)
            , let mid = Int(str)
            , let sum = get(CodingKeys.md5Sum.stringValue)
            , let data = get(CodingKeys.sessionData.stringValue)
            , let csrf = get(CodingKeys.csrf.stringValue)
            // FIXME: Can not return nil here from some reason...
            else { fatalError("Missing components from BKCookie dictionary literal") }
        self.init(DedeUserID: mid, DedeUserID__ckMd5: sum, SESSDATA: data, bili_jct: csrf)
    }
    
    #if os(iOS) || os(watchOS) || os(tvOS)
    // We are supposed to have nothing here.
    #else
    /// Default Cookie as saved in a file named `bilicookies`
    /// at current working directory, which can be retrieved
    /// using https://github.com/dantmnf/biliupload/blob/master/getcookie.py ,
    /// and appending `;bili_jct=value of cookie named bili_jct` .
    public static var `default`: BKCookie! = BKCookie()
    #endif
    
    /// File name which stores cookie as and loads from.
    public static let filename = "bilicookies"
    
    /// Default path for cookies to load from and save to.
    public static var defaultPath: String {
        return "\(FileManager.default.currentDirectoryPath)/\(BKCookie.filename)"
    }
    
    /// DedeUserID
    public let mid: Int
    /// DedeUserID__ckMd5
    private let md5Sum: String
    /// SESSDATA
    private let sessionData: String
    /// CSRF
    public let csrf: String
    
    /// Keys to use when encoding to other formats
    ///
    /// - mid: DedeUserID
    /// - md5Sum: DedeUserID__ckMd5
    /// - sessionData: SESSDATA
    /// - csrf: bili_jct
    public enum CodingKeys: String, CodingKey {
        case mid = "DedeUserID"
        case md5Sum = "DedeUserID__ckMd5"
        case sessionData = "SESSDATA"
        case csrf = "bili_jct"
    }
    
    /// Initialize a Cookie with required cookie value,
    /// available after login a bilibili account.
    ///
    /// - Parameters:
    ///   - DedeUserID: user's mid assigned by bilibili
    ///   - DedeUserID__ckMd5: md5 sum calculated by bilibili
    ///   - SESSDATA: some session data saved by bilibili
    ///   - bili_jct: csrf value assigned by bilibili
    public init(DedeUserID: Int, DedeUserID__ckMd5: String, SESSDATA: String, bili_jct: String) {
        mid = DedeUserID
        md5Sum = DedeUserID__ckMd5
        sessionData = SESSDATA
        csrf = bili_jct
    }
    
    /// Initialize a Cookie with a file at path,
    /// whose contents are of format
    /// `DedeUserID=xx;DedeUserID__ckMd5=xx;SESSDATA=xx`
    ///
    /// - Parameters:
    ///   - path: path to the file, or the directory
    ///           where `bilicookies` file is stored.
    public init?(path: String? = nil) {
        guard let string = try? String(contentsOfFile: path ??
            "\(FileManager.default.currentDirectoryPath)/\(BKCookie.filename)"
            ) else { return nil }
        let splited = string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: ";")
        self.init(array: splited)
    }
    
    /// Initialize a Cookie based on raw cookie, preferably
    /// HTTPURLResponse.allHeaderFields["Set-Cookie"].
    ///
    /// - Parameter headerField: raw cookie.
    public init?(headerField: String) {
        let separator = CharacterSet(charactersIn: "; ")
        let splited = headerField.components(separatedBy: separator)
        self.init(array: splited)
    }
    
    init?<AnyString: StringProtocol>(array: [AnyString]) {
        var dict = [String:String]()
        for part in array {
            let parts = part
                .split(separator: "=")
                .map { "\($0)".trimmingCharacters(in: .whitespacesAndNewlines) }
            if parts.count == 2 { dict[parts[0]] = parts[1] }
        }
        self.init(dictionary: dict)
    }
    
    
    /// Initialize a Cookie from contents of a dictionary.
    ///
    /// - Parameter dictionary: with keys in CodingKeys and their values.
    public init?(dictionary: [String:String]) {
        guard let str = dictionary[CodingKeys.mid.stringValue]
            , let mid = Int(str)
            , let sum = dictionary[CodingKeys.md5Sum.stringValue]
            , let data = dictionary[CodingKeys.sessionData.stringValue]
            , let csrf = dictionary[CodingKeys.csrf.stringValue]
            else { return nil }
        self.init(DedeUserID: mid, DedeUserID__ckMd5: sum, SESSDATA: data, bili_jct: csrf)
    }
    
    /// Cookie in format of request header
    public var asHeaderField: String {
        return "\(CodingKeys.mid.stringValue)=\(mid);\(CodingKeys.md5Sum.stringValue)=\(md5Sum);\(CodingKeys.sessionData.stringValue)=\(sessionData);\(CodingKeys.csrf.stringValue)=\(csrf)"
    }
    
    /// Save this cookie to file.
    ///
    /// - Parameter path: path to save the cookie, default to `BKCookie.defaultPath`.
    /// - Returns: discardable, if saved successfully.
    @discardableResult public func save(toPath path: String = BKCookie.defaultPath) -> Bool {
        do {
            try asHeaderField.write(toFile: path, atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }
}
