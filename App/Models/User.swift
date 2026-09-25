//
//  User.swift
//  Commander
//
//  Created by Dale Ribeiro on 6/14/23.
//

import Foundation

struct User: Codable, Identifiable, Hashable {
    var createdAt: Date
    var updatedAt: Date
    var id: Int
    var name: String
    var email: String
    var globalRole: String?
    var gravatarUrl: String
    var position: String?
    var ssoEnabled: Bool
    var apiOnly: Bool
    var teams: [Team]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? .distantPast
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? .distantPast
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        globalRole = try container.decodeIfPresent(String.self, forKey: .globalRole)
        gravatarUrl = try container.decodeIfPresent(String.self, forKey: .gravatarUrl) ?? ""
        position = try container.decodeIfPresent(String.self, forKey: .position)
        ssoEnabled = try container.decodeIfPresent(Bool.self, forKey: .ssoEnabled) ?? false
        apiOnly = try container.decodeIfPresent(Bool.self, forKey: .apiOnly) ?? false
        teams = try container.decodeIfPresent([Team].self, forKey: .teams) ?? []
    }

    // Explicit memberwise init, since defining `init(from:)` above removes the synthesized one.
    init(createdAt: Date = .distantPast, updatedAt: Date = .distantPast, id: Int = 0,
         name: String = "", email: String = "", globalRole: String? = nil,
         gravatarUrl: String = "", position: String? = nil, ssoEnabled: Bool = false,
         apiOnly: Bool = false, teams: [Team] = []) {
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.id = id
        self.name = name
        self.email = email
        self.globalRole = globalRole
        self.gravatarUrl = gravatarUrl
        self.position = position
        self.ssoEnabled = ssoEnabled
        self.apiOnly = apiOnly
        self.teams = teams
    }

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

/// Response for the `/me` and `/users/{id}` endpoints.
struct MeResponse: Codable {
    var user: User?
    var availableTeams: [Team]?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        user = try container.decodeIfPresent(User.self, forKey: .user)
        availableTeams = try container.decodeIfPresent([Team].self, forKey: .availableTeams)
    }

    init(user: User? = nil, availableTeams: [Team]? = nil) {
        self.user = user
        self.availableTeams = availableTeams
    }
}
