//
//  CachedUser.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 1/8/24.
//
//

import Foundation
import SwiftData

@Model
class CachedUser: Identifiable {
    var apiOnly: Bool
    var createdAt: Date
    var email: String
    var globalRole: String = ""
    var gravatarUrl: String
    @Attribute(.unique) var id: Int
    var lastFetched: Date?
    var name: String
    var ssoEnabled: Bool
    var updatedAt: Date
    var teams = [CachedTeam]()

    // swiftlint:disable:next line_length
    init(apiOnly: Bool, createdAt: Date, email: String, globalRole: String, gravatarUrl: String, id: Int, lastFetched: Date? = nil, name: String, ssoEnabled: Bool, updatedAt: Date) {
        self.apiOnly = apiOnly
        self.createdAt = createdAt
        self.email = email
        self.globalRole = globalRole
        self.gravatarUrl = gravatarUrl
        self.id = id
        self.lastFetched = lastFetched
        self.name = name
        self.ssoEnabled = ssoEnabled
        self.updatedAt = updatedAt
    }

}
