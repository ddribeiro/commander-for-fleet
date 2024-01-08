//
//  CachedUser+CoreDataProperties.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 12/1/23.
//
//

//import Foundation
//import CoreData
//
//extension CachedUser {
//
//    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedUser> {
//        return NSFetchRequest<CachedUser>(entityName: "CachedUser")
//    }
//
//    @NSManaged public var apiOnly: Bool
//    @NSManaged public var lastFetched: Date?
//    @NSManaged public var createdAt: Date?
//    @NSManaged public var email: String?
//    @NSManaged public var globalRole: String?
//    @NSManaged public var gravatarUrl: String?
//    @NSManaged public var id: Int16
//    @NSManaged public var name: String?
//    @NSManaged public var ssoEnabled: Bool
//    @NSManaged public var updatedAt: Date?
//    @NSManaged public var teams: NSSet?
//
//    var wrappedName: String {
//        name ?? ""
//    }
//
//    var wrappedEmail: String {
//        email ?? ""
//    }
//
//    var wrappedGlobalRole: String {
//        globalRole ?? "N/A"
//    }
//
//    var wrappedGravatarUrl: String {
//        gravatarUrl ?? ""
//    }
//
//    var wrappedCreatedAt: Date {
//        createdAt ?? Date.now
//    }
//
//    var wrappedUpdatedAt: Date {
//        updatedAt ?? Date.now
//    }
//
//    var wrappedLastFetched: Date {
//        lastFetched ?? Date.now
//    }
//
//    var teamsArray: [CachedTeam] {
//        let set = teams as? Set<CachedTeam> ?? []
//
//        return set.sorted {
//            $0.wrappedName < $1.wrappedName
//        }
//    }
//
//    @objc dynamic var observableTeamsArray: [CachedTeam] {
//        let set = teams as? Set<CachedTeam> ?? []
//        return set.sorted {
//            $0.wrappedName < $1.wrappedName
//        }
//    }
//}
//
//// MARK: Generated accessors for teams
//extension CachedUser {
//
//    @objc(addTeamsObject:)
//    @NSManaged public func addToTeams(_ value: CachedTeam)
//
//    @objc(removeTeamsObject:)
//    @NSManaged public func removeFromTeams(_ value: CachedTeam)
//
//    @objc(addTeams:)
//    @NSManaged public func addToTeams(_ values: NSSet)
//
//    @objc(removeTeams:)
//    @NSManaged public func removeFromTeams(_ values: NSSet)
//
//}
//
//extension CachedUser: Identifiable {
//
//}
