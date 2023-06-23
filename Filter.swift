//
//  Filter.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/7/23.
//

import Foundation

struct Filter: Identifiable, Hashable {
    var id: Int
    var name: String
    var icon: String
    var minModificationDate = Date.distantPast
    var team: Team?
}
