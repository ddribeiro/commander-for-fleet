//
//  CachedSoftware.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 1/8/24.
//
//

import Foundation
import SwiftData


@Model public class CachedSoftware {
    var bundleIdentifier: String?
    var hostCount: Int16? = 0
    @Attribute(.unique) var id: Int32? = 0
    var installedPaths: String?
    var lastOpenedAt: Date?
    var name: String?
    var source: String?
    var version: String?
    var hosts: [CachedHost]?
    @Relationship(inverse: \CachedVulnerability.software) var vulnerabilities: [CachedVulnerability]?
    public init() {

    }
    
}
