//
//  Extension-JSONDecoder.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 9/21/24.
//

import Foundation

extension JSONDecoder.DateDecodingStrategy {
    static let iso8601withOptionalFractionalSeconds = custom {
        let string = try $0.singleValueContainer().decode(String.self)

        do {
            return try .init(string, strategy: .iso8601withFractionalSeconds)
        } catch {
            return try .init(string, strategy: .iso8601)
        }
    }
}
