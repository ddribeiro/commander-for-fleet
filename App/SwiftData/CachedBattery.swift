//
//  CachedBattery.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 1/8/24.
//
//

import Foundation
import SwiftData


@Model public class CachedBattery {
    var cycleCount: Int16? = 0
    var health: String?
    @Relationship(inverse: \CachedHost.battery) var host: CachedHost?
    public init() {

    }
    
}
