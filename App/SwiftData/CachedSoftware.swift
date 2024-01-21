//
//  CachedSoftware.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 1/8/24.
//
//

import Foundation
import SwiftData

@Model class CachedSoftware: Identifiable {
    var bundleIdentifier: String?
    var hostCount: Int
    @Attribute(.unique) var id: Int
    var installedPaths: [String]?
    var lastOpenedAt: Date?
    var name: String
    var source: String
    var version: String
    var hosts =  [CachedHost]()
    @Relationship(inverse: \CachedVulnerability.software) var vulnerabilities = [CachedVulnerability]()

    // swiftlint:disable:next line_length
    init(bundleIdentifier: String? = nil, hostCount: Int, id: Int, installedPaths: [String]? = nil, lastOpenedAt: Date? = nil, name: String, source: String, version: String) {
        self.bundleIdentifier = bundleIdentifier
        self.hostCount = hostCount
        self.id = id
        self.installedPaths = installedPaths
        self.lastOpenedAt = lastOpenedAt
        self.name = name
        self.source = source
        self.version = version
    }
}
