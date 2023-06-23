//
//  HostsView.swift
//  FleetSample
//
//  Created by Dale Ribeiro on 6/1/23.
//

//import SwiftUI
//
//struct HostsView: View {
//    @StateObject var viewModel = ViewModel()
//    var teamID: Int?
//    var filteredHosts: [Host] {
//        viewModel.hosts.filter { host in
//            host.teamId == teamID
//        }
//    }
//    @Environment(\.dismiss) var dismiss
//    
//    var body: some View {
//        NavigationStack {
//            List {
//                ForEach(filteredHosts) { host in
//                    NavigationLink {
//                        HostView(host: host)
//                    } label: {
//                        Text(host.computerName)
//                    }
//                }
//            }
//            .task {
//                if viewModel.hosts.isEmpty {
//                    await viewModel.fetchHosts()
//                }
//            }
//            .refreshable {
//                await viewModel.fetchHosts()
//            }
//            
//            .navigationTitle("Hosts")
//        }
//    }
//}
//
//struct HostsView_Previews: PreviewProvider {
//    static var previews: some View {
//        HostsView()
//    }
//}
