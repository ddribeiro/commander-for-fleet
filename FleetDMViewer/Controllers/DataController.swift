//
//  DataController.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 8/21/23.
//

import Foundation
import SwiftUI

class DataController: ObservableObject {
    @Published var selectedTeam: Team?
    @Published var selectedHost: Host?

    @AppStorage("isAuthenticated") var isAuthenticated: Bool = false

}
