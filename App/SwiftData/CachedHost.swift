//
//  CachedHost.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 1/8/24.
//
//

import Foundation
import SwiftData

@Model class CachedHost: Identifiable {
    var computerName: String
    var cpuBrand: String
    var diskEncryptionEnabled: Bool?
    var gigsDiskSpaceAvailable: Double
    var hardwareModel: String
    var hardwareSerial: String
    @Attribute(.unique) var id: Int
    var lastEnrolledAt: Date
    var memory: Int
    var osVersion: String
    var percentDiskSpaceAvailable: Int
    var platform: String
    var primaryIp: String
    var primaryMac: String
    var publicIp: String
    var seenTime: Date
    var status: String
    var teamId: Int
    var teamName: String
    var uptime: Int
    var uuid: String
    @Relationship(deleteRule: .cascade) var battery: CachedBattery?
    var commands: CachedCommandResponse?
    @Relationship(inverse: \CachedPolicy.hosts) var policies = [CachedPolicy]()
    @Relationship(inverse: \CachedProfile.hosts) var profiles =  [CachedProfile]()
    @Relationship(inverse: \CachedSoftware.hosts) var software = [CachedSoftware]()
    var team: CachedTeam?

    var formattedDate: String {
        let date: String = {
            if Calendar.current.isDateInToday(seenTime) {
                return String(localized: "Today")
            } else if Calendar.current.isDateInYesterday(seenTime) {
                return String(localized: "Yesterday")
            } else {
                return seenTime.formatted(date: .numeric, time: .omitted)
            }
        }()
        let time = seenTime.formatted(date: .omitted, time: .shortened)
        return "\(date), \(time)"
    }

    // swiftlint:disable:next line_length
    init(computerName: String, cpuBrand: String, diskEncryptionEnabled: Bool? = nil, gigsDiskSpaceAvailable: Double, hardwareModel: String, hardwareSerial: String, id: Int, lastEnrolledAt: Date, memory: Int, osVersion: String, percentDiskSpaceAvailable: Int, platform: String, primaryIp: String, primaryMac: String, publicIp: String, seenTime: Date, status: String, teamId: Int, teamName: String, uptime: Int, uuid: String, battery: CachedBattery? = nil, commands: CachedCommandResponse? = nil, team: CachedTeam? = nil) {
        self.computerName = computerName
        self.cpuBrand = cpuBrand
        self.diskEncryptionEnabled = diskEncryptionEnabled
        self.gigsDiskSpaceAvailable = gigsDiskSpaceAvailable
        self.hardwareModel = hardwareModel
        self.hardwareSerial = hardwareSerial
        self.id = id
        self.lastEnrolledAt = lastEnrolledAt
        self.memory = memory
        self.osVersion = osVersion
        self.percentDiskSpaceAvailable = percentDiskSpaceAvailable
        self.platform = platform
        self.primaryIp = primaryIp
        self.primaryMac = primaryMac
        self.publicIp = publicIp
        self.seenTime = seenTime
        self.status = status
        self.teamId = teamId
        self.teamName = teamName
        self.uptime = uptime
        self.uuid = uuid
        self.battery = battery
        self.commands = commands
        self.team = team
    }
}