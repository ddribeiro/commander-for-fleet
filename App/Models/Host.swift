//
//  Host.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/8/23.
//

import Foundation

struct Host: Codable, Identifiable, Hashable {

    var software: [Software]?
    var platform: String
    var id: Int
    var lastEnrolledAt: Date
    var seenTime: Date
    var uuid: String
    var osVersion: String
    var uptime: Int
    var memory: Int
    var cpuBrand: String
    var hardwareModel: String
    var hardwareSerial: String
    var computerName: String
    var publicIp: String
    var primaryIp: String
    var primaryMac: String
    var teamId: Int?
    var gigsDiskSpaceAvailable: Double
    var gigsTotalDiskSpace: Double
    var percentDiskSpaceAvailable: Double
    var diskEncryptionEnabled: Bool?
    var status: String
    var policies: [Policy]?
    var mdm: Mdm?
    var batteries: [Battery]?
    var teamName: String?

    static let example = Host(
        platform: "darwin",
        id: 1,
        lastEnrolledAt: .now,
        seenTime: .now,
        uuid: "6F6FADC0-6198-4FFB-8F5E-A8E8029754B4",
        osVersion: "macOS 13.4.0",
        uptime: 211905700000000,
        memory: 8589934592,
        cpuBrand: "Intel(R) Core(TM) i5-3230M CPU @ 2.60GHz",
        hardwareModel: "MacBookPro10,2",
        hardwareSerial: "C02ZW7EUMD6R",
        computerName: "Dale's iMac",
        publicIp: "67.245.225.133",
        primaryIp: "192.168.4.61",
        primaryMac: "54:26:96:ce:ec:c5",
        teamId: 9,
        gigsDiskSpaceAvailable: 202.66,
        gigsTotalDiskSpace: 511.12,
        percentDiskSpaceAvailable: 40,
        diskEncryptionEnabled: true,
        status: "Online",
        batteries: [.example],
        teamName: "Example Team Name"
    )
}

struct Issue: Codable, Hashable {
    var failingPoliciesCount: Int

}

struct Battery: Codable, Hashable {
    var cycleCount: Int
    var health: String

    static let example = Battery(
        cycleCount: 643,
        health: "Normal"
    )
}

struct Profile: Codable, Identifiable, Hashable {
    var profileUuid: String
    var name: String
    var status: String
    var operationType: String
    var detail: String

    var id: String {
        profileUuid
    }

    static let example = Profile(
        profileUuid: UUID().uuidString,
        name: "Automatically Install App Updates",
        status: "verified",
        operationType: "install",
        detail: ""
    )
}

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

    static let example = Vulnerability(
        detailsLink: "https://nvd.nist.gov/vuln/detail/CVE-2016-4613",
        cvePublished: .now,
        epssProbability: 30.1,
        cisaKnownExploit: false,
        cve: "CVE-2016-4613"
    )
}

struct Mdm: Codable, Hashable {
    var enrollmentStatus: String?
    var serverUrl: String?
    var name: String
    var encryptionKeyAvailable: Bool
    var profiles: [Profile]?

    static let example = Mdm(
        enrollmentStatus: "On (manual)",
        serverUrl: "https://harmonize-stg.cloud.fleetdm.com/mdm/apple/mdm",
        name: "Fleet",
        encryptionKeyAvailable: true,
        profiles: [.example]
    )
}

struct SearchToken: Identifiable {
    var id: String { name }
    var name: String
    var platform: [String]
}
