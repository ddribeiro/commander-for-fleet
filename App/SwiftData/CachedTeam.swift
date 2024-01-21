//
//  CachedTeam.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 1/8/24.
//
//

import Foundation
import SwiftData

@Model class CachedTeam {
    var hostCount: Int?
    @Attribute(.unique) var id: Int
    var name: String
    var role: String?
    var hosts: [CachedHost]?
    @Relationship(inverse: \CachedUser.teams) var users: [CachedUser]?

    init(hostCount: Int? = nil, id: Int, name: String, role: String? = nil, hosts: [CachedHost]? = nil, users: [CachedUser]? = nil) {
        self.hostCount = hostCount
        self.id = id
        self.name = name
        self.role = role
        self.hosts = hosts
        self.users = users
    }
}
