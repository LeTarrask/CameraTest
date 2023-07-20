//
//  Folder.swift
//  FinalPhoto
//
//  Created by Alex Luna on 07/07/2023.
//

import SwiftUI

struct Folder: Codable, Hashable, Identifiable {
    var id = UUID()
    var name: String
    var photoSets: [PhotoSet]
}
