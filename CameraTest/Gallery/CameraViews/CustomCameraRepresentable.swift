//
//  CustomCameraRepresentable.swift
//  BracketedCamera
//
//  Created by tarrask on 03/05/2023.
//

import SwiftUI
import AVFoundation

struct CustomCameraRepresentable: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var didTapCapture: Bool

    @Binding var bracketAmount: BracketAmount
    @Binding var images: [UIImage]
    @Binding var imagesData: [Data]

    func makeUIViewController(context: Context) -> CustomCameraController {
        let controller = CustomCameraController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ cameraViewController: CustomCameraController, context: Context) {
        if self.didTapCapture {
            cameraViewController.didTapRecord(bracketAmount: bracketAmount)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {
        let parent: CustomCameraRepresentable

        init(_ parent: CustomCameraRepresentable) {
            self.parent = parent
        }

        func photoOutput(_ output: AVCapturePhotoOutput,
                         didFinishProcessingPhoto photo: AVCapturePhoto,
                         error: Error?) {

            parent.didTapCapture = false

            // Check for errors
            guard error == nil else {
                print("Error capturing photo: \(error!)")
                return
            }

            guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData.compress(withQuality: 0.5)) else { return }

            // Get the device's physical orientation
            let deviceOrientation = UIDevice.current.orientation

            // Get the connection of the photo output
            guard let connection = output.connection(with: .video) else { return }

            // Set the video orientation based on the device's physical orientation
            if let videoOrientation = AVCaptureVideoOrientation(rawValue: deviceOrientation.rawValue) {
                connection.videoOrientation = videoOrientation
            }

            // Set the image orientation based on the connection's video orientation
            var imageOrientation: UIImage.Orientation = .up

            switch connection.videoOrientation {
            case .portrait:
                imageOrientation = .right
            case .portraitUpsideDown:
                imageOrientation = .left
            case .landscapeLeft:
                imageOrientation = .down
            case .landscapeRight:
                imageOrientation = .up
            default:
                break
            }

            let orientedImage = UIImage(cgImage: image.cgImage!, scale: 1, orientation: imageOrientation)

            parent.images.append(orientedImage.fixOrientation())
            parent.imagesData.append(imageData)
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
