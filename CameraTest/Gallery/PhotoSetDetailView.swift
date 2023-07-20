//
//  PhotoSetDetailView.swift
//  BracketedCamera
//
//  Created by tarrask on 04/05/2023.
//

import SwiftUI

struct PhotoSetDetailView: View {
    @Binding var photoSet: PhotoSet

    @State private var isLoading: Bool = false

    @State private var errorMessage: String = ""
    @State private var showError: Bool = false

    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Text(photoSet.editStatus)
                    .padding()
                    .hAlign(.leading)

                if photoSet.processedImage != nil {
                    VStack(alignment: .center) {
                        Text("Processed Image")
                            .font(.title)
                        loadImage(name: photoSet.processedImage ?? "")
                            .resizable()
                            .scaledToFit()
                        Button("Download Processed Image", action: {
                            shareActivityView(items: [loadUIImage(name: photoSet.processedImage ?? "")])
                        })
                        .buttonStyle(.borderedProminent)
                    }.padding()

                } else {
                    Button("Upload to process Photo Set") {
                    }
                    .hAlign(.bottom)
                    .fillView(.blue)
                    .foregroundColor(.white)
                    .padding()
                }

                if !photoSet.serverImages.isEmpty {
                    ForEach(photoSet.serverImages, id: \.self) { url in
                        Text(url)
                    }
                }

                VStack {
                    Text("RAW Image Exposures")
                        .fontWeight(.bold)

                    ScrollView(.horizontal) {
                        VStack {
                            Text("Local Images (RAW)")
                            ForEach(photoSet.images, id: \.self) { image in
                                Text("Image: \(image)")
                            }
                        }
                        .cornerRadius(15)
                    }
                    .padding()
                }
                Spacer()
            }
            .navigationTitle(photoSet.title)
            // A navigation bar item to show a button for sharing
            .navigationBarItems(trailing: Button(action: { shareActivityView(items: itemsToShare) },
                                                 label: { // An image view to show a system icon for sharing
                Image(systemName: "square.and.arrow.up")
                .font(.title) } ))
        }
    }

    // MARK: - Sharing RAW DNGs
    var itemsToShare: [Any] {
        let files = photoSet.images.compactMap { fileName -> Data? in
            let fileURL = Self.documentsFolder.appendingPathComponent(fileName)

            do {
                let data = try Data(contentsOf: fileURL)
                print(fileURL)
                return data
            } catch {
                print("Failed to read data from file:", error)
                return nil
            }
        }

        return files
    }

    // MARK: - Present Activity View Controller
    func shareActivityView(items: [Any]) {
        let activityView = UIActivityViewController(activityItems: items, applicationActivities: nil)

        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first

        window?.rootViewController?.present(activityView, animated: true)
    }
}
