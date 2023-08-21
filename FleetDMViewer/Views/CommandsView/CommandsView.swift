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
    @State private var commands = [CommandResponse]()

    var body: some View {
        NavigationStack {
            if sortedCommands.isEmpty {
                Text("No Commands")
                    .font(.title)
                    .foregroundStyle(.secondary)
            } else {
                Form {
                    ForEach(sortedCommands, id: \.commandUuid) { command in
                        CommandRow(command: command)
                    }
                }

                .navigationTitle("Command History for \(dataController.selectedHost?.computerName ?? "N/A")")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .task {
            await fetchCommands()
        }
    }

    func fetchCommands() async {
        guard let serverURL = KeychainWrapper.default.string(forKey: "serverURL") else {
            print("Could not get server URL")
            return
        }

        let environment = AppEnvironment(baseURL: URL(string: "\(serverURL)")!)

        let networkManager = NetworkManager(environment: environment)

        do {
            commands = try await networkManager.fetch(.commands)
        } catch {
            print("Unable to fetch commands")
        }
    }

    var filteredCommands: [CommandResponse] {
        commands.filter { command in
            command.deviceId == dataController.selectedHost?.uuid
        }
    }

    var sortedCommands: [CommandResponse] {
        filteredCommands.sorted(by: {
            $0.updatedAt > $1.updatedAt
        })
    }
}

struct CommandsView_Previews: PreviewProvider {
    static var previews: some View {
        CommandsView()
    }
}
