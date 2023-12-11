//
//  CommandsView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/29/23.
//

import SwiftUI
import KeychainWrapper

struct CommandsView: View {
    @EnvironmentObject var dataController: DataController

    @Environment(\.networkManager) var networkManager
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss

    @FetchRequest var commands: FetchedResults<CachedCommandResponse>

    var body: some View {
        NavigationStack {
            List {
                ForEach(commands) { command in
                    CommandRow(command: command)
                }
            }
            .navigationTitle("Command History for \(dataController.selectedHost?.computerName ?? "N/A")")
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
            let commands = try await networkManager.fetch(.commands, attempts: 5)

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
    init(host: Host) {
        _commands = FetchRequest<CachedCommandResponse>(
            sortDescriptors: [
                SortDescriptor(
                    \.updatedAt,
                     order: .reverse
                )
            ],
            predicate: NSPredicate(
                format: "deviceID CONTAINS %@", host.uuid
            )
        )
    }

    func updateCache(with downloadedCommands: [CommandResponse]) {
        for downloadedCommand in downloadedCommands {
            let cachedCommand = CachedCommandResponse(context: moc)

            cachedCommand.status = downloadedCommand.status
            cachedCommand.commandUUID = downloadedCommand.commandUuid
            cachedCommand.deviceID = downloadedCommand.deviceId
            cachedCommand.updatedAt = downloadedCommand.updatedAt
            cachedCommand.requestType = downloadedCommand.requestType
            cachedCommand.hostname = downloadedCommand.hostname
        }
        try? moc.save()
    }
}
