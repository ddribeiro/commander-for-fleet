//
//  ModelContext-Extension.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 1/26/24.
//

import SwiftData

extension ModelContext {
    var sqliteCommand: String {
        if let url = container.configurations.first?.url.path(percentEncoded: false) {
            "sqlite3 \"\(url)\""
        } else {
            "No SQLite database found."
        }
    }
}
