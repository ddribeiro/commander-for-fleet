//
//  NoHostView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/9/23.
//

import SwiftUI

struct NoHostView: View {
    var body: some View {
        Text("No Host Selected")
            .font(.title)
            .foregroundStyle(.secondary)
    }
}

struct NoHostView_Previews: PreviewProvider {
    static var previews: some View {
        NoHostView()
    }
}
