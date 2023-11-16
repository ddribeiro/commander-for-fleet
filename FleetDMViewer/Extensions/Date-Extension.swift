//
//  Date-Extension.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 11/15/23.
//

import Foundation

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
