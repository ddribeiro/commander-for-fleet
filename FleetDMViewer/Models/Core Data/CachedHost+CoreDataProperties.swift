//
//  CachedHost+CoreDataProperties.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 8/24/23.
//
//

import Foundation
import CoreData

extension CachedHost {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedHost> {
        return NSFetchRequest<CachedHost>(entityName: "CachedHost")
    }

    @NSManaged public var id: Int16
    @NSManaged public var lastEnrolledAt: Date?
    @NSManaged public var seenTime: Date?
    @NSManaged public var uuid: String?
    @NSManaged public var osVersion: String?
    @NSManaged public var uptime: Int64
    @NSManaged public var memory: Int64
    @NSManaged public var cpuBrand: String?
    @NSManaged public var hardwareModel: String?
    @NSManaged public var hardwareSerial: String?
    @NSManaged public var computerName: String?
    @NSManaged public var publicIp: String?
    @NSManaged public var primaryIp: String?
    @NSManaged public var primaryMac: String?
    @NSManaged public var teamId: Int16
    @NSManaged public var gigsDiskSpaceAvailable: Double
    @NSManaged public var percentDiskSpaceAvailable: Double
    @NSManaged public var diskEncryptionEnabled: Bool
    @NSManaged public var status: String?
    @NSManaged public var policies: NSSet?
    @NSManaged public var battery: CachedBattery?
    @NSManaged public var mdm: CachedMdm?
    @NSManaged public var software: NSSet?
    @NSManaged public var team: CachedTeam?

    var wrappedlastEnrolledAt: Date {
        lastEnrolledAt ?? Date.now
    }

    var wrappedSeenTime: Date {
        seenTime ?? Date.now
    }

    var wrappedUuid: String {
        uuid ?? ""
    }

    var wrappedOsVersion: String {
        osVersion ?? ""
    }

    var wrappedCpuBrand: String {
        cpuBrand ?? ""
    }

    var wrappedHardwareModel: String {
        hardwareModel ?? ""
    }

    var wrappedHardwareSerial: String {
        hardwareSerial ?? ""
    }

    var wrappedComputerName: String {
        computerName ?? ""
    }

    var wrappedPublicIp: String {
        publicIp ?? ""
    }

    var wrappedPrimaryIp: String {
        primaryIp ?? ""
    }

    var wrappedPrimaryMac: String {
        primaryMac ?? ""
    }

    var wrappedStatus: String {
        status ?? ""
    }

    var policiesArray: [CachedPolicy] {
        let set = policies as? Set<CachedPolicy> ?? []

        return set.sorted {
            $0.wrappedName < $1.wrappedName
        }
    }

    var softwareArray: [CachedSoftware] {
        let set = software as? Set<CachedSoftware> ?? []

        return set.sorted {
            $0.wrappedName < $1.wrappedName
        }
    }

}

// MARK: Generated accessors for policies
extension CachedHost {

    @objc(addPoliciesObject:)
    @NSManaged public func addToPolicies(_ value: CachedPolicy)

    @objc(removePoliciesObject:)
    @NSManaged public func removeFromPolicies(_ value: CachedPolicy)

    @objc(addPolicies:)
    @NSManaged public func addToPolicies(_ values: NSSet)

    @objc(removePolicies:)
    @NSManaged public func removeFromPolicies(_ values: NSSet)

}

// MARK: Generated accessors for software
extension CachedHost {

    @objc(addSoftwareObject:)
    @NSManaged public func addToSoftware(_ value: CachedSoftware)

    @objc(removeSoftwareObject:)
    @NSManaged public func removeFromSoftware(_ value: CachedSoftware)

    @objc(addSoftware:)
    @NSManaged public func addToSoftware(_ values: NSSet)

    @objc(removeSoftware:)
    @NSManaged public func removeFromSoftware(_ values: NSSet)

}

extension CachedHost: Identifiable {

}
