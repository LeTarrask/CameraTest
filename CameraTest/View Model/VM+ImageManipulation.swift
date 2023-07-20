//
//  ICVM+ImageManipulation.swift
//  FinalPhoto
//
//  Created by tarrask on 15/06/2023.
//

import SwiftUI

// MARK: - Image Manipulation and Storage
extension View {
    static var documentsFolder: URL {
        do {
            return try FileManager.default.url(for: .documentDirectory,
                                               in: .userDomainMask,
                                               appropriateFor: nil,
                                               create: false)
        } catch {
            fatalError("Can't find documents directory.")
        }
    }

    // RAW Local Image Storage
    func storeDataImage(_ image: Data) -> String {
        // Generate a unique file name for each image
        let fileName = UUID().uuidString + ".dng"
        // Create a file URL with the file name
        let fileURL = Self.documentsFolder.appendingPathComponent(fileName)

        do {
            // Write the data to the file URL
            try image.write(to: fileURL)
            // return the file URL string
            return fileName
        } catch {
            // Handle any writing errors
            print("Error saving image to \(fileURL): \(error)")
        }

        return ""
    }

    // PNG Local Image Storage
    func storeImage(_ image: UIImage) -> String {
        // Generate a unique file name for each image
        let fileName = UUID().uuidString + ".png"

        // Create a file URL with the file name
        let fileURL = Self.documentsFolder.appendingPathComponent(fileName)

        if let pngData = image.pngData() {
            do {
                // Write the data to the file URL
                try pngData.write(to: fileURL)
                // return the file URL string
                return fileName
            } catch {
                // Handle any writing errors
                print("Error saving image to \(fileURL): \(error)")
            }
        }
        return ""
    }

    // Local image deletion
    func deleteImage(named fileName: String) {
        // Create a file URL with the file name
        let fileURL = Self.documentsFolder.appendingPathComponent(fileName)

        do {
            // Delete the file at the file URL
            try FileManager.default.removeItem(at: fileURL)
            print("Deleted image at \(fileURL)")
        } catch {
            // Handle any errors that occur while deleting the file
            print("Error deleting image at \(fileURL): \(error)")
        }
    }

    // Reduce image size
    func resizeImage(_ image: UIImage, newSize: CGSize) -> UIImage? {
        let widthRatio = newSize.width / image.size.width
        let heightRatio = newSize.height / image.size.height
        let scaleFactor = min(widthRatio, heightRatio)
        let scaledSize = CGSize(width: image.size.width * scaleFactor, height: image.size.height * scaleFactor)
        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        let newImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: scaledSize))
        }
        return newImage
    }
}
