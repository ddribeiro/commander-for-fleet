//
//  CachedBattery+CoreDataProperties.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 12/1/23.
//
//

import Foundation
import CoreData

extension CachedBattery {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedBattery> {
        return NSFetchRequest<CachedBattery>(entityName: "CachedBattery")
    }

    @NSManaged public var cycleCount: Int16
    @NSManaged public var health: String?
    @NSManaged public var host: CachedHost?

}

extension CachedBattery: Identifiable {

}
