//
//  LoginView.swift
//  FleetSample
//
//  Created by Dale Ribeiro on 5/22/23.
//

import KeychainWrapper
import SwiftUI

struct LoginView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @Environment(\.networkManager) var networkManager

    @EnvironmentObject var dataController: DataController

    @State private var serverURL = ""
    @State private var emailAddress = ""
    @State private var password = ""
    @State private var apiKey = ""

    @State private var useApiKey = false

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
                    if !useApiKey {
                    LabeledContent("Email Address") {
                        TextField("Email Address", text: $emailAddress)
                                .multilineTextAlignment(.trailing)
#if os(iOS)
                                .textContentType(!useApiKey ? .emailAddress : .password)
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
                    } else {
                        LabeledContent("API Token") {
                            SecureField("API Token", text: $apiKey)
                                .multilineTextAlignment(.trailing)
#if os(iOS)
                                .textContentType(.password)
                                .autocorrectionDisabled()
#endif
                        }
                    }
                    LabeledContent("Use API Token") {
                        Toggle("Use API Token", isOn: $useApiKey)
                            .labelsHidden()
                    }
                }

                Section {
                    LabeledContent("Sign In") {
                        Button {
                            Task {
                                dataController.loadingState = .loading
                                if !useApiKey {
                                    try await dataController.loginWithEmail(
                                        email: emailAddress,
                                        password: password,
                                        serverURL: serverURL,
                                        networkManager: networkManager
                                    )
                                } else {
                                    try await dataController.loginWithApiKey(
                                        apiKey: apiKey,
                                        serverURL: serverURL,
                                        networkManager: networkManager
                                    )
                                }

                                if dataController.loadingState == .loaded {
                                    dismiss()
                                }
                            }
                        } label: {
                            switch dataController.loadingState {
                            case .loading:
                                ProgressView()
                            case .loaded:
                                Text("Sign In")
                            case .failed:
                                Text("Sign In")
                            }
                        }
                        .disabled(!isFormValid)
                        .frame(maxWidth: .infinity)
                    }
                    .labelsHidden()
                }
            }
            .animation(.default, value: useApiKey)
            .formStyle(.grouped)
            .navigationTitle("Sign In")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            dataController.loadingState = .loading
                            if !useApiKey {
                                try await dataController.loginWithEmail(
                                    email: emailAddress,
                                    password: password,
                                    serverURL: serverURL,
                                    networkManager: networkManager
                                )
                            } else {
                                try await dataController.loginWithApiKey(
                                    apiKey: apiKey,
                                    serverURL: serverURL,
                                    networkManager: networkManager
                                )
                            }

                            if dataController.loadingState == .loaded {
                                dismiss()
                            }
                        }
                    } label: {
                        switch dataController.loadingState {
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
        .alert(dataController.alertTitle, isPresented: $dataController.showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(dataController.alertDescription)
        }
    }

    private var isFormValid: Bool {
        return (!serverURL.isEmpty && !emailAddress.isEmpty && !password.isEmpty) || (!serverURL.isEmpty && !apiKey.isEmpty)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(DataController())
    }
}
