//
//  Extension-ParseStrategy.swift
//  FleetDMViewer
//
//  Created by Dale Ribeiro on 9/21/24.
//

import Foundation

extension ParseStrategy where Self == Date.ISO8601FormatStyle {
    static var iso8601withFractionalSeconds: Self { .init(includingFractionalSeconds: true) }
}
