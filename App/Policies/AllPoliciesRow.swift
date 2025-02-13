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
                .multilineTextAlignment(.leading)
            if sizeClass == .compact {
                HStack {
                    Text("\(policy.passingHostCount) Passing")
                        .foregroundStyle(.white)
                        .padding(4)
                        .background(.green, in: RoundedRectangle(cornerRadius: 8))
                    
                    
                    Text("\(policy.failingHostCount) Failing")
                        .foregroundStyle(.white)
                        .padding(4)
                        .background(.red, in: RoundedRectangle(cornerRadius: 8))
                }
                .font(.subheadline)
            }
            
        }
    }
}
