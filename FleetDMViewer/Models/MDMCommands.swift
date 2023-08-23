//
//  MDMCommands.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/22/23.
//

import Foundation

struct CommandResponse: Codable {
    var deviceId: String
    var commandUuid: String
    var updatedAt: Date
    var requestType: String
    var status: String
    var hostname: String

    static let example = CommandResponse(
        deviceId: "A04F07D9-0AB0-5682-B99E-996F178A707E",
        commandUuid: "17269A1C-20F9-407F-9AD0-396B9DFA6596",
        updatedAt: .now,
        requestType: "DeviceLock",
        status: "Acknowledged",
        hostname: "Dalers-Super-Awesome-Vitual-Machine.local"
    )
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
