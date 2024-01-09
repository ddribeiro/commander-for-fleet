//
//  CachedCommandResponse.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 1/8/24.
//
//

import Foundation
import SwiftData


@Model class CachedCommandResponse {
    @Attribute(.unique) var commandUUID: String
    var deviceID: String
    var hostname: String
    var requestType: String
    var status: String
    var updatedAt: Date
    @Relationship(inverse: \CachedHost.commands) var hosts: [CachedHost]?
    
    init(commandUUID: String, deviceID: String, hostname: String, requestType: String, status: String, updatedAt: Date, hosts: [CachedHost]? = nil) {
        self.commandUUID = commandUUID
        self.deviceID = deviceID
        self.hostname = hostname
        self.requestType = requestType
        self.status = status
        self.updatedAt = updatedAt
        self.hosts = hosts
    }
}
