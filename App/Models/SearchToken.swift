//
//  SearchToken.swift
//  Commander
//
//  Created by Dale Ribeiro on 6/8/23.
//

struct SearchToken: Identifiable {
    var id: String { name }
    var name: String
    var platform: [String]
}
