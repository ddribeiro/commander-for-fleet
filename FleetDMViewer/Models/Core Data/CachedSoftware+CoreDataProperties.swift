//
//  CachedSoftware+CoreDataProperties.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 12/1/23.
//
//

import Foundation
import CoreData

extension CachedSoftware {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedSoftware> {
        return NSFetchRequest<CachedSoftware>(entityName: "CachedSoftware")
    }

    @NSManaged public var bundleIdentifier: String?
    @NSManaged public var id: Int16
    @NSManaged public var installedPaths: String?
    @NSManaged public var lastOpenedAt: Date?
    @NSManaged public var name: String?
    @NSManaged public var source: String?
    @NSManaged public var version: String?
    @NSManaged public var hosts: NSSet?
    @NSManaged public var vulnerabilities: NSSet?

    var wrappedName: String {
        name ?? ""
    }

    var wrappedVersion: String {
        version ?? ""
    }

    var wrappedBundleIdentifier: String {
        bundleIdentifier ?? ""
    }

    var wrappedSource: String {
        source ?? ""
    }

    var wrappedInstalledPaths: String {
        installedPaths ?? ""
    }

    var wrappedLastOpenedAt: Date {
        lastOpenedAt ?? Date.now
    }

    var vulnerabilitiesArray: [CachedVulnerability] {
        let set = vulnerabilities as? Set<CachedVulnerability> ?? []

        return set.sorted {
            $0.wrappedCvePublished < $1.wrappedCvePublished
        }
    }

    var hostsArray: [CachedHost] {
        let set = hosts as? Set<CachedHost> ?? []

        return set.sorted {
            $0.wrappedComputerName < $1.wrappedComputerName
        }
    }

}

// MARK: Generated accessors for hosts
extension CachedSoftware {

    @objc(addHostsObject:)
    @NSManaged public func addToHosts(_ value: CachedHost)

    @objc(removeHostsObject:)
    @NSManaged public func removeFromHosts(_ value: CachedHost)

    @objc(addHosts:)
    @NSManaged public func addToHosts(_ values: NSSet)

    @objc(removeHosts:)
    @NSManaged public func removeFromHosts(_ values: NSSet)

}

// MARK: Generated accessors for vulnerabilities
extension CachedSoftware {

    @objc(addVulnerabilitiesObject:)
    @NSManaged public func addToVulnerabilities(_ value: CachedVulnerability)

    @objc(removeVulnerabilitiesObject:)
    @NSManaged public func removeFromVulnerabilities(_ value: CachedVulnerability)

    @objc(addVulnerabilities:)
    @NSManaged public func addToVulnerabilities(_ values: NSSet)

    @objc(removeVulnerabilities:)
    @NSManaged public func removeFromVulnerabilities(_ values: NSSet)

}

extension CachedSoftware: Identifiable {

}
