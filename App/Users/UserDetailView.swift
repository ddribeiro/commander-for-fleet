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

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var users: FetchedResults<CachedUser>

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
                    LabeledContent("Email", value: user.wrappedEmail)
                    LabeledContent(
                        "Created At",
                        value: user.wrappedCreatedAt.formatted(
                            date: .abbreviated,
                            time: .shortened
                        )
                    )
                    if user.globalRole != nil {
                        LabeledContent("Global Role", value: user.wrappedGlobalRole.capitalized)
                    }
                }

                Section("Teams") {
                    ForEach(user.teamsArray) { team in
                        HStack {
                            Text(team.wrappedName)
                            Spacer()
                            if team.wrappedRole != "" {
                                Text(team.wrappedRole.capitalized)
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
            .refreshable {
                await updateUser()
            }
            .onReceive(didSave) { _ in
                refreshing.toggle()
            }
            .navigationTitle(user.wrappedName)
            .task {
                if user.teamsArray.isEmpty {
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
                        let cachedTeam = CachedTeam(context: moc)
                        cachedTeam.id = Int16(team.id)
                        cachedTeam.name = team.name

                        user.addToTeams(cachedTeam)
                    }
                }
                user.lastFetched = .now
                user.objectWillChange.send()
            }
            try? moc.save()
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
