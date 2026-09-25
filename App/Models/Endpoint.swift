//
//  Endpoint.swift
//  Commander
//
//  Created by Dale Ribeiro on 6/8/23.
//

import Foundation

struct Endpoint<T: Decodable> {
    var path: String
    var type: T.Type?
    var method = HTTPMethod.get
    var headers = [String: String]()
    var keyPath: String?
    var id: Int?
    var requiresAuth = true
}

extension Endpoint where T == LoginResponse {
    static let loginResponse = Endpoint(
        path: "/api/v1/fleet/login",
        type: LoginResponse.self,
        method: .post,
        headers: [
            "Content-Type": "application/json"
        ],
        requiresAuth: false
    )
}

extension Endpoint where T == [Team] {
    static let teams = Endpoint(
        path: "/api/v1/fleet/teams",
        type: [Team].self,
        keyPath: "teams"
    )
}

extension Endpoint where T == [Host] {
    static let hosts = Endpoint(
        path: "/api/v1/fleet/hosts",
        type: [Host].self,
        keyPath: "hosts"
    )

    static func getPassingHostsForPolicy(policyID: Int) -> Endpoint {
        return Endpoint(
            path: "/api/v1/fleet/hosts?policy_id=\(policyID)&policy_response=passing",
            type: [Host].self,
            keyPath: "hosts"
        )
    }

    static func getFailingHostsForPolicy(policyID: Int) -> Endpoint {
        return Endpoint(
            path: "/api/v1/fleet/hosts?policy_id=\(policyID)&policy_response=failing",
            type: [Host].self,
            keyPath: "hosts"
        )
    }

    static func getHostsForSoftware(softwareID: Int) -> Endpoint {
        return Endpoint(
            path: "/api/v1/fleet/hosts?software_id=\(softwareID)",
            type: [Host].self,
            keyPath: "hosts"
        )
    }
}

extension Endpoint where T == Host {
    static func getHost(id: Int) -> Endpoint {
        return Endpoint(
            path: "/api/v1/fleet/hosts/\(id)",
            type: Host.self,
            keyPath: "host"
        )
    }
}

/// Response for the `/api/v1/fleet/software/titles` endpoint.
struct SoftwareTitlesResponse: Codable {
    var softwareTitles: [Software]?
    var meta: Meta?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        softwareTitles = try container.decodeIfPresent([Software].self, forKey: .softwareTitles)
        meta = try container.decodeIfPresent(Meta.self, forKey: .meta)
    }
}

/// Pagination metadata from Fleet list endpoints.
struct Meta: Codable {
    var hasNextResults: Bool?
    var hasPreviousResults: Bool?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hasNextResults = try container.decodeIfPresent(Bool.self, forKey: .hasNextResults)
        hasPreviousResults = try container.decodeIfPresent(Bool.self, forKey: .hasPreviousResults)
    }
}

extension Endpoint where T == SoftwareTitlesResponse {
    static func softwareTitles(page: Int = 1, perPage: Int = 50, teamId: Int? = nil) -> Endpoint {
        var path = "/api/v1/fleet/software/titles?page=\(page)&per_page=\(perPage)"
        if let teamId {
            path += "&team_id=\(teamId)"
        }
        return Endpoint(
            path: path,
            type: SoftwareTitlesResponse.self
        )
    }
}

extension Endpoint where T == [User] {
    static let users = Endpoint(
        path: "/api/v1/fleet/users",
        type: [User].self,
        keyPath: "users"
    )
}

extension Endpoint where T == User {
    static let logout = Endpoint(
        path: "/api/v1/fleet/logout",
        method: .post
    )
}

extension Endpoint where T == PolicyResponse {
    static let globalPolicies = Endpoint(
        path: "/api/v1/fleet/global/policies",
        type: PolicyResponse.self
    )

    static func getTeamPolicies(id: Int) -> Endpoint {
        return Endpoint(
            path: "/api/v1/fleet/teams/\(id)/policies",
            type: PolicyResponse.self
        )
    }
}

extension Endpoint where T == MeResponse {
    static let meEndpoint = Endpoint(
        path: "/api/v1/fleet/me",
        type: MeResponse.self
    )

    static func getUser(id: Int) -> Endpoint {
        return Endpoint(
            path: "/api/v1/fleet/users/\(id)",
            type: MeResponse.self
        )
    }
}

extension Endpoint where T == MdmCommandResponse {
    static let mdmCommand = Endpoint(
        path: "/api/v1/fleet/commands/run",
        type: MdmCommandResponse.self,
        method: .post,
        headers: [
            "Content-Type": "application/json"
        ]
    )
}

extension Endpoint where T == [CommandResponse] {
    static func getCommands(for host: Host) -> Endpoint {
        return Endpoint(
            path: "/api/v1/fleet/commands?host_identifier=\(host.hardwareSerial)",
            type: [CommandResponse].self,
            keyPath: "results"
        )
    }

    static let commands = Endpoint(
        path: "/api/v1/fleet/commands",
        type: [CommandResponse].self,
        keyPath: "results"
    )
}

enum HTTPMethod: String {
    case delete, get, patch, post, put

    var rawValue: String {
        String(describing: self).uppercased()
    }
}
