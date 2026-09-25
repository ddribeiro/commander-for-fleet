//
//  APITokenRefreshView.swift
//  Commander
//
//  Created by Dale Ribeiro on 11/28/23.
//

import KeychainWrapper
import SwiftUI

struct APITokenRefreshView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.networkManager) var networkManager
    @Environment(\.dismiss) var dismiss

    @State private var showingErrorText = false

    var body: some View {
        Form {
            Section {
                VStack(spacing: 8) {
                    Text("API Token Expired")
                        .font(.headline)

                    Text("Your API token has expired. Please create a new one and enter it below.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }

            Section("New API Token") {
                SecureField("API Token", text: $dataController.apiTokenText)
                    .animation(.bouncy, value: showingErrorText)
                
                if showingErrorText {
                    Text("Your API Token was not accepted. Please try again.")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    let newToken = Token(value: dataController.apiTokenText, isValid: true)
                    KeychainWrapper.default.set(newToken, forKey: "apiToken")

                    Task {
                        do {
                            dataController.loadingState = .loading
                            _ = try await networkManager.fetch(.meEndpoint)

                            dismiss()
                            dataController.loadingState = .loaded
                            dataController.apiTokenText = ""
                        } catch {
                            dataController.loadingState = .failed
                            showingErrorText = true
                        }
                    }
                } label: {
                    HStack {
                        Spacer()
                        if dataController.loadingState == .loading {
                            ProgressView()
                        } else {
                            Text("Submit")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .disabled(dataController.loadingState == .loading)
                
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    APITokenRefreshView()
        .environmentObject(
            DataController(networkManager: NetworkManager(authManager: AuthManager()))
        )
}
