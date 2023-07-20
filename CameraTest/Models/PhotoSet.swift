//
//  PhotoShoot.swift
//  BracketedCamera
//
//  Created by tarrask on 04/05/2023.
//

import SwiftUI

struct PhotoSet: Identifiable, Codable, Hashable, Equatable {
    var id = UUID()
    var title: String
    var images: [String]

    // thumbnail image property for preview in the app
    var thumbnail: String?

    // stored processed image downloaded from server
    var processedImage: String?

    // store the name of the space where the shoot happened
    var album: String?

    // store the firebase user id
    var userID: String?

    // store server image urls
    var serverImages: [String] = []

    // store upload Date
    var uploadDateStamp: Date?

    var editStatus: String = Status.notUploaded.rawValue

    enum Status: String {
        case notUploaded = "Not Uploaded"
        case inProcess = "Editing in process"
        case editFinished = "Edit Completed"
    }
}
