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

    @FetchRequest(sortDescriptors: [SortDescriptor(\.updatedAt, order: .reverse)]) var commands: FetchedResults<CachedCommandResponse>

    var body: some View {
        NavigationStack {
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

                }
            }
            .task {
                await fetchCommands()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", role: .cancel) {
                        dismiss()

                    }
                }
            }
        }
        .sheet(isPresented: $dataController.showingApiTokenAlert) {
            APITokenRefreshView()
                .presentationDetents([.medium])
        }
        .task {
            await fetchCommands()
        }

    }

    func fetchCommands() async {
        guard dataController.activeEnvironment != nil else { return }

        do {
            let commandsForHostEndpoint = Endpoint.getCommands(for: host)
            let commands = try await networkManager.fetch(commandsForHostEndpoint)

            await MainActor.run {
                updateCache(with: commands)
            }
        } catch {
            switch error as? AuthManager.AuthError {
            case .missingCredentials:
                if !dataController.showingApiTokenAlert {
                    dataController.showingApiTokenAlert = true
                    dataController.alertTitle = "API Token Expired"
                    // swiftlint:disable:next line_length
                    dataController.alertDescription = "Your API Token has expired. Please provide a new one or sign out."
                }
            case .missingToken:
                print(error.localizedDescription)
            case .none:
                print(error.localizedDescription)
            }
        }
    }

    func updateCache(with downloadedCommands: [CommandResponse]) {
        for downloadedCommand in downloadedCommands {
            let cachedCommand = CachedCommandResponse(context: moc)

            cachedCommand.status = downloadedCommand.status
            cachedCommand.commandUUID = downloadedCommand.commandUuid
            cachedCommand.hostUUID = downloadedCommand.hostUuid
            cachedCommand.updatedAt = downloadedCommand.updatedAt
            cachedCommand.requestType = downloadedCommand.requestType
            cachedCommand.hostname = downloadedCommand.hostname
        }
        try? moc.save()
    }
}
