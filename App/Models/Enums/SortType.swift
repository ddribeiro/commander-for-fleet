//
//  SortType.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 9/26/24.
//

import Foundation

// Enum to define the types that hosts can be sorted by.
enum SortType: String {
    case name = "computerName"
    case enolledDate = "lastEnrolledAt"
    case updatedDate = "seenTime"
}
