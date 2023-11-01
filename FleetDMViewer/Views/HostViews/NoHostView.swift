//
//  NoHostView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/9/23.
//

import SwiftUI

struct NoHostView: View {
    var body: some View {
        ContentUnavailableView(
            "No Hosts Selected",
            systemImage: "laptopcomputer.slash",
            description: Text("Select a host in the list to see details about it.")
        )
    }
}

struct NoHostView_Previews: PreviewProvider {
    static var previews: some View {
        NoHostView()
    }
}
