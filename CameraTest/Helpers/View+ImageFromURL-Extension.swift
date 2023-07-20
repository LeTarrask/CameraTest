//
//  View+ImageFromURL-Extension.swift
//  BracketedCamera
//
//  Created by tarrask on 05/05/2023.
//

import SwiftUI

extension View {
    // A function that loads an image from a file URL and displays it in SwiftUI
    func loadUIImage(name: String) -> UIImage {
        // Get the path of the document directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // Create a file URL with the image name
        let fileURL = documentsDirectory.appendingPathComponent(name)
        
        // Create a UIImage object from the file URL
        guard let uiImage = UIImage(contentsOfFile: fileURL.path) else {
            // Return an empty image if the UIImage object is nil
            return UIImage(named: "GalleryView.Item.0")!
        }
        
        // Return an Image view with the UIImage object
        return uiImage
    }
    
    func loadImage(name: String) -> Image {
        Image(uiImage: loadUIImage(name: name))
    }
}
