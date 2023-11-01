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

    @EnvironmentObject var dataController: DataController
    @Environment(\.networkManager) var networkManager

    @State private var serverURL = ""
    @State private var emailAddress = ""
    @State private var password = ""

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
                            Task { @MainActor in
                                dataController.loadingState = .loading
                                try? await dataController.login(
                                    email: emailAddress,
                                    password: password,
                                    serverURL: serverURL,
                                    networkManager: networkManager
                                )

                                if dataController.loadingState == .loaded {
                                    dismiss()
                                }
                            }
                        } label: {
                            if dataController.loadingState == .loading {
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
                            dataController.loadingState = .loading
                            try await dataController.login(
                                email: emailAddress,
                                password: password,
                                serverURL: serverURL,
                                networkManager: networkManager
                            )

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
        .alert("Login Error", isPresented: $dataController.showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Incorrect username or password.")
        }
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
