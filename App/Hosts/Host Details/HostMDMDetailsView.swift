//
//  HostMDMDetailsView.swift
//  Commander
//
//  Created by Dale Ribeiro on 9/22/24.
//

import SwiftUI

struct HostMDMDetailsView: View {
    let mdm: Mdm

    var body: some View {
        Group {
            LabeledContent("Enrollment Status", value: mdm.enrollmentStatus ?? "N/A")

            LabeledContent("MDM Server URL", value: mdm.serverUrl ?? "N/A")
                .multilineTextAlignment(.trailing)

            LabeledContent("MDM Name", value: mdm.name)
                .multilineTextAlignment(.trailing)

            HStack {
                Text("Encryption Key Escrowed")
                Spacer()
                HStack(spacing: 6) {
                    Text(mdm.encryptionKeyAvailable ? "Yes" : "No")
                        .foregroundColor(mdm.encryptionKeyAvailable ? .secondary : .red)

                    Image(systemName: mdm.encryptionKeyAvailable ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                        .imageScale(.large)
                        .foregroundColor(mdm.encryptionKeyAvailable ? .green : .red)
                }
            }
        }
    }
}

#Preview {
    HostMDMDetailsView(mdm: .example)
}
