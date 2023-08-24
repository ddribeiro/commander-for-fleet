//
//  CachedMdm+CoreDataProperties.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 8/24/23.
//
//

import Foundation
import CoreData

extension CachedMdm {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedMdm> {
        return NSFetchRequest<CachedMdm>(entityName: "CachedMdm")
    }

    @NSManaged public var enrollmentStatus: String?
    @NSManaged public var serverUrl: String?
    @NSManaged public var name: String?
    @NSManaged public var encryptionKeyAvailable: Bool
    @NSManaged public var profiles: NSSet?
    @NSManaged public var host: CachedHost?

    var wrappedEnrollmentStatus: String {
        enrollmentStatus ?? ""
    }

    var wrappedServerUrl: String {
        serverUrl ?? ""
    }

    var wrappedName: String {
        name ?? ""
    }

    var profileArray: [CachedProfile] {
        let set = profiles as? Set<CachedProfile> ?? []

        return set.sorted {
            $0.wrappedName < $1.wrappedName
        }
    }

}

// MARK: Generated accessors for profiles
extension CachedMdm {

    @objc(addProfilesObject:)
    @NSManaged public func addToProfiles(_ value: CachedProfile)

    @objc(removeProfilesObject:)
    @NSManaged public func removeFromProfiles(_ value: CachedProfile)

    @objc(addProfiles:)
    @NSManaged public func addToProfiles(_ values: NSSet)

    @objc(removeProfiles:)
    @NSManaged public func removeFromProfiles(_ values: NSSet)

}

extension CachedMdm: Identifiable {

}
