//
//  HostsSortType.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 2/2/24.
//

import Foundation

@Observable
class SortOptions {
    var selectedSortType: SortType = .name
    var selectedSortStatus: Status = .all
    var selectedSortOrder: SortOrder = .forward

    // Enum to define the types that hosts can be sorted by.
    enum SortType: String {
        case name = "computerName"
        case enolledDate = "lastEnrolledAt"
        case updatedDate = "seenTime"
    }

    // Enum to define states that hosts can be filtered by.
    enum Status {
        case all, online, offline, missing, recentlyEnrolled
    }

}
