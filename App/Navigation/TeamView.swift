//
//  TeamView.swift
//  Commander
//
//  Created by Dale Ribeiro on 4/5/25.
//

import SwiftUI

struct TeamView: View {
    var team: CachedTeam

    var body: some View {
        List {
            TopLevelNavigationView()
        }
        .navigationTitle(team.wrappedName)
    }
}
