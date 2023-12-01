//
//  UserRow.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/30/23.
//

import SwiftUI

struct UserRow: View {
    var user: CachedUser

    var body: some View {
        let iconShape = RoundedRectangle(cornerRadius: 4, style: .continuous)

        HStack {
            Image(systemName: "person")
                .imageScale(.large)
                .foregroundStyle(.red)
#if os(iOS)
                .frame(width: 40, height: 40)
#else
                .frame(width: 20, height: 20)
#endif
            Text(user.wrappedName)

        }
    }
}
