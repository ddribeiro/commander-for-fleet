//
//  CachedPolicy.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 1/8/24.
//
//

import Foundation
import SwiftData


@Model class CachedPolicy: Identifiable {
    var authorEmail: String
    var authorId: Int
    var authorName: String
    var createdAt: Date
    var critical: Bool
    var failingHostCount: Int
    @Attribute(.unique) var id: Int
    var name: String
    var passingHostCount: Int
    var platform: String
    var policyDescription: String
    var query: String
    var resolution: String
    var response: String
    var teamId: Int?
    var updatedAt: Date
    var hosts: [CachedHost]?
    
    init(authorEmail: String, authorId: Int, authorName: String, createdAt: Date, critical: Bool, failingHostCount: Int, id: Int, name: String, passingHostCount: Int, platform: String, policyDescription: String, query: String, resolution: String, response: String, teamId: Int? = nil, updatedAt: Date, hosts: [CachedHost]? = nil) {
        self.authorEmail = authorEmail
        self.authorId = authorId
        self.authorName = authorName
        self.createdAt = createdAt
        self.critical = critical
        self.failingHostCount = failingHostCount
        self.id = id
        self.name = name
        self.passingHostCount = passingHostCount
        self.platform = platform
        self.policyDescription = policyDescription
        self.query = query
        self.resolution = resolution
        self.response = response
        self.teamId = teamId
        self.updatedAt = updatedAt
        self.hosts = hosts
    }
}
