//
//  ProfilesView.swift
//  Commander
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
            List {
                ForEach(profiles) { profile in
                    HostProfilesRow(profile: profile)
                }
            }
            .listStyle(.insetGrouped)
        }
    }
}

#Preview {
    HostProfilesView(profiles: [.example, .example, .example])
}
