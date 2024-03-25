//
//  UserView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/30/23.
//

import SwiftUI

struct UserDetailView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var dataController: DataController
    @Environment(\.networkManager) var networkManager

    @State private var downloadedUser: UserReponse?
    @State private var updatedUser: CachedUser?
    @State private var teams: [Team]?
    @State private var refreshing: Bool = false

    var user: CachedUser

    var didSave =  NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)

    var body: some View {
        if refreshing || !refreshing {
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
                    if let globalRole = user.globalRole {
                        LabeledContent("Global Role") {
                            Text(globalRole.capitalized)
                        }
                    }
                }

                if !user.teams.isEmpty {
                    Section("Teams") {
                        ForEach(user.teams) { team in
                            HStack {
                                Text(team.name)
                                Spacer()
                                if team.role != "" && team.role != nil {
                                    Text(team.role?.capitalized ?? "")
                                        .font(.smallCaps(.body)())
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 8)
                                        .background(.tertiary)
                                        .clipShape(.capsule)
                                }
                            }
                        }
                    }
                }
            }
            .refreshable {
                await updateUser()
            }
            .onReceive(didSave) { _ in
                refreshing.toggle()
            }
            .navigationTitle(user.name)
            .task {
                if user.teams.isEmpty {
                    Task {
                        await updateUser()
                    }
                }
            }
        }
    }

        private func updateCachedUserData() {
            if let downloadedUser = downloadedUser {
                if downloadedUser.user.teams.isEmpty {
                    for team in downloadedUser.availableTeams {
                        let cachedTeam = CachedTeam(id: team.id, name: team.name)

                        user.teams.append(cachedTeam)
                    }
                }
                user.lastFetched = .now
                modelContext.insert(user)
            }
        }

        private func updateUser() async {
            guard dataController.activeEnvironment != nil else { return }

            do {

                downloadedUser = try await getUser(userID: Int(user.id))
                if let downloadedUser = downloadedUser {
                    teams = downloadedUser.availableTeams
                }

                await MainActor.run {
                    updateCachedUserData()
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
