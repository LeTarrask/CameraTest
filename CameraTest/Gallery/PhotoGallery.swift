//
//  FolderGallery.swift
//  BracketedCamera
//
//  Created by tarrask on 03/05/2023.
//  Copyright © 2023 com.tarrask. All rights reserved.
//

import SwiftUI
import AVFoundation

struct FolderGallery: View {
    @State private var isPhotoSetViewPresented = false
    @State private var hasCamera = true

    @State var folder: Folder = Folder(name: "Test Folder", photoSets: [])

    @State private var draggingItem: PhotoSet?
    @State private var dualGrid: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                let columns = Array(repeating: GridItem(spacing: 10), count: dualGrid ? 2 : 3)
                LazyVGrid(columns: columns, spacing: 10, content: {
                    ForEach($folder.photoSets, id: \.self) { photoSet in
                        NavigationLink(destination: PhotoSetDetailView(photoSet: photoSet)) {
                            ZStack {
                                loadImage(name: photoSet.thumbnail.wrappedValue ?? "")
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(10)
                                    .shadow(radius: 5)

                                if photoSet.processedImage.wrappedValue != nil {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .vAlign(.bottom)
                                        .hAlign(.trailing)
                                        .padding(5)
                                }
                            }
                        }
                    }
                })
                .padding()
            }

            // MARK: - Navigation & Toolbar Items
            .navigationTitle(folder.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation(Animation.easeInOut) {
                            dualGrid.toggle()
                        }
                    } label: {
                        Image(systemName: dualGrid ? "square.grid.3x2" : "square.grid.2x2")
                            .font(.title3)
                    }
                }

                if hasCamera {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { isPhotoSetViewPresented = true }, label: {
                            Image(systemName: "camera")
                        })
                    }
                }
            })
            .fullScreenCover(isPresented: $isPhotoSetViewPresented) {
                NewPhotoSetView(isPhotoSetViewPresented: $isPhotoSetViewPresented,
                                folder: $folder)
            }
        }
        .onAppear {
            let discovery = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera],
                                                                  mediaType: AVMediaType.video,
                                                                  position: .back)
            hasCamera = !discovery.devices.isEmpty
        }
    }
}

struct GalleryRow: View {
    let headline: String
    let image: Image

    var body: some View {
        HStack(spacing: 16.0) {
            image
                .resizable()
                .frame(width: 56.0, height: 56.0)
                .clipShape(Circle())
            Text(headline)
        }
    }
}

 struct PhotoGallery_Previews: PreviewProvider {
    static var previews: some View {
        FolderGallery()
    }
 }
