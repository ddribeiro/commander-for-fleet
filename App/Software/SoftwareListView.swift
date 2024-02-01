//
//  SoftwareListView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 1/24/24.
//

import SwiftData
import SwiftUI

struct SoftwareListView: View {
    @Query var software: [CachedSoftware]
    @State private var isShowingVulnerableSoftware: Bool

    var body: some View {
        List {
            softwareRows(software)
        }
    }

    init(
        searchString: String,
        isShowingVulnerableSoftware: Bool,

        sortOrder: SortOrder = .forward
    ) {
        let predicate = CachedSoftware.predicate(
            searchText: searchString,
            isShowingVulnerableSoftware: isShowingVulnerableSoftware
        )

        _software = Query(filter: predicate, sort: \.name, order: sortOrder)
        _isShowingVulnerableSoftware = State(initialValue: isShowingVulnerableSoftware)
    }

    func softwareRows(_ software: [CachedSoftware]) -> some View {

        ForEach(software, id: \.id) { software in
//            _ = print("\(software.name) has an ID of: \(software.id)")
            NavigationLink(value: software) {
                AllSoftwareRow(software: software)
            }
        }
    }
}
