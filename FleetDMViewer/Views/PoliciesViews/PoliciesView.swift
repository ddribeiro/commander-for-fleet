//
//  PoliciesView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/19/23.
//

import SwiftUI

struct PoliciesView: View {
    var policies: [Policy]
    
    var body: some View {
        if policies.isEmpty {
            Text("No policies")
        } else {
            List {
                ForEach(policies) { policy in
                    HStack {
                        Text(policy.name)
                        Spacer()
                        Image(systemName: policy.response == "pass" ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                            .foregroundStyle(policy.response == "pass" ? .green : .red)
                            .imageScale(.large)
                    }
                }
            }
        }
    }
}

struct PoliciesView_Previews: PreviewProvider {
    static var previews: some View {
        PoliciesView(policies: [Policy(id: 42, name: "Auto Updates", critical: false, response: "pass")])
    }
}