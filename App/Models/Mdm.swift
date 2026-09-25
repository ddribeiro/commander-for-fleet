//
//  Mdm.swift
//  Commander
//
//  Created by Dale Ribeiro on 6/8/23.
//

import Foundation

struct Profile: Codable, Identifiable, Hashable {
    var profileUuid: String
    var name: String
    var status: String
    var operationType: String
    var detail: String

    var id: String {
        profileUuid
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        profileUuid = try container.decodeIfPresent(String.self, forKey: .profileUuid) ?? ""
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        status = try container.decodeIfPresent(String.self, forKey: .status) ?? ""
        operationType = try container.decodeIfPresent(String.self, forKey: .operationType) ?? ""
        detail = try container.decodeIfPresent(String.self, forKey: .detail) ?? ""
    }

    init(profileUuid: String = "", name: String = "", status: String = "", operationType: String = "", detail: String = "") {
        self.profileUuid = profileUuid
        self.name = name
        self.status = status
        self.operationType = operationType
        self.detail = detail
    }

    static let example = Profile(
        profileUuid: UUID().uuidString,
        name: "Automatically Install App Updates",
        status: "verified",
        operationType: "install",
        detail: ""
    )
}

struct Mdm: Codable, Hashable {
    var enrollmentStatus: String?
    var serverUrl: String?
    var name: String
    var encryptionKeyAvailable: Bool
    var profiles: [Profile]?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        enrollmentStatus = try container.decodeIfPresent(String.self, forKey: .enrollmentStatus)
        serverUrl = try container.decodeIfPresent(String.self, forKey: .serverUrl)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        encryptionKeyAvailable = try container.decodeIfPresent(Bool.self, forKey: .encryptionKeyAvailable) ?? false
        profiles = try container.decodeIfPresent([Profile].self, forKey: .profiles)
    }

    init(enrollmentStatus: String? = nil, serverUrl: String? = nil, name: String = "",
         encryptionKeyAvailable: Bool = false, profiles: [Profile]? = nil) {
        self.enrollmentStatus = enrollmentStatus
        self.serverUrl = serverUrl
        self.name = name
        self.encryptionKeyAvailable = encryptionKeyAvailable
        self.profiles = profiles
    }

    static let example = Mdm(
        enrollmentStatus: "On (manual)",
        serverUrl: "https://harmonize-stg.cloud.fleetdm.com/mdm/apple/mdm",
        name: "Fleet",
        encryptionKeyAvailable: true,
        profiles: [.example]
    )
}
