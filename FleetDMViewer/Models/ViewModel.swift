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
    
    @Published var selectedTeam: Team?
    
    @Published var selectedHost: Host?
    
    @Published var teams = [Team]()
    @Published var hosts = [Host]()
    @Published var commands = [CommandResponse]()
    
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
    
    var filteredCommands: [CommandResponse] {
        commands.filter { command in
            command.deviceId == selectedHost?.uuid
        }
    }
    
    var sortedCommands: [CommandResponse] {
        filteredCommands.sorted(by: {
            $0.updatedAt > $1.updatedAt
        })
    }
    
    @AppStorage("isAuthenticated") var isAuthenticated: Bool = false
    
    let commandsSavePath = FileManager.documentsDirectory.appendingPathComponent("mdmcommands")
    
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
    
    func sendMDMCommand(command: MdmCommand) async throws {
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
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            
            _ = try await networkManager.fetch(.mdmCommand, with: encoder.encode(command))
        } catch {
            print("Could not send command")
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
    
    func fetchCommands() async {
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
            commands = try await networkManager.fetch(.commands)
        } catch {
            print("Unable to fetch commands")
        }
    }
    
    func generatebase64EncodedPlistData<T: Encodable>(from object: T) throws -> String {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        
        do {
            let plistData = try encoder.encode(object)
            return plistData.base64EncodedString().replacingOccurrences(of: "=", with: "")
        } catch {
            print("Error generating plist data: \(error)")
            return error.localizedDescription
        }
    }
    
    
//    private func saveCommands() {
//        do {
//            let data = try JSONEncoder().encode(mdmCommands)
//            try data.write(to: commandsSavePath, options: [.atomic, .completeFileProtection])
//        } catch {
//            print("Unable to save data")
//            print(error.localizedDescription)
//        }
//    }
//    
//    func addCommand(_ command: MdmCommandResponse) {
//        mdmCommands.append(command)
//        saveCommands()
//    }
    
    private func loadCommands() throws -> [MdmCommandResponse] {
        do {
            let data = try Data(contentsOf: commandsSavePath)
            return try JSONDecoder().decode([MdmCommandResponse].self, from: data)
        } catch {
            print("Unable to load commands")
            throw error
        }
    }
}
