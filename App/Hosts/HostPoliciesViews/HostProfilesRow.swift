//
//  ProfilesRow.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/21/23.
//

import SwiftUI

struct HostProfilesRow: View {
    var profile: Profile
    var body: some View {
        HStack {
            Image(systemName: profile.status == "verified" ? "gear.badge.checkmark" : "gear.badge.questionmark")
                .symbolRenderingMode(.palette)
                .foregroundStyle(profile.status == "verified" ? .green : .red, .primary)
                .imageScale(.large)

            VStack(alignment: .leading) {
                Text(profile.name)
                    .font(.headline)
                Text(profile.status)
                    .foregroundStyle(.secondary)
                    .font(.body.smallCaps())
            }
        }
    }
}

struct ProfilesRow_Previews: PreviewProvider {
    static var previews: some View {
        HostProfilesRow(profile: .example)
    }
}
