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
    @Published var currentUser: User?

    @Published var activeEnvironment: AppEnvironment? {
        didSet {
            print(String(describing: activeEnvironment))
        }
    }

    @AppStorage("isAuthenticated") var isAuthenticated: Bool = false

}
