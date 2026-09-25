//
//  Policy.swift
//  Commander
//
//  Created by Dale Ribeiro on 11/20/23.
//

import Foundation

struct PolicyResponse: Codable {
    var policies: [Policy]?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        policies = try container.decodeIfPresent([Policy].self, forKey: .policies)
    }
}

struct Policy: Codable, Identifiable, Hashable {
    var id: Int
    var name: String
    var query: String
    var critical: Bool
    var description: String
    var authorId: Int
    var authorName: String
    var authorEmail: String
    var teamId: Int?
    var resolution: String
    var platform: String
    var createdAt: Date
    var updatedAt: Date
    var passingHostCount: Int?
    var failingHostCount: Int?
    var response: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        query = try container.decodeIfPresent(String.self, forKey: .query) ?? ""
        critical = try container.decodeIfPresent(Bool.self, forKey: .critical) ?? false
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        authorId = try container.decodeIfPresent(Int.self, forKey: .authorId) ?? 0
        authorName = try container.decodeIfPresent(String.self, forKey: .authorName) ?? ""
        authorEmail = try container.decodeIfPresent(String.self, forKey: .authorEmail) ?? ""
        teamId = try container.decodeIfPresent(Int.self, forKey: .teamId)
        resolution = try container.decodeIfPresent(String.self, forKey: .resolution) ?? ""
        platform = try container.decodeIfPresent(String.self, forKey: .platform) ?? ""
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? .distantPast
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? .distantPast
        passingHostCount = try container.decodeIfPresent(Int.self, forKey: .passingHostCount)
        failingHostCount = try container.decodeIfPresent(Int.self, forKey: .failingHostCount)
        response = try container.decodeIfPresent(String.self, forKey: .response)
    }

    // Explicit memberwise init, since defining `init(from:)` above removes the synthesized one.
    init(id: Int = 0, name: String = "", query: String = "", critical: Bool = false,
         description: String = "", authorId: Int = 0, authorName: String = "",
         authorEmail: String = "", teamId: Int? = nil, resolution: String = "",
         platform: String = "", createdAt: Date = .distantPast, updatedAt: Date = .distantPast,
         passingHostCount: Int? = nil, failingHostCount: Int? = nil, response: String? = nil) {
        self.id = id
        self.name = name
        self.query = query
        self.critical = critical
        self.description = description
        self.authorId = authorId
        self.authorName = authorName
        self.authorEmail = authorEmail
        self.teamId = teamId
        self.resolution = resolution
        self.platform = platform
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.passingHostCount = passingHostCount
        self.failingHostCount = failingHostCount
        self.response = response
    }

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
