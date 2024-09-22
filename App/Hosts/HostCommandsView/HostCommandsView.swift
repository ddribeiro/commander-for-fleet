//
//  CommandsView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/29/23.
//

import SwiftUI
import KeychainWrapper

struct HostCommandsView: View {
    @EnvironmentObject var dataController: DataController

    @Environment(\.networkManager) var networkManager
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss

    let host: Host

    @State private var commands = [CommandResponse]()
    @State private var loadingState: LoadingState = .loaded

    var sortedCommands: [CommandResponse] {
        commands.sorted { $0.updatedAt > $1.updatedAt }
    }

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
                if let commandData = try? JSONEncoder().encode(commands) {
                    if let jsonString = String(data: commandData, encoding: .utf8) {
                        print("JSON string: \(jsonString)")

                        // Optionally, you can print the specific value at index 8595
                        if let jsonData = try? JSONSerialization.jsonObject(with: commandData, options: []),
                           let jsonArray = jsonData as? [[String: Any]],
                           jsonArray.indices.contains(8595) {
                            print("Problematic entry: \(jsonArray[8595])")
                        }
                    }
                }
                print(String(describing: error))
            }
        }
    }
}
