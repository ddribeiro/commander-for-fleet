//
//  SoftwareListView.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 1/24/24.
//

import SwiftData
import SwiftUI

struct SoftwareListView: View {
    @EnvironmentObject var dataController: DataController
    @Query var software: [CachedSoftware]
    @State private var isShowingVulnerableSoftware: Bool

    var body: some View {
        List {
            softwareRows(software)
        }
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .bottomBar) {
                if dataController.loadingState == .loaded {
                    VStack {
                        if let updatedAt = dataController.softwareLastUpdatedAt {
                            Text("Updated at \(updatedAt.formatted(date: .omitted, time: .shortened))")
                                .font(.footnote)
                            Text("^[\(software.count) Software Titles](inflection: true)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if dataController.loadingState == .loading {
                    HStack {
                        ProgressView()
                            .padding(.horizontal, 1)
                            .controlSize(.mini)

                        Text("Loading Software")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                }
            }
            #endif
        }
        .overlay {
            if software.isEmpty {
                ContentUnavailableView.search
            }
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
