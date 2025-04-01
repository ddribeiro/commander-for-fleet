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
        VStack(alignment: .center) {
            Text(policy.wrappedName)
                .font(.headline)
                .multilineTextAlignment(.center)
            if sizeClass == .compact {
                HStack {
                    Group {
                        VStack {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.headline)
                            Text("\(policy.passingHostCount) Passing")
                        }
                        .padding(8)
                        .foregroundStyle(.white)
                        .frame(width: 120, height: 70)
                        .background(.green, in: RoundedRectangle(cornerRadius: 8))

                        Spacer()
                        VStack {
                            Image(systemName: "xmark.seal.fill")
                                .font(.headline)
                            Text("\(policy.failingHostCount) Failing")

                        }
                        .foregroundStyle(.white)
                        .padding(8)
                        .frame(width: 120, height: 70)
                        .background(.red, in: RoundedRectangle(cornerRadius: 8))

                    }

                }

                .padding()
                .font(.subheadline)
            }
        }
    }
}
