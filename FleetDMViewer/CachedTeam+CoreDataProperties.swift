//
//  CachedTeam+CoreDataProperties.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 8/23/23.
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
    @NSManaged public var user: CachedUser?

    var wrappedName: String {
        name ?? ""
    }

}

extension CachedTeam: Identifiable {

}
