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
        VStack(alignment: .leading) {
            Text(policy.wrappedName)
                .font(.headline)

            if sizeClass == .compact {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                        Text("\(policy.passingHostCount) Passing")
                    }

                    HStack {
                        Image(systemName: "xmark.seal.fill")
                            .foregroundStyle(.red)
                        Text("\(policy.failingHostCount) Failing")
                    }
                }
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)
                .font(.subheadline)
            }

        }
    }
}
