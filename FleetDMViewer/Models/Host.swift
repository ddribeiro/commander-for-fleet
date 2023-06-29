//
//  Host.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/8/23.
//

import Foundation

struct Host: Codable, Identifiable, Hashable {
    
    var software: [Software]?
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
    var percentDiskSpaceAvailable: Int
    var diskEncryptionEnabled: Bool?
    var status: String
    var policies: [Policy]?
    var mdm: Mdm?
    var batteries: [Battery]?
    

    
    static let example = Host(id: 1, lastEnrolledAt: .now, seenTime: .now, uuid: "6F6FADC0-6198-4FFB-8F5E-A8E8029754B4", osVersion: "macOS 13.4.0", uptime: 211905700000000, memory: 8589934592, cpuBrand: "Intel(R) Core(TM) i5-3230M CPU @ 2.60GHz", hardwareModel: "MacBookPro10,2", hardwareSerial: "C02ZW7EUMD6R", computerName: "Dale's iMac", publicIp: "67.245.225.133", primaryIp: "192.168.4.61", primaryMac: "54:26:96:ce:ec:c5", teamId: 9, gigsDiskSpaceAvailable: 202.66, percentDiskSpaceAvailable: 40, diskEncryptionEnabled: true, status: "Online", batteries: [.example])
}

struct Policy: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let critical: Bool
    let response: String
    
    static let example = Policy(id: 12, name: "Screen lock enabled (macOS) (All teams)", critical: false, response: "pass")
}


struct Battery: Codable, Hashable {
    var cycleCount: Int
    var health: String

    static let example = Battery(cycleCount: 643, health: "Normal")
}

struct Profile: Codable, Identifiable, Hashable {
    var profileId: Int
    var name: String
    var status: String
    var operationType: String
    var detail: String
    
    var id: Int {
        profileId
    }
    
    static let example = Profile(profileId: 841493, name: "Automatically Install App Updates", status: "verified", operationType: "install", detail: "")
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
    
    static let example = Software(id: 2089, name: "Safari.app", version: "16.5", source: "apps", vulnerabilities: [.example], installedPaths: ["/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app"], lastOpenedAt: .now)
}

struct Vulnerability: Codable, Hashable {
    var cve: String
    var detailsLink: String
    var cvssScore: Double?
    var epssProbability: Double
    var cisaKnownExploit: Bool
    var cvePublished: Date
    
    static let example = Vulnerability(cve: "CVE-2016-4613", detailsLink: "https://nvd.nist.gov/vuln/detail/CVE-2016-4613", epssProbability: 30.1, cisaKnownExploit: false, cvePublished: .now)
}

struct Mdm: Codable, Hashable {
    var enrollmentStatus: String?
    var serverUrl: String?
    var name: String
    var encryptionKeyAvailable: Bool
    var profiles: [Profile]?
    
    static let example = Mdm(enrollmentStatus: "On (manual)", serverUrl: "https://harmonize-stg.cloud.fleetdm.com/mdm/apple/mdm", name: "Fleet", encryptionKeyAvailable: true, profiles: [.example])
}
