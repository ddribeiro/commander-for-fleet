//
//  ContentView2.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/15/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        if viewModel.isAuthenticated {
    
            List(selection: $viewModel.selectedHost) {
                ForEach(viewModel.selectedTeam != nil ? viewModel.filteredHosts : viewModel.hosts) { host in
                    HostRow(host: host)
                }
            }
            .refreshable {
                await viewModel.fetchHosts()
            }
            .task {
                await viewModel.fetchHosts()
            }
            .navigationTitle(viewModel.selectedTeam?.name ?? "Hosts")
        } else {
            NoHostView()
                .sheet(isPresented: $viewModel.isShowingSignInSheet) {
                    LoginView()
                }
                .onAppear {
                    viewModel.isShowingSignInSheet = true
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
