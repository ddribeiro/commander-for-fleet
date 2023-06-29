//
//  MDMCommands.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/22/23.
//

import Foundation

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
        
        private enum CodingKeys: String, CodingKey {
            case requestType = "RequestType"
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case command = "Command"
        case commandUUID = "CommandUUID"
    }
}
