//
//  NewHostRow.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/29/23.
//

import SwiftUI

struct NewHostRow: View {
    var host: CachedHost

    var body: some View {
        HStack {
            Image(systemName: "laptopcomputer")
                .imageScale(.large)
#if os(iOS)
                .frame(width: 40, height: 40)
#else
                .frame(width: 20, height: 20)
#endif
            Text(host.wrappedComputerName)
        }
    }
}
