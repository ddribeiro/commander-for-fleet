//
//  Errors.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/24/23.
//

import Foundation

enum TokenRefreshError: Error {
    case noCredentials
    case unexpectedError
}
