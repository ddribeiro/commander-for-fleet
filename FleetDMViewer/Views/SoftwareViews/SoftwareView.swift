//
//  SoftwareView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/21/23.
//

import SwiftUI

struct SoftwareView: View {
    let software: [Software]
    var vulnerableSoftware: [Software] {
        software.filter { software in
            software.vulnerabilities != nil
        }
    }

    @State var isShowingVulnerableSoftware = false
    @State private var searchText = ""

    var body: some View {
        if software.isEmpty {
            ContentUnavailableView(
                "No Software",
                systemImage: "exclamationmark.triangle",
                description: Text("This host has no software.")
            )
        } else {
            Toggle("Only Show Software with Vulnerabilities", isOn: $isShowingVulnerableSoftware)
            ForEach(isShowingVulnerableSoftware ? vulnerableSoftware : software) { software in
                NavigationLink {
                    SoftwareDetailView(software: software)
                } label: {
                    SoftwareRow(software: software)
                }
            }
        }
    }
}

struct SoftwareView_Previews: PreviewProvider {
    static var previews: some View {
        SoftwareView(software: [.example])
    }
}
