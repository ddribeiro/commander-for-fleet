//
//  TeamView.swift
//  FleetSample
//
//  Created by Dale Ribeiro on 5/30/23.
//

import SwiftUI

struct TeamsView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
            List(selection: $viewModel.selectedTeam) {
                ForEach(viewModel.teams) { team in
                    NavigationLink(value: team) {
                        Label(team.name, systemImage: "person.3")
                            .lineLimit(1)
                    }
                }
            }
            .task {
                if viewModel.teams.isEmpty {
                    await viewModel.fetchTeams()
                }
            }
            .refreshable {
                await viewModel.fetchTeams()
            }
            .navigationTitle("Teams")
    }
}

struct TeamView_Previews: PreviewProvider {
    static var previews: some View {
        TeamsView()
    }
}
