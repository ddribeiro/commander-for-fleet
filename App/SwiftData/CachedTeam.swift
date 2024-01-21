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
    @Relationship(deleteRule: .cascade, inverse: \CachedHost.team) var hosts: [CachedHost]? = [CachedHost]()
    @Relationship(deleteRule: .cascade, inverse: \CachedUser.teams) var users: [CachedUser]? = [CachedUser]()

    init(hostCount: Int? = nil, id: Int, name: String, role: String? = nil) {
        self.hostCount = hostCount
        self.id = id
        self.name = name
        self.role = role
    }
}
