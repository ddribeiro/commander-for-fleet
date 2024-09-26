//
//  UserView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/30/23.
//

import SwiftUI

struct UserDetailView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var dataController: DataController
    @Environment(\.networkManager) var networkManager
    
    @State private var currentUser: User?
    
    var id: Int
    
    var body: some View {
        if let user = currentUser {
            Form {
                Section {
                    LabeledContent("Email", value: user.email)
                    LabeledContent(
                        "Created At",
                        value: user.createdAt.formatted(
                            date: .abbreviated,
                            time: .shortened
                        )
                    )
                    
                    if let position = user.position {
                        LabeledContent("Position", value: position)
                    }
                    
                    if let globalRole = user.globalRole {
                        LabeledContent("Global Role", value: globalRole.capitalized)
                    }
                }
                
                Section("Teams") {
                    ForEach(user.teams) { team in
                        LabeledContent(team.name, value: team.role?.capitalized ?? "")
                    }
                }
            }
            .refreshable {
                await updateUser()
            }
            .navigationTitle(user.name)
        } else {
            ProgressView()
            Text("Loading")
                .font(.body.smallCaps())
                .foregroundColor(.secondary)
                .task {
                    await updateUser()
                }
        }
            
    }
    
    private func updateUser() async {
        guard dataController.activeEnvironment != nil else { return }
        
        do {
            
            let userReponse = try await getUser(userID: id)
            currentUser = userReponse.user
            
            if userReponse.user.teams.isEmpty {
                currentUser?.teams = userReponse.availableTeams
            } else {
                currentUser?.teams = userReponse.user.teams
            }
            
        } catch {
            switch error as? AuthManager.AuthError {
            case .missingCredentials:
                if !dataController.showingApiTokenAlert {
                    dataController.showingApiTokenAlert = true
                    dataController.alertTitle = "API Token Expired"
                    // swiftlint:disable:next line_length
                    dataController.alertDescription = "Your API Token has expired. Please provide a new one or sign out."
                }
            case .missingToken:
                print(error.localizedDescription)
            case .none:
                print(error.localizedDescription)
            }
        }
    }
    
    func getUser(userID: Int) async throws -> UserReponse {
        let endpoint = Endpoint.getUser(id: userID)
        
        do {
            let user = try await networkManager.fetch(endpoint, attempts: 5)
            return user
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
}
