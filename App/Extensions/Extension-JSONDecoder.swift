//
//  Extension-JSONDecoder.swift
//  Commander
//
//  Created by Dale Ribeiro on 9/21/24.
//

import Foundation

extension JSONDecoder.DateDecodingStrategy {
    static let iso8601withOptionalFractionalSeconds = custom {
        let string = try $0.singleValueContainer().decode(String.self)

        // Fleet sometimes returns "" for date fields that are effectively null.
        // ISO8601DateFormatter rejects it, which fails the entire decode, so
        // treat blank strings as distantPast (the models' default) instead.
        if string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return Date.distantPast
        }

        do {
            return try .init(string, strategy: .iso8601withFractionalSeconds)
        } catch {
            return try .init(string, strategy: .iso8601)
        }
    }
}
