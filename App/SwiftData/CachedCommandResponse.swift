//
//  CachedCommandResponse.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 1/8/24.
//
//

import Foundation
import SwiftData


@Model public class CachedCommandResponse {
    @Attribute(.unique) var commandUUID: String?
    var deviceID: String?
    var hostname: String?
    var requestType: String?
    var status: String?
    var updatedAt: Date?
    @Relationship(inverse: \CachedHost.commands) var hosts: [CachedHost]?
    public init() {

    }
    
}
