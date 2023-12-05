//
//  AllPoliciesRow.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 12/5/23.
//

import SwiftUI

struct AllPoliciesRow: View {
    var policy: CachedPolicy
    var body: some View {
        HStack {
            Image(systemName: "checkmark.seal")
                .imageScale(.large)
                .foregroundStyle(.green)
#if os(iOS)
                .frame(width: 40, height: 40)
#else
                .frame(width: 20, height: 20)
#endif
            Text(policy.wrappedName)
        }
    }
}
