//
//  DetailView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/15/23.
//

import SwiftUI

struct DetailView: View {
    @EnvironmentObject var viewModel: ViewModel
    var body: some View {
        VStack {
            if let host = viewModel.selectedHost {
                HostView(host: host)
            } else {
                NoHostView()
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView()
    }
}
