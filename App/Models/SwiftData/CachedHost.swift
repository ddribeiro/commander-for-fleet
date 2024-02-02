//
//  CachedHost.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 1/8/24.
//
//

import OSLog
import SwiftData

@Model class CachedHost {
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
    var battery: CachedBattery?
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

    init(
        computerName: String,
        cpuBrand: String,
        diskEncryptionEnabled: Bool? = nil,
        gigsDiskSpaceAvailable: Double,
        hardwareModel: String,
        hardwareSerial: String,
        id: Int,
        lastEnrolledAt: Date,
        memory: Int,
        osVersion: String,
        percentDiskSpaceAvailable: Int,
        platform: String,
        primaryIp: String,
        primaryMac: String,
        publicIp: String,
        seenTime: Date,
        status: String,
        teamId: Int,
        teamName: String,
        uptime: Int,
        uuid: String,
        battery: CachedBattery? = nil,
        commands: CachedCommandResponse? = nil,
        team: CachedTeam? = nil
    ) {
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

extension CachedHost {
    static func fetchHosts() async throws -> [Host] {
        guard await DataController().activeEnvironment != nil else { throw HTTPError.invalidURL }

        do {
            return try await NetworkManager(authManager: AuthManager()).fetch(.hosts, attempts: 5)
        } catch {
            throw error
        }
    }
}

extension CachedHost {
    convenience init(from host: Host) {
        self.init(
            computerName: host.computerName,
            cpuBrand: host.cpuBrand,
            gigsDiskSpaceAvailable: host.gigsDiskSpaceAvailable,
            hardwareModel: host.hardwareModel,
            hardwareSerial: host.hardwareSerial,
            id: host.id,
            lastEnrolledAt: host.lastEnrolledAt,
            memory: host.memory,
            osVersion: host.osVersion,
            percentDiskSpaceAvailable: host.percentDiskSpaceAvailable,
            platform: host.platform,
            primaryIp: host.primaryIp,
            primaryMac: host.primaryMac,
            publicIp: host.publicIp,
            seenTime: host.seenTime,
            status: host.status,
            teamId: host.teamId ?? 0,
            teamName: host.teamName ?? "",
            uptime: host.uptime,
            uuid: host.uuid
        )
    }
}

extension CachedHost {
    fileprivate static let logger = Logger(subsystem: "com.daleribeiro.FleetDMViewer", category: "parsing")

    @MainActor
    static func refresh(modelContext: ModelContext) async {
        do {
            logger.debug("Refreshing the data store for hosts...")
            let downloadedHosts = try await fetchHosts()
            logger.debug("Loaded: \(downloadedHosts.count) hosts")

            for host in downloadedHosts {
                let cachedHost = CachedHost(from: host)

                logger.debug("Inserting \(cachedHost.computerName)")
                modelContext.insert(cachedHost)
            }

            logger.debug("Refresh complete.")
        } catch {
            switch error as? AuthManager.AuthError {
            case .missingCredentials:
                let dataController = DataController()

                if !dataController.showingApiTokenAlert {
                    dataController.showingApiTokenAlert = true
                    dataController.alertTitle = "API Token Expired"
                    // swiftlint:disable:next line_length
                    dataController.alertDescription = "Your API Token has expired. Please provide a new one or sign out."
                }
            case .missingToken:
                print(error.localizedDescription)
            case .none:
                print(error.localizedDescription)
            }
        }
    }
}

extension CachedHost {
    static func predicate(
        searchText: String,
        filter: Filter,
        sortOptions: SortOptions
    ) -> Predicate<CachedHost> {
        if let team = filter.team {
            let teamID = team.id
            switch sortOptions.selectedSortStatus {
            case .all:
                return #Predicate<CachedHost> { host in
                    (searchText.isEmpty || host.computerName.localizedStandardContains(searchText))
                    &&
                    host.teamId == teamID
                }
            case .missing:
                let lastThirtyDays = Date.now.addingTimeInterval(86400 * -30)
                return #Predicate<CachedHost> { host in
                    (searchText.isEmpty || host.computerName.localizedStandardContains(searchText))
                    &&
                    host.seenTime < lastThirtyDays
                    &&
                    host.teamId == teamID
                }
            case .offline:
                return #Predicate<CachedHost> { host in
                    (searchText.isEmpty || host.computerName.localizedStandardContains(searchText))
                    &&
                    host.status == "offline"
                    &&
                    host.teamId == teamID
                }
            case .online:
                return #Predicate<CachedHost> { host in
                    (searchText.isEmpty || host.computerName.localizedStandardContains(searchText))
                    &&
                    host.status == "online"
                    &&
                    host.teamId == teamID
                }
            case .recentlyEnrolled:
                let lastSevenDays = Date.now.addingTimeInterval(86400 * -7)
                return #Predicate<CachedHost> { host in
                    (searchText.isEmpty || host.computerName.localizedStandardContains(searchText))
                    &&
                    host.lastEnrolledAt > lastSevenDays
                    &&
                    host.teamId == teamID
                }
            }

        } else {
            switch sortOptions.selectedSortStatus {
            case .all:
                return #Predicate<CachedHost> { host in
                    (searchText.isEmpty || host.computerName.localizedStandardContains(searchText))
                }
            case .missing:
                let lastThirtyDays = Date.now.addingTimeInterval(86400 * -30)
                return #Predicate<CachedHost> { host in
                    (searchText.isEmpty || host.computerName.localizedStandardContains(searchText))
                    &&
                    host.seenTime < lastThirtyDays
                }
            case .offline:
                return #Predicate<CachedHost> { host in
                    (searchText.isEmpty || host.computerName.localizedStandardContains(searchText))
                    && host.status == "offline"
                }
            case .online:
                return #Predicate<CachedHost> { host in
                    (searchText.isEmpty || host.computerName.localizedStandardContains(searchText))
                    && host.status == "online"
                }
            case .recentlyEnrolled:
                let lastSevenDays = Date.now.addingTimeInterval(86400 * -7)
                return #Predicate<CachedHost> { host in
                    (searchText.isEmpty || host.computerName.localizedStandardContains(searchText))
                    &&
                    host.lastEnrolledAt > lastSevenDays
                }
            }
        }
    }
}

extension CachedHost: Identifiable {}
