//
//  SoftwareView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/21/23.
//

import SwiftUI

struct SoftwareView: View {

    @State private var isShowingVulnerableSoftware = false
    let software: [Software]

    var vulnerableSoftware: [Software] {
        software.filter { software in
            software.vulnerabilities != nil
        }
    }

    var body: some View {
        Toggle("Only Show Software with Vulnerabilities", isOn: $isShowingVulnerableSoftware)
        ForEach(isShowingVulnerableSoftware ? vulnerableSoftware : software) { software in
            NavigationLink {
                HostSoftwareDetailView(software: software)
            } label: {
                SoftwareRow(software: software)
            }
        }
    }
}
