//
//  CommandsView.swift
//  Commander
//
//  Created by Dale Ribeiro on 6/29/23.
//

import SwiftUI

struct HostCommandsView: View {
    @EnvironmentObject var dataController: DataController

    @Environment(\.networkManager) var networkManager
    @Environment(\.dismiss) var dismiss

    let host: Host

    @State private var commands = [CommandResponse]()
    @State private var loadingState: LoadingState = .loaded

    var body: some View {
        NavigationStack {
            if loadingState == .loading {
                VStack {
                    ProgressView()
                    Text("Loading Command History...")
                        .foregroundStyle(.secondary)
                }
                .navigationTitle("Command History for \(host.computerName)")
#if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
#endif
            } else if loadingState == .failed {
                ContentUnavailableView("Failed to Load History", systemImage: "exclamationmark.triangle")
                    .navigationTitle("Command History for \(host.computerName)")
#if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
#endif
            } else {
                List {
                    ForEach(commands) { command in
                        HostCommandRow(command: command)
                    }
                }
                .navigationTitle("Command History for \(host.computerName)")
#if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
#endif
                .overlay {
                    if commands.isEmpty {
                        ContentUnavailableView("No Commands Found", systemImage: "xmark.icloud")

                    }
                }

                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done", role: .cancel) {
                            dismiss()
                        }
                    }
                }

                .sheet(isPresented: $dataController.showingApiTokenAlert) {
                    APITokenRefreshView()
                        .presentationDetents([.medium])
                }
            }
        }
        .task {
            await fetchCommands()
        }
    }

    func fetchCommands() async {
        guard dataController.activeEnvironment != nil else { return }

        do {
            loadingState = .loading

            let commandsForHostEndpoint = Endpoint.getCommands(for: host)
            commands = try await networkManager.fetch(commandsForHostEndpoint)
            loadingState = .loaded
        } catch {
            loadingState = .failed
            switch error as? AuthManager.AuthError {
            case .missingCredentials:
                if !dataController.showingApiTokenAlert {
                    dataController.showingApiTokenAlert = true
                    dataController.alertTitle = "API Token Expired"
                    // swiftlint:disable:next line_length
                    dataController.alertDescription = "Your API Token has expired. Please provide a new one or sign out."
                }
            case .missingToken:
                print(error)
            case .none:
                print("Failed to fetch command history: \(error.localizedDescription)")
            }
        }
    }
}
