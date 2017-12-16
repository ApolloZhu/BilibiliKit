//
//  BKCookie.swift
//  BilibiliKit
//
//  Created by Apollo Zhu on 7/9/17.
//

import Foundation

/// Cookie required to post danmaku
public struct BKCookie: Codable {
    
    #if os(iOS) || os(watchOS) || os(tvOS)
    // We are supposed to have nothing here.
    #else
    /// Default Cookie as saved in a file named `bilicookies`
    /// at current working directory, which can be retrieved
    /// using https://github.com/dantmnf/biliupload/blob/master/getcookie.py .
    public static var `default`: BKCookie! = BKCookie()
    #endif
    
    /// File name which stores cookie as and loads from.
    public static let filename = "bilicookies"
    
    /// Default path for cookies to load from and save to.
    public static var defaultPath: String {
        return "\(FileManager.default.currentDirectoryPath)/\(BKCookie.filename)"
    }
    
    /// DedeUserID
    private let mid: Int
    /// DedeUserID__ckMd5
    private let md5Sum: String
    /// SESSDATA
    private let sessionData: String
    
    /// Keys to use when encoding to other formats
    ///
    /// - mid: DedeUserID
    /// - md5Sum: DedeUserID__ckMd5
    /// - sessionData: SESSDATA
    enum CodingKeys: String, CodingKey {
        case mid = "DedeUserID"
        case md5Sum = "DedeUserID__ckMd5"
        case sessionData = "SESSDATA"
    }
    
    /// Initialize a Cookie with required cookie value,
    /// available after login a bilibili account.
    ///
    /// - Parameters:
    ///   - DedeUserID: user's mid assigned by bilibili
    ///   - DedeUserID__ckMd5: md5 sum calculated by bilibili
    ///   - SESSDATA: some session data saved by bilibili
    public init(DedeUserID: Int, DedeUserID__ckMd5: String, SESSDATA: String) {
        mid = DedeUserID
        md5Sum = DedeUserID__ckMd5
        sessionData = SESSDATA
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
        var dict = [String:String]()
        for part in string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: ";") {
                let parts = part
                    .split(separator: "=")
                    .map { "\($0)".trimmingCharacters(in: .whitespacesAndNewlines) }
                if parts.count == 2 { dict[parts[0]] = parts[1] }
        }
        guard let str = dict[CodingKeys.mid.stringValue],
            let mid = Int(str),
            let sum = dict[CodingKeys.md5Sum.stringValue],
            let data = dict[CodingKeys.sessionData.stringValue]
            else { return nil }
        self.init(DedeUserID: mid, DedeUserID__ckMd5: sum, SESSDATA: data)
    }
    
    public init?(headerField: String) {
        var dict = [String:String]()
        for part in headerField.split(whereSeparator: { "; ".contains($0) }) {
            let parts = part
                .split(separator: "=")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            if parts.count == 2 { dict[parts[0]] = parts[1] }
        }
        guard let str = dict[CodingKeys.mid.stringValue],
            let mid = Int(str),
            let sum = dict[CodingKeys.md5Sum.stringValue],
            let data = dict[CodingKeys.sessionData.stringValue]
            else { return nil }
        self.init(DedeUserID: mid, DedeUserID__ckMd5: sum, SESSDATA: data)
    }
    
    /// Cookie in format of request header
    public var asHeaderField: String {
        return "\(CodingKeys.mid.stringValue)=\(mid);\(CodingKeys.md5Sum.stringValue)=\(md5Sum);\(CodingKeys.sessionData.stringValue)=\(sessionData)"
    }
    
    @discardableResult
    public func save(toPath path: String =  BKCookie.defaultPath) -> Bool {
        do {
            try asHeaderField.write(toFile: path, atomically: false, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }
}
