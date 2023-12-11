//
//  ServerSelectionView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 8/21/23.
//

import SwiftUI

struct ServerSelectionView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var appEnvironments = AppEnvironments()

    var body: some View {
        if !appEnvironments.environments.isEmpty {
            List(selection: $dataController.activeEnvironment) {
                ForEach(appEnvironments.environments, id: \.self) {
                    Text($0.name ?? "\($0.baseURL)")
                }
            }
        } else {
            Text("No Environments Saved")
        }
    }
}

struct ServerSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ServerSelectionView()
    }
}
