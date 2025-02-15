//
//  Endpoint.swift
//  FleetDMViewer
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

}

extension Endpoint where T == LoginRequestBody {
    static let loginRequest = Endpoint(path: "login", type: LoginRequestBody.self, method: .post)
}
extension Endpoint where T == LoginResponse {
    static let loginResponse = Endpoint(
        path: "/api/v1/fleet/login",
        type: LoginResponse.self,
        method: .post,
        headers: [
            "Content-Type": "application/json"
        ]
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
    
    static func getHostsforTeam(teamID: Int) -> Endpoint {
        return Endpoint(
            path: "/api/v1/fleet/hosts?team_id=\(teamID)",
            type: [Host].self,
            keyPath: "hosts"
        )
    }

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
    static func gethost(id: Int) -> Endpoint {
        return Endpoint(
            path: "/api/v1/fleet/hosts/\(id)",
            type: Host.self,
            keyPath: "host"
        )
    }
}

extension Endpoint where T == [Software] {
    static let software = Endpoint(
        path: "/api/v1/fleet/software",
        type: [Software].self,
        keyPath: "software"
    )

    static func getSoftwareForTeam(id: Int) -> Endpoint {
        return Endpoint(
            path: "/api/v1/fleet/software?team_id=\(id)",
            type: [Software].self,
            keyPath: "software"
        )
    }
}

extension Endpoint where T == [User] {
    static let users = Endpoint(
        path: "api/v1/fleet/users",
        type: [User].self,
        keyPath: "users"
    )
}

extension Endpoint where T == User {

    //    static let meEndpoint = Endpoint(
    //        path: "/api/v1/fleet/me",
    //        type: User.self,
    //        keyPath: "user"
    //    )

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

        extension Endpoint where T == UserReponse {
            static let meEndpoint = Endpoint(
                path: "/api/v1/fleet/me",
                type: UserReponse.self
            )

            static func getUser(id: Int) -> Endpoint {
                return Endpoint(
                    path: "/api/v1/fleet/users/\(id)",
                    type: UserReponse.self
                )
            }
        }

        extension Endpoint where T == MdmCommandResponse {
            static let mdmCommand = Endpoint(
                path: "/api/v1/fleet/mdm/apple/enqueue",
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
