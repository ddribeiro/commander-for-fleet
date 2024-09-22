//
//  MDMCommands.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/22/23.
//

import Foundation

struct CommandResponse: Codable, Identifiable {
    var id: String { commandUuid }
    var status: String
    var commandUuid: String
    var updatedAt: Date
    var requestType: String
    var hostname: String
    var hostUuid: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        commandUuid = try container.decode(String.self, forKey: .commandUuid)
        status = try container.decode(String.self, forKey: .status)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        requestType = try container.decode(String.self, forKey: .requestType)
        hostname = try container.decode(String.self, forKey: .hostname)
        hostUuid = try container.decode(String.self, forKey: .hostUuid)
    }

    enum CodingKeys: String, CodingKey {
        case status, commandUuid, updatedAt, requestType, hostname, hostUuid
    }
}

struct MdmCommand: Codable {
    var command: String
    var deviceIds: [String]
}

struct MdmCommandResponse: Codable {
    var commandUuid: String
    var requestType: String
}

// Struct for DeviceInformationCommand
struct DeviceInformationCommand: Codable {
    var command: Command
    var commandUUID = UUID().uuidString

    struct Command: Codable {
        var queries: [String]
        var requestType = "DeviceInformation"
        // swiftlint:disable:next nesting
        private enum CodingKeys: String, CodingKey {
            case queries = "Queries"
            case requestType = "RequestType"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case command = "Command"
        case commandUUID = "CommandUUID"
    }

}

// Struct for LockDeviceCommand
struct LockDeviceCommand: Codable {
    var command: Command
    var commandUUID = UUID().uuidString

    struct Command: Codable {
        var message: String?
        var phoneNumber: String?
        var pin: String?
        var requestRequiresNetworkTether: Bool?
        var requestType = "DeviceLock"

        // swiftlint:disable:next nesting
        private enum CodingKeys: String, CodingKey {
            case message = "Message"
            case phoneNumber = "PhoneNumber"
            case pin = "PIN"
            case requestRequiresNetworkTether = "RequestRequiresNetworkTether"
            case requestType = "RequestType"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case command = "Command"
        case commandUUID = "CommandUUID"
    }
}

// Struct for ShutDownDeviceCommand
struct ShutDownDeviceCommand: Codable {
    var command: Command
    var commandUUID = UUID().uuidString

    struct Command: Codable {
        var requestType = "ShutDownDevice"

        // swiftlint:disable:next nesting
        private enum CodingKeys: String, CodingKey {
            case requestType = "RequestType"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case command = "Command"
        case commandUUID = "CommandUUID"
    }
}

// Struct for RestartDeviceCommand
struct RestartDeviceCommand: Codable {
    var command: Command
    var commandUUID = UUID().uuidString

    struct Command: Codable {
        var requestType = "RestartDevice"

        // swiftlint:disable:next nesting
        private enum CodingKeys: String, CodingKey {
            case requestType = "RequestType"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case command = "Command"
        case commandUUID = "CommandUUID"
    }
}

// Struct for InstallApplicationCommand
struct InstallApplicationCommand: Codable {
    var command: Command
    var commandUUID = UUID().uuidString

    struct Command: Codable {
        var requestType = "InstallApplication"
        var manifestUrl: String
        var managementFlags = 0

        // swiftlint:disable:next nesting
        private enum CodingKeys: String, CodingKey {
            case requestType = "RequestType"
            case manifestUrl = "ManifestURL"
            case managementFlags = "ManagementFlags"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case command = "Command"
        case commandUUID = "CommandUUID"
    }
}
