//
//  CachedProfile+CoreDataProperties.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 12/1/23.
//
//

import Foundation
import CoreData

extension CachedProfile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedProfile> {
        return NSFetchRequest<CachedProfile>(entityName: "CachedProfile")
    }

    @NSManaged public var detail: String?
    @NSManaged public var name: String?
    @NSManaged public var operationType: String?
    @NSManaged public var profileId: Int16
    @NSManaged public var status: String?
    @NSManaged public var hosts: NSSet?

}

// MARK: Generated accessors for hosts
extension CachedProfile {

    @objc(addHostsObject:)
    @NSManaged public func addToHosts(_ value: CachedHost)

    @objc(removeHostsObject:)
    @NSManaged public func removeFromHosts(_ value: CachedHost)

    @objc(addHosts:)
    @NSManaged public func addToHosts(_ values: NSSet)

    @objc(removeHosts:)
    @NSManaged public func removeFromHosts(_ values: NSSet)

}

extension CachedProfile: Identifiable {

}
