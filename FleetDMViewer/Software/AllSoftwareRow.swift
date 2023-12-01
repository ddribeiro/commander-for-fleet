//
//  AllSoftwareRow.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 12/1/23.
//

import SwiftUI

struct AllSoftwareRow: View {
    var software: CachedSoftware
    var body: some View {
        HStack {
            Image(systemName: "app.badge")
                .imageScale(.large)
#if os(iOS)
                .frame(width: 40, height: 40)
#else
                .frame(width: 20, height: 20)
#endif
            Text(software.wrappedName)

        }
    }
}
