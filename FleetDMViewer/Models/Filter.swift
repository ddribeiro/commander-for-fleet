//
//  Filter.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 8/29/23.
//

import Foundation

struct Filter: Identifiable, Hashable {
    var id: Int
    var name: String
    var icon: String
    var minEnrollmentDate = Date.distantPast
    var team: CachedTeam?

    var hostCount: Int {
        Int(team?.hostCount ?? 0)
    }

    static var all = Filter(
        id: 0,
        name: "All",
        icon: "laptopcomputer"
    )

    static var recentlyEnrolled = Filter(
        id: 134331,
        name: "Recently Enrolled",
        icon: "clock",
        minEnrollmentDate: .now.addingTimeInterval(86400 * -7)
    )

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // swiftlint:disable:next operator_whitespace
    static func ==(lhs: Filter, rhs: Filter) -> Bool {
        lhs.id == rhs.id
    }
}
