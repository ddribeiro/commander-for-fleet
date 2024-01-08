//
//  CachedHost+CoreDataProperties.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 12/1/23.
//
//

//import Foundation
//import CoreData
//
//extension CachedHost {
//
//    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedHost> {
//        return NSFetchRequest<CachedHost>(entityName: "CachedHost")
//    }
//
//    @NSManaged public var computerName: String?
//    @NSManaged public var cpuBrand: String?
//    @NSManaged public var diskEncryptionEnabled: Bool
//    @NSManaged public var gigsDiskSpaceAvailable: Double
//    @NSManaged public var hardwareModel: String?
//    @NSManaged public var hardwareSerial: String?
//    @NSManaged public var id: Int16
//    @NSManaged public var lastEnrolledAt: Date?
//    @NSManaged public var memory: Int64
//    @NSManaged public var osVersion: String?
//    @NSManaged public var percentDiskSpaceAvailable: Double
//    @NSManaged public var platform: String?
//    @NSManaged public var primaryIp: String?
//    @NSManaged public var primaryMac: String?
//    @NSManaged public var publicIp: String?
//    @NSManaged public var seenTime: Date?
//    @NSManaged public var status: String?
//    @NSManaged public var teamId: Int16
//    @NSManaged public var teamName: String?
//    @NSManaged public var uptime: Int64
//    @NSManaged public var uuid: String?
//    @NSManaged public var battery: CachedBattery?
//    @NSManaged public var policies: NSSet?
//    @NSManaged public var software: NSSet?
//    @NSManaged public var team: CachedTeam?
//    @NSManaged public var commands: CachedCommandResponse?
//    @NSManaged public var profiles: NSSet?
//
//    var wrappedLastEnrolledAt: Date {
//        lastEnrolledAt ?? Date.now
//    }
//
//    var wrappedSeenTime: Date {
//        seenTime ?? Date.now
//    }
//
//    var wrappedUuid: String {
//        uuid ?? ""
//    }
//
//    var wrappedOsVersion: String {
//        osVersion ?? ""
//    }
//
//    var wrappedCpuBrand: String {
//        cpuBrand ?? ""
//    }
//
//    var wrappedHardwareModel: String {
//        hardwareModel ?? ""
//    }
//
//    var wrappedHardwareSerial: String {
//        hardwareSerial ?? ""
//    }
//
//    var wrappedComputerName: String {
//        computerName ?? ""
//    }
//
//    var wrappedPlatform: String {
//        platform ?? ""
//    }
//
//    var wrappedPublicIp: String {
//        publicIp ?? ""
//    }
//
//    var wrappedPrimaryIp: String {
//        primaryIp ?? ""
//    }
//
//    var wrappedPrimaryMac: String {
//        primaryMac ?? ""
//    }
//
//    var wrappedStatus: String {
//        status ?? ""
//    }
//
//    var policiesArray: [CachedPolicy] {
//        let set = policies as? Set<CachedPolicy> ?? []
//
//        return set.sorted {
//            $0.wrappedName < $1.wrappedName
//        }
//    }
//
//    var wrappedTeamName: String {
//        teamName ?? ""
//    }
//
//    var softwareArray: [CachedSoftware] {
//        let set = software as? Set<CachedSoftware> ?? []
//
//        return set.sorted {
//            $0.wrappedName < $1.wrappedName
//        }
//    }
//
//    public var formattedDate: String {
//        let date: String = {
//            if Calendar.current.isDateInToday(wrappedSeenTime) {
//                return String(localized: "Today")
//            } else if Calendar.current.isDateInYesterday(wrappedSeenTime) {
//                return String(localized: "Yesterday")
//            } else {
//                return wrappedSeenTime.formatted(date: .numeric, time: .omitted)
//            }
//        }()
//        let time = wrappedSeenTime.formatted(date: .omitted, time: .shortened)
//        return "\(date), \(time)"
//    }
//}
//
//// MARK: Generated accessors for policies
//extension CachedHost {
//
//    @objc(addPoliciesObject:)
//    @NSManaged public func addToPolicies(_ value: CachedPolicy)
//
//    @objc(removePoliciesObject:)
//    @NSManaged public func removeFromPolicies(_ value: CachedPolicy)
//
//    @objc(addPolicies:)
//    @NSManaged public func addToPolicies(_ values: NSSet)
//
//    @objc(removePolicies:)
//    @NSManaged public func removeFromPolicies(_ values: NSSet)
//
//}
//
//// MARK: Generated accessors for software
//extension CachedHost {
//
//    @objc(addSoftwareObject:)
//    @NSManaged public func addToSoftware(_ value: CachedSoftware)
//
//    @objc(removeSoftwareObject:)
//    @NSManaged public func removeFromSoftware(_ value: CachedSoftware)
//
//    @objc(addSoftware:)
//    @NSManaged public func addToSoftware(_ values: NSSet)
//
//    @objc(removeSoftware:)
//    @NSManaged public func removeFromSoftware(_ values: NSSet)
//
//}
//
//// MARK: Generated accessors for profiles
//extension CachedHost {
//
//    @objc(addProfilesObject:)
//    @NSManaged public func addToProfiles(_ value: CachedProfile)
//
//    @objc(removeProfilesObject:)
//    @NSManaged public func removeFromProfiles(_ value: CachedProfile)
//
//    @objc(addProfiles:)
//    @NSManaged public func addToProfiles(_ values: NSSet)
//
//    @objc(removeProfiles:)
//    @NSManaged public func removeFromProfiles(_ values: NSSet)
//
//}
//
//extension CachedHost: Identifiable {
//
//}
