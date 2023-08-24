//
//  CachedSoftware+CoreDataProperties.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 8/24/23.
//
//

import Foundation
import CoreData

extension CachedSoftware {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedSoftware> {
        return NSFetchRequest<CachedSoftware>(entityName: "CachedSoftware")
    }

    @NSManaged public var id: Int16
    @NSManaged public var name: String?
    @NSManaged public var version: String?
    @NSManaged public var bundleIdentifier: String?
    @NSManaged public var source: String?
    @NSManaged public var installedPaths: String?
    @NSManaged public var lastOpenedAt: Date?
    @NSManaged public var vulnerabilities: NSSet?
    @NSManaged public var host: CachedHost?

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

}

// MARK: Generated accessors for vulnerability
extension CachedSoftware {

    @objc(addVulnerabilityObject:)
    @NSManaged public func addToVulnerability(_ value: CachedVulnerability)

    @objc(removeVulnerabilityObject:)
    @NSManaged public func removeFromVulnerability(_ value: CachedVulnerability)

    @objc(addVulnerability:)
    @NSManaged public func addToVulnerability(_ values: NSSet)

    @objc(removeVulnerability:)
    @NSManaged public func removeFromVulnerability(_ values: NSSet)

}

extension CachedSoftware: Identifiable {

}
