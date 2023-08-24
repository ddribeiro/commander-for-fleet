//
//  CachedPolicy+CoreDataProperties.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 8/24/23.
//
//

import Foundation
import CoreData

extension CachedPolicy {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedPolicy> {
        return NSFetchRequest<CachedPolicy>(entityName: "CachedPolicy")
    }

    @NSManaged public var id: Int16
    @NSManaged public var name: String?
    @NSManaged public var critical: Bool
    @NSManaged public var response: String?
    @NSManaged public var host: CachedHost?

    var wrappedName: String {
        name ?? ""
    }

    var wrappedResponse: String {
        response ?? ""
    }

}

extension CachedPolicy: Identifiable {

}
