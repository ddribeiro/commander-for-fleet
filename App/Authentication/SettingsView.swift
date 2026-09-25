//
//  SettingsView.swift
//  Commander
//
//  Created by Dale Ribeiro on 8/22/23.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataController: DataController
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss

    @State private var isSignOutAlertPresented = false

    var body: some View {
        NavigationStack {
            if let user = dataController.currentUser {
                Form {
                    Section {
                        HStack {
                            if user.gravatarUrl.isEmpty {
                                Image(systemName: "person.fill")
                                    .font(.system(.largeTitle, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.accentColor.gradient, in: Circle())
                            } else {
                                AsyncImage(url: URL(string: "\(user.gravatarUrl)?s=240")) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(Circle())
                                        .overlay {
                                            Circle()
                                                .stroke(.white, lineWidth: 2)
                                        }
                                        .shadow(radius: 7)

                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 60, height: 60)
                            }

                            VStack(alignment: .leading) {
                                Text(user.name)
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.medium)

                                Text(user.email)
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Section {
                        LabeledContent("Global Role", value: (user.globalRole ?? "").capitalized)
                        // swiftlint:disable:next line_length
                        LabeledContent("Created On", value: user.createdAt.formatted(date: .abbreviated, time: .omitted))
                    }

                    Section {
                        LabeledContent("Sign Out") {
                            Button("Sign Out", role: .destructive) {
                                isSignOutAlertPresented = true
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .labelsHidden()
                    }

                    if !user.teams.isEmpty {
                        Section {
                            ForEach(user.teams) { team in
                                Text(team.name)
                            }
                        } header: {
                            Text("Available Teams")
                        }
                    }
                }
                .formStyle(.grouped)
                .navigationTitle("My Account")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            } else {
                ContentUnavailableView {
                    Label("No User Found", systemImage: "person.crop.circle.badge.exclamationmark")
                } description: {
                    Text("No current user found. Please sign out and sign back in again.")
                } actions: {
                    Button("Sign Out", role: .destructive) {
                        isSignOutAlertPresented = true
                    }
                    .buttonStyle(.bordered)
                    .alert(isPresented: $isSignOutAlertPresented) {
                        signOutAlert
                    }
                }
            }
        }
        .alert(isPresented: $isSignOutAlertPresented) {
            signOutAlert
        }
    }

    private var signOutAlert: Alert {
        Alert(
            title: Text("Are you sure you want to sign out?"),
            primaryButton: .destructive(Text("Sign Out")) {
                Task {
                    await authService.signOut()
                }
                dismiss()
            },
            secondaryButton: .cancel()
        )
    }
}

#Preview {
    let dataController = DataController(networkManager: NetworkManager(authManager: AuthManager()))
    dataController.currentUser = .example
    return SettingsView()
        .environmentObject(dataController)
        .environmentObject(AuthService(
            authManager: AuthManager(),
            networkManager: dataController.networkManager,
            dataController: dataController
        ))
}
