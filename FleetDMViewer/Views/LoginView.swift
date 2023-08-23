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
                            .textContentType(.URL)
                            .multilineTextAlignment(.trailing)
#if os(iOS)

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
                            .textContentType(.emailAddress)
                            .multilineTextAlignment(.trailing)
#if os(iOS)

                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
#endif
                    }

                    LabeledContent("Password") {
                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .multilineTextAlignment(.trailing)
                            .autocorrectionDisabled()
                    }
                }

                Section {
                    LabeledContent("Sign In") {
                        Button("Sign In") {
                            Task {
                                loadingState = .loading
                                try await login(email: emailAddress, password: password)
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

        let networkManager = NetworkManager(environment: environment)

        let credentials = LoginRequestBody(email: email, password: password)

        do {
            let response = try await networkManager.fetch(.loginResponse, with: JSONEncoder().encode(credentials))
            KeychainWrapper.default.set(response.token, forKey: "apiToken")
            let user = response.user
            dataController.currentUser?.teams = response.availableTeams

            await MainActor.run {
                updateCache(with: user)
            }

            loadingState = .loaded
            isAuthenticated = true
            AppEnvironments().addEnvironment(environment)
            dataController.activeEnvironment = environment
            dismiss()
        } catch {
            loadingState = .failed
            print(error.localizedDescription)
            showingAlert.toggle()
        }
    }

    func updateCache(with downloadedUser: User) {
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

        try? moc.save()
    }

    func validateServerURL(_ urlString: String) throws -> String {
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
