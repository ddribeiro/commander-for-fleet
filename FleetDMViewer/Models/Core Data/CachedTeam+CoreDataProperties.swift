//
//  CachedTeam+CoreDataProperties.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 8/24/23.
//
//

import Foundation
import CoreData

extension CachedTeam {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedTeam> {
        return NSFetchRequest<CachedTeam>(entityName: "CachedTeam")
    }

    @NSManaged public var hostCount: Int16
    @NSManaged public var id: Int16
    @NSManaged public var name: String?
    @NSManaged public var user: CachedUser?
    @NSManaged public var hosts: NSSet?

    var wrappedName: String {
        name ?? ""
    }

    var hostsArray: [CachedHost] {
        let set = hosts as? Set<CachedHost> ?? []

        return set.sorted {
            $0.wrappedComputerName < $1.wrappedComputerName
        }
    }

}

// MARK: Generated accessors for host
extension CachedTeam {

    @objc(addHosstObject:)
    @NSManaged public func addToHosts(_ value: CachedHost)

    @objc(removeHostsObject:)
    @NSManaged public func removeFromHosts(_ value: CachedHost)

    @objc(addHosts:)
    @NSManaged public func addToHosts(_ values: NSSet)

    @objc(removeHosts:)
    @NSManaged public func removeFromHosts(_ values: NSSet)

}

extension CachedTeam: Identifiable {

}
