//
//  NetRes.swift
//  LibreMap
//
//  Created by Muhammadjon Tohirov on 07/05/25.
//

import Foundation

public struct NetRes<T: NetResBody>: Codable {
    public let success: Bool
    public let result: T?
    public let message: String?
    public let code: Int?
    public var error: String?
    
    init (success: Bool, result: T?, message: String?, code: Int?, error: String?) {
        self.success = success
        self.result = result
        self.message = message
        self.code = code
        self.error = error
    }
    
    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<NetRes<T>.CodingKeys> = try decoder.container(keyedBy: NetRes<T>.CodingKeys.self)
        let success = try? container.decodeIfPresent(Bool.self, forKey: NetRes<T>.CodingKeys.success)
        let status = try? container.decodeIfPresent(Bool.self, forKey: NetRes<T>.CodingKeys.status)
        
        self.result = try? container.decodeIfPresent(T.self, forKey: NetRes<T>.CodingKeys.result)
        self.message = try? container.decodeIfPresent(String.self, forKey: NetRes<T>.CodingKeys.message)
        self.code = try? container.decodeIfPresent(Int.self, forKey: NetRes<T>.CodingKeys.code)
        self.error = try? container.decodeIfPresent(String.self, forKey: NetRes<T>.CodingKeys.error)
        
        if self.error == nil {
            self.error = (try? container.decodeIfPresent([String].self, forKey: NetRes<T>.CodingKeys.error))?.joined(separator: " ")
        }
        
        self.success = success ?? status ?? false
    }
    
    enum CodingKeys: CodingKey {
        case success
        case result
        case message
        case code
        case error
        case status
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: NetRes<T>.CodingKeys.self)
        try container.encode(self.success, forKey: .success)
        try container.encodeIfPresent(self.result, forKey: .result)
        try container.encodeIfPresent(self.message, forKey: .message)
        try container.encodeIfPresent(self.code, forKey: .code)
        try container.encodeIfPresent(self.error, forKey: .error)
    }
}
