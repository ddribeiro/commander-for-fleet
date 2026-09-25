//
//  AllPoliciesRow.swift
//  Commander
//
//  Created by Dale Ribeiro on 12/5/23.
//

import SwiftUI

struct AllPoliciesRow: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    var policy: Policy

    var body: some View {
        VStack(alignment: .leading) {
            Text(policy.name)
                .font(.headline)

            if sizeClass == .compact {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                        Text("\(policy.passingHostCount.map(String.init) ?? "—") Passing")
                    }

                    HStack {
                        Image(systemName: "xmark.seal.fill")
                            .foregroundStyle(.red)
                        Text("\(policy.failingHostCount.map(String.init) ?? "—") Failing")
                    }
                }
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)
                .font(.subheadline)
            }

        }
    }
}
