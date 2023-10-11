//
//  LoginView.swift
//  FleetSample
//
//  Created by Dale Ribeiro on 5/22/23.
//

import KeychainWrapper
import SwiftUI

    enum LoadingState {
    case loading, loaded, failed
}

struct LoginView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataController: DataController

    @State private var serverURL = ""
    @State private var emailAddress = ""
    @State private var password = ""
    @State private var loadingState = LoadingState.loaded

    @State private var showingAlert = false

    @AppStorage("isAuthenticated") var isAuthenticated: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section {
                    LabeledContent("Server URL") {
                        TextField("FleetDM Server URL", text: $serverURL)

                            .multilineTextAlignment(.trailing)
#if os(iOS)
                            .textContentType(.URL)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
#endif
                            .labelsHidden()
                    }
                } header: {
                    Text("Sign in to your account")
                }

                Section {
                    LabeledContent("Email Address") {
                        TextField("Email Address", text: $emailAddress)
                            .multilineTextAlignment(.trailing)
#if os(iOS)
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
#endif
                    }

                    LabeledContent("Password") {
                        SecureField("Password", text: $password)
                            .multilineTextAlignment(.trailing)
                        #if os(iOS)
                            .textContentType(.password)
                            .autocorrectionDisabled()
                        #endif
                    }
                }

                Section {
                    LabeledContent("Sign In") {
                        Button {
                            Task {
                                loadingState = .loading
                                try await login(email: emailAddress, password: password)
                            }
                        } label: {
                            if loadingState == .loading {
                                ProgressView()
                            } else {
                                Text("Sign In")
                            }
                        }
                        .disabled(!isFormValid)
                        .frame(maxWidth: .infinity)
                    }
                    .labelsHidden()
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Sign In")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            loadingState = .loading
                            try await login(email: emailAddress, password: password)
                        }
                    } label: {
                        switch loadingState {
                        case .loading:
                            ProgressView()
                        case .loaded:
                            Text("Sign In")
                        case .failed:
                            Text("Sign In")
                        }
                    }
                    .disabled(!isFormValid)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        print("Canceled sign in.")
                        dismiss()
                    }
                }
            }
        }
        .alert("Login Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Incorrect username or password.")
        }
    }

    private func login(email: String, password: String) async throws {
        let environment = AppEnvironment(
            baseURL: URL(
                string: "\(try validateServerURL(serverURL))"
            )!
        )

        dataController.saveActiveEnvironment(environment: environment)

        let networkManager = NetworkManager()

        let credentials = LoginRequestBody(email: email, password: password)

        do {
            let response = try await networkManager.fetch(.loginResponse, with: JSONEncoder().encode(credentials))
            KeychainWrapper.default.set(response.token, forKey: "apiToken")
            let user = response.user
            let teams = response.availableTeams

            dataController.deleteAll()

            await MainActor.run {
                updateCache(with: user, downloadedTeams: teams)
            }

            loadingState = .loaded
            AppEnvironments().addEnvironment(environment)
            dataController.activeEnvironment = environment
            dismiss()
            isAuthenticated = true
        } catch {
            loadingState = .failed
            print(error.localizedDescription)
            showingAlert.toggle()
        }
    }

    func updateCache(with downloadedUser: User, downloadedTeams: [Team]) {
        let cachedUser = CachedUser(context: moc)

        cachedUser.createdAt = downloadedUser.createdAt
        cachedUser.updatedAt = downloadedUser.updatedAt
        cachedUser.id = Int16(downloadedUser.id)
        cachedUser.name = downloadedUser.name
        cachedUser.email = downloadedUser.email
        cachedUser.globalRole = downloadedUser.globalRole
        cachedUser.gravatarUrl = downloadedUser.gravatarUrl
        cachedUser.ssoEnabled = downloadedUser.ssoEnabled
        cachedUser.apiOnly = downloadedUser.apiOnly

        for team in downloadedTeams {
            let cachedTeam = CachedUserTeam(context: moc)
            cachedTeam.id = Int16(team.id)
            cachedTeam.name = team.name
            cachedTeam.teamDescription = team.description

            cachedUser.addToUserTeams(cachedTeam)
        }

        try? moc.save()
    }

    func validateServerURL(_ urlString: String) throws -> String {
        guard !urlString.isEmpty else {
            throw URLError(.badURL)
        }

        guard let url = URL(string: urlString), url.scheme != nil else {
            let validatedURLString = "https://" + urlString
            return validatedURLString

        }
        return urlString
    }

    private var isFormValid: Bool {
        return !serverURL.isEmpty && !emailAddress.isEmpty && !password.isEmpty
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(DataController())
    }
}
