//
//  CachedCommandResponse+CoreDataProperties.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/17/23.
//
//

import Foundation
import CoreData

extension CachedCommandResponse {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedCommandResponse> {
        return NSFetchRequest<CachedCommandResponse>(entityName: "CachedCommandResponse")
    }

    @NSManaged public var deviceID: String?
    @NSManaged public var commandUUID: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var requestType: String?
    @NSManaged public var status: String?
    @NSManaged public var hostname: String?

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

}

extension CachedCommandResponse: Identifiable {

}
