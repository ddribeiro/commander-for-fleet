//
//  UsersListView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/29/23.
//

import SwiftData
import SwiftUI

struct UsersListView: View {
    @EnvironmentObject var dataController: DataController

    @Environment(\.managedObjectContext) var moc
    @Environment(\.networkManager) var networkManager

    @State private var isShowingSignInSheet = false

    @Query var teams: [CachedTeam]
    @Query var users: [CachedUser]

    var teamFilters: [Filter] {
        teams.map { team in
            Filter(id: Int(team.id), name: team.name, icon: "person.3", team: team)
        }
    }

    var body: some View {
        if dataController.isAuthenticated {
            List(selection: $dataController.selectedUser) {
                ForEach(users) { user in
                    UserRow(user: user)
                }
            }
        } else {
            NoHostView()
                .sheet(isPresented: $isShowingSignInSheet) {
                    LoginView()
                }
                .onAppear {
                    isShowingSignInSheet = true
                }
        }
    }
}

#Preview {
    UsersListView()
}
