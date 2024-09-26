//
//  UsersListView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/29/23.
//

import SwiftUI

struct UsersListView: View {
    @EnvironmentObject var dataController: DataController

    @Environment(\.managedObjectContext) var moc
    @Environment(\.networkManager) var networkManager

    @State private var isShowingSignInSheet = false

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var teams: FetchedResults<CachedTeam>

    var teamFilters: [Filter] {
        teams.map { team in
            Filter(id: Int(team.id), name: team.wrappedName, icon: "person.3", team: team)
        }
    }

    var body: some View {
        if dataController.isAuthenticated {
            List {
                ForEach(dataController.usersForSelectedFilter()) { user in
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
