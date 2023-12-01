//
//  Team.swift
//  FleetDMViewer
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

    static let example = Team(
        id: 2,
        name: "Harmonize - Engineering",
        description: "",
        hostCount: 0
    )
}
