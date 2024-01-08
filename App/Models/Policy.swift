//
//  Queries.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/20/23.
//

import Foundation

struct PolicyResponse: Codable {
    var policies: [Policy]?
}

struct Policy: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let query: String
    let critical: Bool
    let description: String
    let authorId: Int
    let authorName: String
    let authorEmail: String
    let teamId: Int?
    let team: String?
    let resolution: String
    let platform: String
    let createdAt: Date
    let updatedAt: Date
    let passingHostCount: Int?
    let failingHostCount: Int?
    let response: String?

    static let example = Policy(
        id: 29,
        name: "Full disk encryption enabled (macOS) (harmonize-dev/mdm_instance/default)",
        query: "SELECT 1 FROM disk_encryption WHERE user_uuid IS NOT '' AND filevault_status = 'on' LIMIT 1;",
        critical: false,
        description: "Checks to make sure that full disk encryption (FileVault) is enabled on macOS devices.",
        authorId: 3,
        authorName: "Dale Ribeiro",
        authorEmail: "dale@harmonize.io",
        teamId: 35,
        team: "Harmonize",
        // swiftlint:disable:next line_length
        resolution: "To enable full disk encryption, on the failing device, select System Preferences > Security & Privacy > FileVault > Turn On FileVault.",
        platform: "darwin",
        createdAt: .distantPast,
        updatedAt: .now,
        passingHostCount: 1,
        failingHostCount: 0,
        response: "fail"
    )
}
