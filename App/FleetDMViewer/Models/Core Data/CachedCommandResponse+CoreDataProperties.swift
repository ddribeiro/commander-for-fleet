//
//  CachedCommandResponse+CoreDataProperties.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 12/1/23.
//
//

import Foundation
import CoreData

extension CachedCommandResponse {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedCommandResponse> {
        return NSFetchRequest<CachedCommandResponse>(entityName: "CachedCommandResponse")
    }

    @NSManaged public var commandUUID: String?
    @NSManaged public var deviceID: String?
    @NSManaged public var hostname: String?
    @NSManaged public var requestType: String?
    @NSManaged public var status: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var hosts: NSSet?

    var wrappedDeviceID: String {
        deviceID ?? ""
    }

    var wrappedCommandUUID: String {
        commandUUID ?? ""
    }

    var wrappedUpdatedAt: Date {
        updatedAt ?? .now
    }

    var wrappedRequestType: String {
        requestType ?? ""
    }

    var wrappedStatus: String {
        status ?? ""
    }

    var wrappedHostname: String {
        hostname ?? ""
    }

    var hostsArray: [CachedHost] {
        let set = hosts as? Set<CachedHost> ?? []

        return set.sorted {
            $0.wrappedComputerName < $1.wrappedComputerName
        }
    }
}

// MARK: Generated accessors for hosts
extension CachedCommandResponse {

    @objc(addHostsObject:)
    @NSManaged public func addToHosts(_ value: CachedHost)

    @objc(removeHostsObject:)
    @NSManaged public func removeFromHosts(_ value: CachedHost)

    @objc(addHosts:)
    @NSManaged public func addToHosts(_ values: NSSet)

    @objc(removeHosts:)
    @NSManaged public func removeFromHosts(_ values: NSSet)

}

extension CachedCommandResponse: Identifiable {

}
