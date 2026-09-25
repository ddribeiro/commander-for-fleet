//
//  LoginView.swift
//  Commander
//
//  Created by Dale Ribeiro on 5/22/23.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: AuthService

    @State private var serverURL = ""
    @State private var emailAddress = ""
    @State private var password = ""
    @State private var apiKey = ""

    @State private var useApiKey = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "lock.shield")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 64, height: 64)
                        .foregroundStyle(Color.accentColor)
                    
                    Text("Commander")
                        .font(.title.bold())
                }
                .padding(.top, 32)

                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Server URL")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField("https://fleet.example.com", text: $serverURL)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.URL)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                    }

                    if !useApiKey {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email Address")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("email@example.com", text: $emailAddress)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            SecureField("Password", text: $password)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.password)
                                .autocorrectionDisabled()
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("API Token")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            SecureField("API Token", text: $apiKey)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.password)
                                .autocorrectionDisabled()
                        }
                    }

                    Toggle("Use API Token", isOn: $useApiKey)
                        .toggleStyle(.button)
                        .tint(Color.accentColor)
                }
                .padding(.horizontal, 20)

                Button {
                    Task {
                        if !useApiKey {
                            try? await authService.login(
                                email: emailAddress,
                                password: password,
                                serverURL: serverURL
                            )
                        } else {
                            try? await authService.login(
                                apiKey: apiKey,
                                serverURL: serverURL
                            )
                        }
                        
                        if authService.loadingState == .loaded {
                            dismiss()
                        }
                    }
                } label: {
                    if authService.loadingState == .loading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Sign In")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!isFormValid || authService.loadingState == .loading)
                .padding(.horizontal, 20)
                
                if authService.error != nil {
                    Text(authService.error?.description ?? "")
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
        }
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }

    private var isFormValid: Bool {
        if useApiKey {
            return !serverURL.isEmpty && !apiKey.isEmpty
        } else {
            return !serverURL.isEmpty && !emailAddress.isEmpty && !password.isEmpty
        }
    }
}

#Preview {
    let dataController = DataController(networkManager: NetworkManager(authManager: AuthManager()))
    return LoginView()
        .environmentObject(AuthService(
            authManager: AuthManager(),
            networkManager: NetworkManager(authManager: AuthManager()),
            dataController: dataController
        ))
}
