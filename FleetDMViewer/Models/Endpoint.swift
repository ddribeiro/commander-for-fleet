//
//  Endpoint.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/8/23.
//

import Foundation

struct Endpoint<T: Decodable> {
    var path: String
    var type: T.Type
    var method = HTTPMethod.get
    var headers = [String: String]()
    var keyPath: String?
    var id: Int?
}

extension Endpoint where T == LoginRequestBody {
    static let loginRequest = Endpoint(path: "login", type: LoginRequestBody.self, method: .post)
}
extension Endpoint where T == LoginResponse {
    static let loginResponse = Endpoint(path: "login", type: LoginResponse.self, method: .post, headers: ["Content-Type": "application/json"])
}

extension Endpoint where T == [Team] {
    static let teams = Endpoint(path: "teams", type: [Team].self, keyPath: "teams")
}

extension Endpoint where T == [Host] {
    static let hosts = Endpoint(path: "hosts", type: [Host].self, keyPath: "hosts")
}

extension Endpoint where T == Host {
    static func gethost(id: Int) -> Endpoint {
        return Endpoint(path: "hosts/\(id)", type: Host.self, keyPath: "host")
    }
}

extension Endpoint where T == User {
    static func getUser(id: Int) -> Endpoint {
        return Endpoint(path: "users/\(id)", type: User.self, keyPath: "user")
    }
    
    static let me = Endpoint(path: "me", type: User.self, keyPath: "user")
}

extension Endpoint where T == MdmCommandResponse {
    static let mdmCommand = Endpoint(path: "mdm/apple/enqueue", type: MdmCommandResponse.self, method: .post, headers: ["Content-Type": "application/json"])
}

extension Endpoint where T == [CommandResponse] {
    static let commands = Endpoint(path: "mdm/apple/commands", type: [CommandResponse].self, keyPath: "results")
}

enum HTTPMethod: String {
    case delete, get, patch, post, put
    
    var rawValue: String {
        String(describing: self).uppercased()
    }
}
