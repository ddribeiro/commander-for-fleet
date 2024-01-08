//
//  CachedTeam.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 1/8/24.
//
//

import Foundation
import SwiftData


@Model public class CachedTeam {
    var hostCount: Int16? = 0
    @Attribute(.unique) var id: Int16? = 0
    var name: String?
    var role: String?
    var hosts: [CachedHost]?
    @Relationship(inverse: \CachedUser.teams) var users: [CachedUser]?
    public init() {

    }
    
}
