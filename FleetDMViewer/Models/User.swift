//
//  User.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/14/23.
//

import Foundation

struct User: Codable, Identifiable {
    var createdAt: Date
    var updatedAt: Date
    var id: Int
    var name: String
    var email: String
    var globalRole: String
    var gravatarUrl: String
    var ssoEnabled: Bool
    var apiOnly: Bool
    var teams: [Team]
}
