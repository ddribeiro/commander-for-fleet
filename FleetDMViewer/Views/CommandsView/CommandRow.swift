//
//  CommandRow.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/29/23.
//

import SwiftUI

struct CommandRow: View {
    var command: CommandResponse
    
    var body: some View {
        HStack {
            Image(systemName: "laptopcomputer.and.arrow.down")
                .imageScale(.large)
            
            VStack(alignment: .leading) {
                Text(command.requestType)
                    .font(.headline)
                Text("\(command.updatedAt.formatted(date: .numeric, time: .shortened))")
                    .foregroundStyle(.secondary)
                
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                switch command.status {
                case "Acknowledged":
                    Image(systemName: "checkmark.icloud.fill")
                        .foregroundColor(.green)
                    Text(command.status)
                        .foregroundStyle(.secondary)
                        .font(.body.smallCaps())
                    
                case "Pending":
                    Image(systemName: "clock.badge.questionmark.fill")
                        .foregroundColor(.secondary)
                    
                    Text(command.status)
                        .foregroundStyle(.secondary)
                        .font(.body.smallCaps())
                    
                default:
                    Image(systemName: "xmark.icloud.fill")
                        .foregroundColor(.red)
                    Text(command.status)
                        .foregroundColor(.secondary)
                        .font(.body.smallCaps())
                }
            }
        }
    }
}

struct CommandRow_Previews: PreviewProvider {
    static var previews: some View {
        CommandRow(command: .example)
    }
}
