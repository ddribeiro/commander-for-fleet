//
//  DetailColumn.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/29/23.
//

import SwiftUI

struct DetailColumn: View {
    @Binding var selection: Panel?
    @EnvironmentObject var dataController: DataController

    var body: some View {
        switch selection ?? .hosts {
        case .home:
            EmptyView()
        case .hosts:
            HostsView()
        case .controls:
            EmptyView()
        case .users:
            UsersView()
        case .queries:
            ContentUnavailableView(
                "Queries Coming Soon",
                systemImage: "rectangle.and.text.magnifyingglass",
                description: Text("Check back later for query support.")
            )
        case .policies:
            AllPoliciesView()
        case .software:
            AllSoftwareView()
        }
    }
}
