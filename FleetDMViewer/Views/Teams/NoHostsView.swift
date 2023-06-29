//
//  NoHostsView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/29/23.
//

import SwiftUI

struct NoHostsView: View {
    var body: some View {
        Text("No Hosts in Team")
            .font(.title)
            .foregroundStyle(.secondary)
    }
}

struct NoHostsView_Previews: PreviewProvider {
    static var previews: some View {
        NoHostsView()
    }
}
