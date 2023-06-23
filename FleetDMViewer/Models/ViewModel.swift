//
//  DataController.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/15/23.
//

import Foundation
import SwiftUI
import KeychainWrapper

@MainActor
class ViewModel: ObservableObject {
    
    enum HostPickerOptions: String, CaseIterable {
        case policies
        case software
        case profiles
        
        var readableValue: String {
            switch self {
            case .policies:
                return "Policies"
            case .software:
                return "Software"
            case .profiles:
                return "Profiles"
            }
        }
    }
    
    @Published var selectedTeam: Team?
    
    @Published var selectedHost: Host?
    
    @Published var teams = [Team]()
    @Published var hosts = [Host]()
    
    @Published var serverURL = ""
    @Published var emailAddress = ""
    @Published var password = ""
    
    @Published var showingAlert = false
    
    @Published var isShowingSignInSheet = true
    
    var filteredHosts: [Host] {
        hosts.filter { host in
            host.teamId == selectedTeam?.id
        }
    }
    
    @AppStorage("isAuthenticated") var isAuthenticated: Bool = false
    
    func saveCredentials() {
        KeychainWrapper.default.set(emailAddress, forKey: "emailAddress")
        KeychainWrapper.default.set(password, forKey: "password")
        teams = []
    }
    
    func validateServerURL(_ urlString: String) throws -> String  {
        guard !urlString.isEmpty else {
            throw URLError(.badURL)
        }
        
        guard let url = URL(string: urlString), url.scheme != nil else {
            let validatedURLString = "https://" + urlString
            KeychainWrapper.default.set(validatedURLString, forKey: "serverURL")
            return validatedURLString
            
        }
        KeychainWrapper.default.set(urlString, forKey: "serverURL")
        return urlString
    }
    
    func login(email: String, password: String) async throws {
        let environment = AppEnvironment(baseURL: URL(string: "\(try validateServerURL(serverURL))/api/v1/fleet/")!,
                                         session: {
            let configuration = URLSessionConfiguration.default
            return URLSession(configuration: configuration)
        }())
        
        let networkManager = NetworkManager(environment: environment)
        
        let credentials = LoginRequestBody(email: email, password: password)
        
        do {
            let response = try await networkManager.fetch(.loginResponse, with: JSONEncoder().encode(credentials))
            KeychainWrapper.default.set(response.token, forKey: "apiToken")
            
            isAuthenticated = true
            
        } catch {
            print(error.localizedDescription)
            showingAlert.toggle()
        }
    }
    
    func fetchTeams() async {
        guard let serverURL = KeychainWrapper.default.string(forKey: "serverURL") else {
            print("Could not get server URL")
            return
        }
        
        guard let apiToken = KeychainWrapper.default.string(forKey: "apiToken") else {
            print("Could not get API Key")
            return
        }
        
        let environment = AppEnvironment(baseURL: URL(string: "\(serverURL)/api/v1/fleet/")!,
                                         session: {
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = [
                "Authorization": "Bearer \(apiToken)"
            ]
            return URLSession(configuration: configuration)
        }())
        
        let networkManager = NetworkManager(environment: environment)
        
        do {
            teams = try await networkManager.fetch(.teams)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchHosts() async {
        guard let serverURL = KeychainWrapper.default.string(forKey: "serverURL") else {
            print("Could not get server URL")
            return
        }
        
        guard let apiToken = KeychainWrapper.default.string(forKey: "apiToken") else {
            print("Could not get API Key")
            return
        }
        
        let environment = AppEnvironment(baseURL: URL(string: "\(serverURL)/api/v1/fleet/")!,
                                         session: {
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = [
                "Authorization": "Bearer \(apiToken)"
            ]
            return URLSession(configuration: configuration)
        }())
        
        let networkManager = NetworkManager(environment: environment)
        
        do {
            hosts = try await networkManager.fetch(.hosts)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getHost(hostID: Int) async throws -> Host {
        let endpoint = Endpoint.gethost(id: hostID)
        
        guard let serverURL = KeychainWrapper.default.string(forKey: "serverURL") else {
            print("Could not get server URL")
            throw URLError(.badURL)
        }
        
        guard let apiToken = KeychainWrapper.default.string(forKey: "apiToken") else {
            print("Could not get API Key")
            throw URLError(.userAuthenticationRequired)
        }
        
        let environment = AppEnvironment(baseURL: URL(string: "\(serverURL)/api/v1/fleet/")!,
                                         session: {
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = [
                "Authorization": "Bearer \(apiToken)"
            ]
            return URLSession(configuration: configuration)
        }())
        
        let networkManager = NetworkManager(environment: environment)
        
        do {
            let host = try await networkManager.fetch(endpoint)
            return host
        } catch {
            print("here's the error")
            print(error.localizedDescription)
            throw error
        }
    }
}
