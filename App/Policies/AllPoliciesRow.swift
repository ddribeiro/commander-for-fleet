//
//  AllPoliciesRow.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 12/5/23.
//

import SwiftUI

struct AllPoliciesRow: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    var policy: CachedPolicy

    var body: some View {
        HStack {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.semibold)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.green)
#if os(iOS)
                .frame(width: 40, height: 40)
#else
                .frame(width: 20, height: 20)
#endif
            Text(policy.name)
                .font(.headline)
            if sizeClass == .compact {
                Spacer()

                VStack {
                    Text("\(policy.passingHostCount) Passing")
                        .foregroundStyle(.green)
                    Text("\(policy.failingHostCount) Failing")
                        .foregroundStyle(.red)
                }
                .font(.smallCaps(.body)())
            }
        }

    }
}
