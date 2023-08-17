//
//  ProfilesView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/21/23.
//

import SwiftUI

struct ProfilesView: View {
    var profiles: [Profile]

    var body: some View {
        if profiles.isEmpty {
            Text("No Profiles")
        } else {
            ForEach(profiles) { profile in
                ProfilesRow(profile: profile)
            }
        }
    }
}

struct ProfilesView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilesView(profiles: [.example, .example, .example])
    }
}
