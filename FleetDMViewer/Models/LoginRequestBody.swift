//
//  LoginRequestBody.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/8/23.
//

import Foundation

struct LoginRequestBody: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    var token: String
}
