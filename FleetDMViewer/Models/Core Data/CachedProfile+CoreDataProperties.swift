//
//  CachedProfile+CoreDataProperties.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 8/24/23.
//
//

import Foundation
import CoreData

extension CachedProfile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedProfile> {
        return NSFetchRequest<CachedProfile>(entityName: "CachedProfile")
    }

    @NSManaged public var profileId: Int16
    @NSManaged public var name: String?
    @NSManaged public var status: String?
    @NSManaged public var operationType: String?
    @NSManaged public var detail: String?
    @NSManaged public var mdm: CachedMdm?

    var wrappedName: String {
        name ?? ""
    }

    var wrappedStatus: String {
        status ?? ""
    }

    var wrappedOperationType: String {
        operationType ?? ""
    }

    var wrappedDetail: String {
        detail ?? ""
    }

}

extension CachedProfile: Identifiable {

}
