//
//  PoliciesView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/19/23.
//

import SwiftUI

struct HostPoliciesView: View {
    var policies: [Policy]

    var body: some View {
        if policies.isEmpty {
            ContentUnavailableView(
                "No Policies",
                systemImage: "exclamationmark.triangle",
                description: Text("This host has no policies assigned to it.")
            )
        } else {
            List {
                ForEach(policies) { policy in
                    HStack {
                        // swiftlint:disable:next line_length
                        Image(systemName: policy.response == "" ? "questionmark.circle.fill" : policy.response == "pass" ? "checkmark.seal.fill" : "xmark.seal.fill")
                        // swiftlint:disable:next line_length
                            .foregroundStyle(policy.response == "" ? .yellow : policy.response == "pass" ? .green : .red)
                            .symbolRenderingMode(.hierarchical)
                            .imageScale(.large)

                        VStack(alignment: .leading) {
                            Text(policy.name)
                                .font(.headline)
                            if let response = policy.response {
                                Text(response == "" ? "Pending" : response)
                                    .foregroundStyle(.secondary)
                                    .font(.body.smallCaps())
                            }
                        }
                    }
                }
            }
        }
    }
}
