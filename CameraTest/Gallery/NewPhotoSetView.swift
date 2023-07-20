//
//  PhotoSetView.swift
//  BracketedCamera
//
//  Created by tarrask on 04/05/2023.
//

import SwiftUI

struct NewPhotoSetView: View {
    @Binding var isPhotoSetViewPresented: Bool
    @State fileprivate var isCameraViewPresented: Bool = false

    // MARK: - alert data
    @State var showingAlert = true
    var alertTitle: String = "New Photo"
    var alertMessage: String = "Enter a name for this photo"
    var alertButtonText: String = "Save"

    @State var title = "New PhotoSet"

    @State var images: [UIImage] = []
    @State var imagesData: [Data] = []

    @Binding var folder: Folder

    var thumbImage: UIImage? {
        images[images.count/2]
    }

    var body: some View {
        NavigationView {
            VStack {
                if images.isEmpty {
                    // MARK: - Empty View
                    VStack {
                        Spacer()

                        Button(action: {
                            isCameraViewPresented.toggle()
                        }, label: {
                            Text("Add Photo")
                                .foregroundColor(.white)
                                .frame(maxWidth: 200)
                                .padding()
                                .background(Color(red: 0.06, green: 0.44, blue: 0.77))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        })

                        Spacer()

                        Text("Empty")
                            .foregroundColor(.gray)
                    }

                } else {
                    ScrollView(.horizontal) {
                        // Use a ForEach loop to iterate over the array
                        HStack {
                            ForEach(0..<images.count, id: \.self) { index in
                                // Create an Image view from each UIImage from the RAW images array
                                Image(uiImage: images[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                        }
                    }

                    VStack {
                        HStack {
                            Button(action: {
                                isPhotoSetViewPresented.toggle()
                            }, label: {
                                Text("Cancel")
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.gray))
                            })

                            Button(action: {
                                var imagePaths = [String]()
                                for image in imagesData {
                                    imagePaths.append(storeDataImage(image))
                                }

                                var thumb = ""
                                if (thumbImage != nil) {
                                    thumb = storeImage(thumbImage!)
                                }

                                let photoSet = PhotoSet(title: title, images: imagePaths, thumbnail: thumb)

                                folder.photoSets.append(photoSet)

                                // Clear temp data
                                images = []
                                imagesData = []
                                title = ""

                                // Go back to gallery
                                isPhotoSetViewPresented.toggle()

                            }, label: {
                                Text("Save PhotoSet")
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(RoundedRectangle(cornerRadius: 20))
                            })
                        }

                        Spacer()

                        HStack {
                            Spacer()

                            Text("\(images.count) photos")
                                .font(.body)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 32)

                            Button(action: {

                            }, label: {
                                Image(systemName: "camera")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: 80)
                                    .padding()
                                    .background(Color(red: 0.06, green: 0.44, blue: 0.77))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))

                            }).padding(16)
                        }
                        .frame(maxWidth: .infinity, minHeight: 130, maxHeight: 130, alignment: .bottom)
                        .background(
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: .black.opacity(0), location: 0.00),
                                    Gradient.Stop(color: .black.opacity(0.2), location: 1.00)
                                ],
                                startPoint: UnitPoint(x: 0.5, y: 0),
                                endPoint: UnitPoint(x: 0.5, y: 1)
                            )
                        )
                        .edgesIgnoringSafeArea(.all)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(title)
            .navigationBarItems(trailing: Button("Add", action: { isCameraViewPresented.toggle() }) )
            .fullScreenCover(isPresented: $isCameraViewPresented) {
                CameraView(didTapCapture: false,
                           isPresented: $isCameraViewPresented,
                           images: $images,
                           imagesData: $imagesData,
                           folderName: folder.name)
            }
            .alert(alertTitle, isPresented: $showingAlert, actions: {
                TextField("New Photo", text: $title)
                Button("Save", action: {})
                Button("Cancel", role: .cancel, action: {})
            }, message: {
                Text(alertMessage)
            })
        }
    }
}
