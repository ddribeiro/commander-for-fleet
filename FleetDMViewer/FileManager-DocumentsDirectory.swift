//
//  FileManager-DocumentsDirectory.swift
//  FaceTracker
//
//  Created by Dale Ribeiro on 11/11/22.
//

import Foundation


extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
