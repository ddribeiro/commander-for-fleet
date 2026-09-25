//
//  Host.swift
//  Commander
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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        software = try container.decodeIfPresent([Software].self, forKey: .software)
        platform = try container.decodeIfPresent(String.self, forKey: .platform) ?? ""
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        lastEnrolledAt = try container.decodeIfPresent(Date.self, forKey: .lastEnrolledAt) ?? .distantPast
        seenTime = try container.decodeIfPresent(Date.self, forKey: .seenTime) ?? .distantPast
        uuid = try container.decodeIfPresent(String.self, forKey: .uuid) ?? ""
        osVersion = try container.decodeIfPresent(String.self, forKey: .osVersion) ?? ""
        uptime = try container.decodeIfPresent(Int.self, forKey: .uptime) ?? 0
        memory = try container.decodeIfPresent(Int.self, forKey: .memory) ?? 0
        cpuBrand = try container.decodeIfPresent(String.self, forKey: .cpuBrand) ?? ""
        hardwareModel = try container.decodeIfPresent(String.self, forKey: .hardwareModel) ?? ""
        hardwareSerial = try container.decodeIfPresent(String.self, forKey: .hardwareSerial) ?? ""
        computerName = try container.decodeIfPresent(String.self, forKey: .computerName) ?? ""
        publicIp = try container.decodeIfPresent(String.self, forKey: .publicIp) ?? ""
        primaryIp = try container.decodeIfPresent(String.self, forKey: .primaryIp) ?? ""
        primaryMac = try container.decodeIfPresent(String.self, forKey: .primaryMac) ?? ""
        teamId = try container.decodeIfPresent(Int.self, forKey: .teamId)
        gigsDiskSpaceAvailable = try container.decodeIfPresent(Double.self, forKey: .gigsDiskSpaceAvailable) ?? 0
        gigsTotalDiskSpace = try container.decodeIfPresent(Double.self, forKey: .gigsTotalDiskSpace) ?? 0
        percentDiskSpaceAvailable = try container.decodeIfPresent(Double.self, forKey: .percentDiskSpaceAvailable) ?? 0
        diskEncryptionEnabled = try container.decodeIfPresent(Bool.self, forKey: .diskEncryptionEnabled)
        status = try container.decodeIfPresent(String.self, forKey: .status) ?? ""
        policies = try container.decodeIfPresent([Policy].self, forKey: .policies)
        mdm = try container.decodeIfPresent(Mdm.self, forKey: .mdm)
        batteries = try container.decodeIfPresent([Battery].self, forKey: .batteries)
        teamName = try container.decodeIfPresent(String.self, forKey: .teamName)
    }

    // Explicit memberwise init, since defining `init(from:)` above removes the synthesized one.
    init(
        software: [Software]? = nil,
        platform: String = "",
        id: Int = 0,
        lastEnrolledAt: Date = .distantPast,
        seenTime: Date = .distantPast,
        uuid: String = "",
        osVersion: String = "",
        uptime: Int = 0,
        memory: Int = 0,
        cpuBrand: String = "",
        hardwareModel: String = "",
        hardwareSerial: String = "",
        computerName: String = "",
        publicIp: String = "",
        primaryIp: String = "",
        primaryMac: String = "",
        teamId: Int? = nil,
        gigsDiskSpaceAvailable: Double = 0,
        gigsTotalDiskSpace: Double = 0,
        percentDiskSpaceAvailable: Double = 0,
        diskEncryptionEnabled: Bool? = nil,
        status: String = "",
        policies: [Policy]? = nil,
        mdm: Mdm? = nil,
        batteries: [Battery]? = nil,
        teamName: String? = nil
    ) {
        self.software = software
        self.platform = platform
        self.id = id
        self.lastEnrolledAt = lastEnrolledAt
        self.seenTime = seenTime
        self.uuid = uuid
        self.osVersion = osVersion
        self.uptime = uptime
        self.memory = memory
        self.cpuBrand = cpuBrand
        self.hardwareModel = hardwareModel
        self.hardwareSerial = hardwareSerial
        self.computerName = computerName
        self.publicIp = publicIp
        self.primaryIp = primaryIp
        self.primaryMac = primaryMac
        self.teamId = teamId
        self.gigsDiskSpaceAvailable = gigsDiskSpaceAvailable
        self.gigsTotalDiskSpace = gigsTotalDiskSpace
        self.percentDiskSpaceAvailable = percentDiskSpaceAvailable
        self.diskEncryptionEnabled = diskEncryptionEnabled
        self.status = status
        self.policies = policies
        self.mdm = mdm
        self.batteries = batteries
        self.teamName = teamName
    }

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

    var iconName: String {
        switch platform {
        case "ios":
            return "iphone"
        case "ipados":
            return "ipad"
        default:
            return "laptopcomputer"
        }
    }

    var formattedDate: String {
        let date: String
        if Calendar.current.isDateInToday(seenTime) {
            date = String(localized: "Today")
        } else if Calendar.current.isDateInYesterday(seenTime) {
            date = String(localized: "Yesterday")
        } else {
            date = seenTime.formatted(date: .numeric, time: .omitted)
        }
        let time = seenTime.formatted(date: .omitted, time: .shortened)
        return "\(date), \(time)"
    }
}

struct Issue: Codable, Hashable {
    var failingPoliciesCount: Int

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        failingPoliciesCount = try container.decodeIfPresent(Int.self, forKey: .failingPoliciesCount) ?? 0
    }
}

struct Battery: Codable, Hashable {
    var cycleCount: Int
    var health: Double?
    var healthText: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cycleCount = try container.decodeIfPresent(Int.self, forKey: .cycleCount) ?? 0

        // Fleet reports health as either a 0.0–1.0 number (older versions)
        // or a string like "Normal" / "Service recommended". Accept both;
        // map the string to an approximate level so the gauge still works.
        if container.contains(.health) {
            if let raw = try? container.decodeIfPresent(String.self, forKey: .health) {
                healthText = raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : raw
                health = Self.healthLevel(from: raw)
            } else {
                health = try? container.decodeIfPresent(Double.self, forKey: .health)
            }
        }
    }

    private static func healthLevel(from raw: String) -> Double? {
        switch raw.lowercased() {
        case "normal", "good", "excellent", "ok":
            return 1.0
        case "fair":
            return 0.9
        case "poor", "service recommended", "needs service":
            return 0.75 // triggers the < 0.8 warning in the UI
        default:
            return nil // UI defaults to 1.0 (100%)
        }
    }

    init(cycleCount: Int = 0, health: Double? = nil, healthText: String? = nil) {
        self.cycleCount = cycleCount
        self.health = health
        self.healthText = healthText
    }

    static let example = Battery(
        cycleCount: 643,
        health: 0.95
    )
}

