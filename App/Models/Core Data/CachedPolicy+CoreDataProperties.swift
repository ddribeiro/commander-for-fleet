//
//  CachedPolicy+CoreDataProperties.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 12/5/23.
//
//

//import Foundation
//import CoreData
//
//extension CachedPolicy {
//
//    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedPolicy> {
//        return NSFetchRequest<CachedPolicy>(entityName: "CachedPolicy")
//    }
//
//    @NSManaged public var critical: Bool
//    @NSManaged public var policyDescription: String?
//    @NSManaged public var id: Int16
//    @NSManaged public var name: String?
//    @NSManaged public var response: String?
//    @NSManaged public var query: String?
//    @NSManaged public var authorId: Int16
//    @NSManaged public var authorName: String?
//    @NSManaged public var authorEmail: String?
//    @NSManaged public var teamId: Int16
//    @NSManaged public var resolution: String?
//    @NSManaged public var platform: String?
//    @NSManaged public var createdAt: Date?
//    @NSManaged public var updatedAt: Date?
//    @NSManaged public var passingHostCount: Int16
//    @NSManaged public var failingHostCount: Int16
//    @NSManaged public var hosts: NSSet?
//
//    var wrappedPolicyDescription: String {
//        policyDescription ?? ""
//    }
//
//    var wrappedName: String {
//        name ?? ""
//    }
//
//    var wrappedResponse: String {
//        response ?? ""
//    }
//
//    var wrappedQuery: String {
//        query ?? ""
//    }
//
//    var wrappedAuthorName: String {
//        authorName ?? ""
//    }
//
//    var wrappedAuthorEmail: String {
//        authorEmail ?? ""
//    }
//
//    var wrappedResolution: String {
//        resolution ?? ""
//    }
//
//    var wrappedPlatform: String {
//        platform ?? ""
//    }
//
//    var wrappedCreatedAt: Date {
//        createdAt ?? .now
//    }
//
//    var wrappedUpdatedAt: Date {
//        updatedAt ?? .now
//    }
//
//    var hostsArray: [CachedHost] {
//        let set = hosts as? Set<CachedHost> ?? []
//
//        return set.sorted {
//            $0.wrappedComputerName < $1.wrappedComputerName
//        }
//    }
//
//}
//
//// MARK: Generated accessors for hosts
//extension CachedPolicy {
//
//    @objc(addHostsObject:)
//    @NSManaged public func addToHosts(_ value: CachedHost)
//
//    @objc(removeHostsObject:)
//    @NSManaged public func removeFromHosts(_ value: CachedHost)
//
//    @objc(addHosts:)
//    @NSManaged public func addToHosts(_ values: NSSet)
//
//    @objc(removeHosts:)
//    @NSManaged public func removeFromHosts(_ values: NSSet)
//
//}
//
//extension CachedPolicy: Identifiable {
//
//}
