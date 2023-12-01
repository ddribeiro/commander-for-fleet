//
//  CachedPolicy+CoreDataProperties.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 12/1/23.
//
//

import Foundation
import CoreData

extension CachedPolicy {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedPolicy> {
        return NSFetchRequest<CachedPolicy>(entityName: "CachedPolicy")
    }

    @NSManaged public var critical: Bool
    @NSManaged public var id: Int16
    @NSManaged public var name: String?
    @NSManaged public var response: String?
    @NSManaged public var hosts: NSSet?

    var wrappedName: String {
        name ?? ""
    }

    var wrappedResponse: String {
        response ?? ""
    }

    var hostsArray: [CachedHost] {
        let set = hosts as? Set<CachedHost> ?? []

        return set.sorted {
            $0.wrappedComputerName < $1.wrappedComputerName
        }
    }

}

// MARK: Generated accessors for hosts
extension CachedPolicy {

    @objc(addHostsObject:)
    @NSManaged public func addToHosts(_ value: CachedHost)

    @objc(removeHostsObject:)
    @NSManaged public func removeFromHosts(_ value: CachedHost)

    @objc(addHosts:)
    @NSManaged public func addToHosts(_ values: NSSet)

    @objc(removeHosts:)
    @NSManaged public func removeFromHosts(_ values: NSSet)

}

extension CachedPolicy: Identifiable {

}
