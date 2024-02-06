//
//  VideoContentViewModel.swift
//  Aespa-iOS
//
//  Created by 이영빈 on 2023/06/07.
//

import Combine
import SwiftUI
import Foundation
import AVFoundation

import AespaBracketedCamera

class VideoContentViewModel: ObservableObject {
    let aespaSession: AespaSession
    
    var preview: some View {
        aespaSession.interactivePreview()
        
        // Or you can give some options
//        let option = InteractivePreviewOption(enableZoom: true)
//        return aespaSession.interactivePreview(option: option)
    }
    
    private var subscription = Set<AnyCancellable>()
    
    @Published var videoAlbumCover: Image?
    @Published var photoAlbumCover: Image?
    
    @Published var videoFiles: [VideoAsset] = []
    @Published var photoFiles: [PhotoAsset] = []

    @Published var images: [UIImage] = []

    init() {
        let option = AespaOption(albumName: "Camera Test")
        self.aespaSession = Aespa.session(with: option)

        // Common setting
        aespaSession
            .common(.focus(mode: .continuousAutoFocus))
            .common(.changeMonitoring(enabled: true))
            .common(.orientation(orientation: .portrait))
            .common(.quality(preset: .high))
            .common(.custom(tuner: WideColorCameraTuner())) { result in
                if case .failure(let error) = result {
                    print("Error: ", error)
                }
            }
        
        // Photo-only setting
        aespaSession
            .photo(.flashMode(mode: .off))
            .photo(.redEyeReduction(enabled: false))

        // Video-only setting
        aespaSession
            .video(.mute)
            .video(.stabilization(mode: .auto))

        // Prepare video album cover
        aespaSession.videoFilePublisher
            .receive(on: DispatchQueue.main)
            .map { result -> Image? in
                if case .success(let file) = result {
                    return file.thumbnailImage
                } else {
                    return nil
                }
            }
            .assign(to: \.videoAlbumCover, on: self)
            .store(in: &subscription)
        
        // Prepare photo album cover
        aespaSession.photoFilePublisher
            .receive(on: DispatchQueue.main)
            .map { result -> Image? in
                if case .success(let file) = result {
                    return file.thumbnailImage
                } else {
                    return nil
                }
            }
            .assign(to: \.photoAlbumCover, on: self)
            .store(in: &subscription)
    }
    
    func fetchVideoFiles() {
        // File fetching task can cause low reponsiveness when called from main thread
        Task(priority: .utility) {
            let fetchedFiles = await aespaSession.fetchVideoFiles()
            DispatchQueue.main.async { self.videoFiles = fetchedFiles }
        }
    }
    
    func fetchPhotoFiles() {
        // File fetching task can cause low reponsiveness when called from main thread
        Task(priority: .utility) {
            let fetchedFiles = await aespaSession.fetchPhotoFiles()
            DispatchQueue.main.async { self.photoFiles = fetchedFiles }
        }
    }
}


extension VideoContentViewModel {
    // Example for using custom session tuner
    struct WideColorCameraTuner: AespaSessionTuning {
        func tune<T>(_ session: T) throws where T : AespaCoreSessionRepresentable {
            session.avCaptureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
        }
    }
}


extension VideoContentViewModel {
    func captureBracketedPhotos(count: Int) {
        Task {
            let photos = try? await self.aespaSession.captureBracketedPhotos(count: count, autoVideoOrientationEnabled: true)

            _ = photos.map { photos in
                for capture in photos {
                    if let image = convertToImage(photo: capture) {
                        DispatchQueue.main.async {
                            // TODO: here we're getting photis in the TIFF format on iPhone 13
                            // We could check the metadata and save the file with the correct format here
                            
                            print(capture.resolvedSettings.rawPhotoDimensions)

                            print("capture is raw \(capture.isRawPhoto)")
                            print("pixel buffer \(String(describing: capture.pixelBuffer))")

                            self.images.append(image)
                        }
                    }
                }
            }
        }
    }
}

func convertToImage(photo: AVCapturePhoto) -> UIImage? {
    if let data = photo.fileDataRepresentation() {
        return UIImage(data: data)?.fixOrientation()
    }
    return nil
}
