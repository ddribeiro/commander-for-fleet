//
//  LoginRequestBody.swift
//  Commander
//
//  Created by Dale Ribeiro on 6/8/23.
//

import Foundation

struct LoginRequestBody: Codable {
    let email: String
    let password: String
}

/// Response for the `/api/v1/fleet/login` endpoint.
/// All fields are optional in the Fleet API, so decode leniently.
struct LoginResponse: Codable {
    var user: User?
    var availableTeams: [Team]?
    var token: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        user = try container.decodeIfPresent(User.self, forKey: .user)
        availableTeams = try container.decodeIfPresent([Team].self, forKey: .availableTeams)
        token = try container.decodeIfPresent(String.self, forKey: .token)
    }

    init(user: User? = nil, availableTeams: [Team]? = nil, token: String? = nil) {
        self.user = user
        self.availableTeams = availableTeams
        self.token = token
    }
}
