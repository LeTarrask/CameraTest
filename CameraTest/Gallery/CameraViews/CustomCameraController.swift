//
//  CustomCameraController.swift
//  BracketedCamera
//
//  Created by tarrask on 03/05/2023.
//

import UIKit
import AVFoundation

class CustomCameraController: UIViewController {

    var image: UIImage?

    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?

    var delegate: AVCapturePhotoCaptureDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func setup() {
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
    }

    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }

    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                      mediaType: AVMediaType.video,
                                                                      position: AVCaptureDevice.Position.unspecified)

        for device in deviceDiscoverySession.devices {

            switch device.position {
            case AVCaptureDevice.Position.front:
                self.frontCamera = device
            case AVCaptureDevice.Position.back:
                self.backCamera = device
            default:
                break
            }
        }

        self.currentCamera = self.backCamera
    }

    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format:
                                                                                [AVVideoCodecKey:
                                                                                    AVVideoCodecType.hevc])],
                                                       completionHandler: nil)
//            photoOutput?.isHighResolutionCaptureEnabled = true

            // TESTING: Setting the Capture Prioritization
            photoOutput?.maxPhotoQualityPrioritization = .quality

            captureSession.addOutput(photoOutput!)

        } catch {
            print(error)
        }

    }

    func setupPreviewLayer() {
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill

        self.cameraPreviewLayer?.frame = self.view.frame

        self.view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.cameraPreviewLayer?.frame = self.view.bounds

        // TODO: - probably delete this after testing
//        let deviceOrientation = UIDevice.current.orientation
//        let newVideoOrientation: AVCaptureVideoOrientation
//
//        switch deviceOrientation {
//        case .portrait:
//            newVideoOrientation = .portrait
//        case .portraitUpsideDown:
//            newVideoOrientation = .portraitUpsideDown
//        case .landscapeLeft:
//            newVideoOrientation = .landscapeRight
//        case .landscapeRight:
//            newVideoOrientation = .landscapeLeft
//        default:
//            newVideoOrientation = .portrait
//        }
//
//        self.cameraPreviewLayer?.connection?.videoOrientation = newVideoOrientation
    }

    func startRunningCaptureSession() {
        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }
    }

    // This method is called when the user taps the capture button
    func didTapRecord(bracketAmount: BracketAmount) {
        switch bracketAmount {
        case .standard:
            captureBracketedPicture(exposureValues: [-1, 0, +1])
        case .pro:
            captureBracketedPicture(exposureValues: [-2, -1, -0])
            captureBracketedPicture(exposureValues: [+1, +2])
        case .premium:
            captureBracketedPicture(exposureValues: [-4, -2, -1, -0])
            captureBracketedPicture(exposureValues: [+1, +2, +4])
        }
    }

    // Gets an array of exposureValues and take bracketed pictures of them
    func captureBracketedPicture(exposureValues: [Float]) {
        // Get AVCaptureBracketedStillImageSettings for a set of exposure values
        let makeAutoExposureSettings = AVCaptureAutoExposureBracketedStillImageSettings
            .autoExposureSettings(exposureTargetBias:)

        let exposureSettings = exposureValues.map(makeAutoExposureSettings)

        // Here we're going for RAW images
        let photoSettings = AVCapturePhotoBracketSettings(rawPixelFormatType: kCVPixelFormatType_14Bayer_RGGB,
                                                          processedFormat: nil, bracketedSettings: exposureSettings)

//        photoSettings.isHighResolutionPhotoEnabled = true

        // Disable flash, just in case
        photoSettings.flashMode = .off

        // Shoot the bracket, using a custom class to handle capture delegate callbacks.
        self.photoOutput?.capturePhoto(with: photoSettings, delegate: delegate!)
    }
}
