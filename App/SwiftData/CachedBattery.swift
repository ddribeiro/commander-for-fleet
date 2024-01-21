//
//  CachedBattery.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 1/8/24.
//
//

import Foundation
import SwiftData

@Model class CachedBattery {
    var cycleCount: Int
    var health: String
    var host: CachedHost

    init(cycleCount: Int, health: String, host: CachedHost) {
        self.cycleCount = cycleCount
        self.health = health
        self.host = host
    }
}
