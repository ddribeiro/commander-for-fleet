//
//  CachedUserTeam+CoreDataProperties.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 8/24/23.
//
//

import Foundation
import CoreData

extension CachedUserTeam {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedUserTeam> {
        return NSFetchRequest<CachedUserTeam>(entityName: "CachedUserTeam")
    }

    @NSManaged public var id: Int16
    @NSManaged public var name: String?
    @NSManaged public var teamDescription: String?
    @NSManaged public var user: CachedUser?

    var wrappedName: String {
        name ?? ""
    }

    var wrappedTeamDescription: String {
        teamDescription ?? ""
    }

}

extension CachedUserTeam: Identifiable {

}
