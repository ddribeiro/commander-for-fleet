//
//  CommandsView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/29/23.
//

import SwiftUI

struct CommandsView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        NavigationStack {
            if viewModel.sortedCommands.isEmpty {
                Text("No Commands")
                    .font(.title)
                    .foregroundStyle(.secondary)
            } else {
                Form {
                    ForEach(viewModel.sortedCommands, id: \.commandUuid) { command in
                        CommandRow(command: command)
                    }
                }
                
                .navigationTitle("Command History for \(viewModel.selectedHost?.computerName ?? "N/A")")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .task {
            await viewModel.fetchCommands()
        }
    }
}

struct CommandsView_Previews: PreviewProvider {
    static var previews: some View {
        CommandsView()
    }
}
