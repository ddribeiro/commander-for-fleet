//
//  CachedProfile.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 1/8/24.
//
//

import Foundation
import SwiftData

@Model class CachedProfile {
    var detail: String
    var name: String
    var operationType: String
    @Attribute(.unique) var profileId: Int
    var status: String
    var hosts: [CachedHost]?

    init(detail: String, name: String, operationType: String, profileId: Int, status: String, hosts: [CachedHost]? = nil) {
        self.detail = detail
        self.name = name
        self.operationType = operationType
        self.profileId = profileId
        self.status = status
        self.hosts = hosts
    }
}
