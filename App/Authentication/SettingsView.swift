//
//  MeView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 8/22/23.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.networkManager) var networkManager
    @Environment(\.dismiss) var dismiss

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var users: FetchedResults<CachedUser>

    @State private var isSignOutAlertPresented = false

    var body: some View {
        NavigationView {
            if let savedUserID = UserDefaults.standard.value(forKey: "loggedInUserID") as? Int16 {
                if let user = users.first(where: { $0.id == savedUserID}) {
                    Form {
                        Section {
                            HStack {
                                if user.wrappedGravatarUrl.isEmpty {
                                    Image(systemName: "person.fill")
                                        .font(.system(.largeTitle, design: .rounded))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(width: 60, height: 60)
                                        .background(Color.accentColor.gradient, in: Circle())
                                } else {
                                    AsyncImage(url: URL(string: "\(user.wrappedGravatarUrl)?s=240")) { image in
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
                                    Text(user.wrappedName)
                                        .font(.system(.title3, design: .rounded))
                                        .fontWeight(.medium)

                                    Text(user.wrappedEmail)
                                        .font(.system(.subheadline, design: .rounded))
                                        .fontWeight(.medium)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        Section {
                            LabeledContent("Global Role", value: user.wrappedGlobalRole.capitalized)
                            // swiftlint:disable:next line_length
                            LabeledContent("Created On", value: user.wrappedCreatedAt.formatted(date: .abbreviated, time: .omitted))
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

                        Section {
                            ForEach(user.teamsArray) { team in
                                Text(team.wrappedName)
                            }
                        } header: {
                            Text("Available Teams")
                        }
                    }
                    .formStyle(.grouped)
                    .navigationTitle("My Account")
//                    .task {
//                        if UserDefaults.standard.value(forKey: "loggedInUserID") as? Int16 == nil {
//                            let response = try await networkManager.fetch(.meEndpoint)
//                            
//                        }
//                    }
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                dismiss()
                            }
                        }
                    }
                    .alert(isPresented: $isSignOutAlertPresented) {
                        signOutAlert
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

    }

//    func getMeInfo() async {
//        guard dataController.activeEnvironment != nil else { return }
//
//        do {
//            let response = try await networkManager.fetch(.meEndpoint)
//            let user = response.user
//            let teams = response.availableTeams
//
//            UserDefaults.standard.setValue(user.id, forKey: "loggedInUserID")
//        } catch {
//            switch error as? AuthManager.AuthError {
//            case .missingCredentials:
//                dataController.loadingState = .failed
//                if !dataController.showingApiTokenAlert {
//                    dataController.showingApiTokenAlert = true
//                    dataController.alertTitle = "API Token Expired"
//                    dataController.alertDescription = "Your API Token has expired. Please provide a new one or sign out."
//                }
//            case .missingToken:
//                dataController.loadingState = .failed
//                print(error.localizedDescription)
//            case .none:
//                dataController.loadingState = .failed
//                print(error.localizedDescription)
//            }
//        }
//    }

    private var signOutAlert: Alert {
        Alert(
            title: Text("Are you sure you want to sign out?"),
            primaryButton: .destructive(Text("Sign Out")) {
                Task {
                    await dataController.signOut()
                }
                dismiss()
            },
            secondaryButton: .cancel()
        )
    }

}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
