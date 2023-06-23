//
//  DeviceInformationQuerySelection.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 6/22/23.
//

import SwiftUI

enum Query: String, CaseIterable {
    case deviceName = "DeviceName"
    case osVersion = "OSVersion"
    case modelName = "ModelName"
    
    var readableValue: String {
        switch self {
        case .deviceName:
            return "Device Name"
        case .osVersion:
            return "OS Version"
        case .modelName:
            return "Model Name"
        }
    }
}

struct DeviceInformationQuerySelection: View {
    
    
    let supportedQueries: [String]
    
    @State private var selectedQueries: Set<String> = []
    
    var body: some View {
        VStack {
            Text("Select Queries")
                .font(.title)
            
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(supportedQueries, id: \.self) { query in
                        Toggle(query, isOn: Binding(
                            get: { selectedQueries.contains(query) },
                            set: { isSelected in
                                if isSelected {
                                    selectedQueries.insert(query)
                                } else {
                                    selectedQueries.remove(query)
                                }
                            }
                        ))
                    }
                }
            }
            
            Button(action: generateCommand) {
                Text("Send Command")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    func generateCommand() {
        let queriesArray = Array(selectedQueries)
        let uuid = UUID()
        // Create the DeviceInformationCommand instance with the generated array of queries
        let deviceInfoCommand = DeviceInformationCommand(commandUUID: "\(uuid)", queries: queriesArray)
        
        
        let plistData: Data
        do {
            plistData = try PropertyListEncoder().encode(deviceInfoCommand)
        } catch {
            fatalError("Failed to convert dictionary to plist data: \(error)")
        }
        
        if let plistString = String(data: plistData, encoding: .utf8) {
            print(plistString)
        // Perform further actions with the generated command
        // ...
    }
    }
}

struct DeviceInformationQuerySelection_Previews: PreviewProvider {
    static var previews: some View {
        DeviceInformationQuerySelection(supportedQueries: ["Battery Life", "MacBookPro"])
    }
}
