//
//  TopLevelNavigationView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 4/5/25.
//

import SwiftUI

struct TopLevelNavigationView: View {
    var body: some View {
        NavigationLink(value: Panel.hosts) {
            Label("Hosts", systemImage: "laptopcomputer")
        }

//        NavigationLink(value: Panel.controls) {
//            Label("Controls", systemImage: "slider.horizontal.3")
//        }

//        NavigationLink(value: Panel.software) {
//            Label("Software", systemImage: "square.stack.3d.up")
//        }

        NavigationLink(value: Panel.queries) {
            Label("Queries", systemImage: "rectangle.and.text.magnifyingglass")
        }

        NavigationLink(value: Panel.policies) {
            Label("Policies", systemImage: "checkmark.seal")
        }
    }
}

#Preview {
    TopLevelNavigationView()
}
