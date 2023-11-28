//
//  APITokenRefreshView.swift
//  FleetDMViewer
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
            VStack {
                Text("API Token Expired")
                    .font(.title)
                    .padding(.bottom)

                Text("Your API token has expired. Please create a new one and enter it below.")
                    .foregroundStyle(.secondary)
                    .font(.body)
                    .multilineTextAlignment(.center)

                SecureField("API Token", text: $dataController.apiTokenText)
                    .textFieldStyle(.roundedBorder)
                    .animation(.bouncy, value: showingErrorText)

                if showingErrorText {
                    Text("Your API Token was not accepted. Please try again.")
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Button {
                    let newToken = Token(value: dataController.apiTokenText, isValid: true)
                    KeychainWrapper.default.set(newToken, forKey: "apiToken")

                    Task {
                        do {
                            dataController.loadingState = .loaded
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
                    switch dataController.loadingState {
                    case .loading:
                        ProgressView()
                    case .loaded:
                        Text("Submit")
                    case .failed:
                        Text("Submit")
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)

                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
            .padding()
        }
}

#Preview {
    APITokenRefreshView()
}
