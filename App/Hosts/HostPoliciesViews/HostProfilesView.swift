//
//  ProfilesView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/21/23.
//

import SwiftUI

struct HostProfilesView: View {
    var profiles: [Profile]

    var body: some View {
        if profiles.isEmpty {
            ContentUnavailableView(
                "No Profiles",
                systemImage: "exclamationmark.triangle",
                description: Text("This host has no profiles installed.")
            )
        } else {
            ForEach(profiles) { profile in
                HostProfilesRow(profile: profile)
            }
        }
    }
}

struct ProfilesView_Previews: PreviewProvider {
    static var previews: some View {
        HostProfilesView(profiles: [.example, .example, .example])
    }
}
