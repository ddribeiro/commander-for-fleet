//
//  Team.swift
//  Commander
//
//  Created by Dale Ribeiro on 6/8/23.
//

import Foundation

struct Team: Codable, Identifiable, Hashable {
    var id: Int
    var name: String
    var description: String
    var hostCount: Int?
    var role: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        hostCount = try container.decodeIfPresent(Int.self, forKey: .hostCount)
        role = try container.decodeIfPresent(String.self, forKey: .role)
    }

    // Explicit memberwise init, since defining `init(from:)` above removes the synthesized one.
    init(id: Int = 0, name: String = "", description: String = "", hostCount: Int? = nil, role: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.hostCount = hostCount
        self.role = role
    }

    static let example = Team(
        id: 2,
        name: "Harmonize - Engineering",
        description: "",
        hostCount: 0
    )
}
