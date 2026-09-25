//
//  Software.swift
//  Commander
//
//  Created by Dale Ribeiro on 6/8/23.
//

import Foundation

struct Software: Codable, Identifiable, Hashable {
    var id: Int
    var name: String
    var version: String
    var bundleIdentifier: String?
    var source: String
    var vulnerabilities: [Vulnerability]?
    var installedPaths: [String]?
    var lastOpenedAt: Date?
    var hostsCount: Int?
    var versionsCount: Int?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        version = try container.decodeIfPresent(String.self, forKey: .version) ?? ""
        bundleIdentifier = try container.decodeIfPresent(String.self, forKey: .bundleIdentifier)
        source = try container.decodeIfPresent(String.self, forKey: .source) ?? ""
        vulnerabilities = try container.decodeIfPresent([Vulnerability].self, forKey: .vulnerabilities)
        // Fleet may include null entries; keep the [String] shape while dropping them.
        if let paths = try container.decodeIfPresent([String?].self, forKey: .installedPaths) {
            installedPaths = paths.compactMap { $0 }
        }
        lastOpenedAt = try container.decodeIfPresent(Date.self, forKey: .lastOpenedAt)
        hostsCount = try container.decodeIfPresent(Int.self, forKey: .hostsCount)
        versionsCount = try container.decodeIfPresent(Int.self, forKey: .versionsCount)
    }

    // Explicit memberwise init, since defining `init(from:)` above removes the synthesized one.
    init(id: Int, name: String, version: String = "", bundleIdentifier: String? = nil,
         source: String = "", vulnerabilities: [Vulnerability]? = nil,
         installedPaths: [String]? = nil, lastOpenedAt: Date? = nil,
         hostsCount: Int? = nil, versionsCount: Int? = nil) {
        self.id = id
        self.name = name
        self.version = version
        self.bundleIdentifier = bundleIdentifier
        self.source = source
        self.vulnerabilities = vulnerabilities
        self.installedPaths = installedPaths
        self.lastOpenedAt = lastOpenedAt
        self.hostsCount = hostsCount
        self.versionsCount = versionsCount
    }

    static let example = Software(
        id: 2089,
        name: "Safari.app",
        version: "16.5",
        source: "apps",
        vulnerabilities: [.example],
        installedPaths: ["/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app"],
        lastOpenedAt: .now,
        hostsCount: 2
    )
}

struct Vulnerability: Codable, Hashable {
    var cveDescription: String?
    var detailsLink: String
    var cvssScore: Double?
    var cvePublished: Date?
    var epssProbability: Double?
    var cisaKnownExploit: Bool?
    var cve: String
    var resolvedInVersion: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cveDescription = try container.decodeIfPresent(String.self, forKey: .cveDescription)
        detailsLink = try container.decodeIfPresent(String.self, forKey: .detailsLink) ?? ""
        cvssScore = try container.decodeIfPresent(Double.self, forKey: .cvssScore)
        cvePublished = try container.decodeIfPresent(Date.self, forKey: .cvePublished)
        epssProbability = try container.decodeIfPresent(Double.self, forKey: .epssProbability)
        cisaKnownExploit = try container.decodeIfPresent(Bool.self, forKey: .cisaKnownExploit)
        cve = try container.decodeIfPresent(String.self, forKey: .cve) ?? ""
        resolvedInVersion = try container.decodeIfPresent(String.self, forKey: .resolvedInVersion)
    }

    init(cveDescription: String? = nil, detailsLink: String = "", cvssScore: Double? = nil,
         cvePublished: Date? = nil, epssProbability: Double? = nil,
         cisaKnownExploit: Bool? = nil, cve: String = "", resolvedInVersion: String? = nil) {
        self.cveDescription = cveDescription
        self.detailsLink = detailsLink
        self.cvssScore = cvssScore
        self.cvePublished = cvePublished
        self.epssProbability = epssProbability
        self.cisaKnownExploit = cisaKnownExploit
        self.cve = cve
        self.resolvedInVersion = resolvedInVersion
    }

    static let example = Vulnerability(
        detailsLink: "https://nvd.nist.gov/vuln/detail/CVE-2016-4613",
        cvePublished: .now,
        epssProbability: 30.1,
        cisaKnownExploit: false,
        cve: "CVE-2016-4613"
    )
}
