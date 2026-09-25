//
//  UserView.swift
//  Commander
//
//  Created by Dale Ribeiro on 11/30/23.
//

import SwiftUI

struct UserDetailView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.networkManager) var networkManager

    @State private var currentUser: User?

    var id: Int?

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

                if !user.teams.isEmpty {
                    Section("Teams") {
                        ForEach(user.teams) { team in
                            LabeledContent(team.name, value: team.role?.capitalized ?? "")
                        }
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
        guard dataController.activeEnvironment != nil, let id else { return }

        do {
            let meResponse = try await getUser(userID: id)
            currentUser = meResponse.user

            let assignedTeams: [Team]
            if let user = meResponse.user, user.teams.isEmpty {
                assignedTeams = meResponse.availableTeams ?? []
            } else {
                assignedTeams = meResponse.user?.teams ?? []
            }
            currentUser?.teams = assignedTeams

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

    func getUser(userID: Int) async throws -> MeResponse {
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
