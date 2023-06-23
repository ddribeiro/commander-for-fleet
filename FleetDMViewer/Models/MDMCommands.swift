//
//  MDMCommands.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/22/23.
//

import Foundation

enum RequestType: String {
    case deviceLock = "DeviceLock"
    case eraseDevice = "EraseDevice"
    case restartDevice = "RestartDevice"
    case scheduleOSUpdate = "ScheduleOSUpdate"
    case deviceInformation = "DeviceInformation"
}

class MDMCommand {
    var requestType: RequestType
    var commandUUID: String
    
    init(requestType: RequestType, commandUUID: String) {
        self.requestType = requestType
        self.commandUUID = commandUUID
    }
}

class DeviceInformationCommand: MDMCommand, Encodable {
    var queries: [String]
    
    init(commandUUID: String, queries: [String]) {
        self.queries = queries
        super.init(requestType: .deviceInformation, commandUUID: commandUUID)
    }
}
