//
//  CachedTeam+CoreDataProperties.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 12/1/23.
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
    @NSManaged public var role: String?
    @NSManaged public var hosts: NSSet?
    @NSManaged public var users: NSSet?

    var wrappedName: String {
        name ?? ""
    }

    var wrappedRole: String {
        role ?? ""
    }

    var hostsArray: [CachedHost] {
        let set = hosts as? Set<CachedHost> ?? []

        return set.sorted {
            $0.wrappedComputerName < $1.wrappedComputerName
        }
    }

    var usersArray: [CachedUser] {
        let set = users as? Set<CachedUser> ?? []

        return set.sorted {
            $0.wrappedName < $1.wrappedName
        }
    }

}

// MARK: Generated accessors for hosts
extension CachedTeam {

    @objc(addHostsObject:)
    @NSManaged public func addToHosts(_ value: CachedHost)

    @objc(removeHostsObject:)
    @NSManaged public func removeFromHosts(_ value: CachedHost)

    @objc(addHosts:)
    @NSManaged public func addToHosts(_ values: NSSet)

    @objc(removeHosts:)
    @NSManaged public func removeFromHosts(_ values: NSSet)

}

// MARK: Generated accessors for users
extension CachedTeam {

    @objc(addUsersObject:)
    @NSManaged public func addToUsers(_ value: CachedUser)

    @objc(removeUsersObject:)
    @NSManaged public func removeFromUsers(_ value: CachedUser)

    @objc(addUsers:)
    @NSManaged public func addToUsers(_ values: NSSet)

    @objc(removeUsers:)
    @NSManaged public func removeFromUsers(_ values: NSSet)

}

extension CachedTeam: Identifiable {

}
