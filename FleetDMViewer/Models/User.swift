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

    static let example = User(
        createdAt: .now,
        updatedAt: .now,
        id: 1,
        name: "Dale Ribeiro",
        email: "dale@harmonize.io",
        globalRole: "admin",
        gravatarUrl: "https://gravatar.com/avatar/55e4cc1c7008b7d162fd66a0172650d0",
        ssoEnabled: false,
        apiOnly: true,
        teams: [.example]
    )
}
