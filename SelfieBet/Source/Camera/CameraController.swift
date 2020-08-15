//
//  CameraController.swift
//  SelfieBet
//
//  Created by 용태권 on 2020/07/08.
//  Copyright © 2020 Yongtae.Kwon. All rights reserved.
//
import AVFoundation
import Foundation
import RxSwift
import RxCocoa
import Vision
import UIKit


protocol DetectFaceDelegate {
    func detect()
}

enum CameraControllerError: Swift.Error {
    case captureSessionAlreadyRunning
    case captureSessionIsMissing
    case inputsAreInvalid
    case invalidOperation
    case noCamerasAvailable
    case unknown
}

public enum CameraPosition {
    case front
    case rear
}

class CameraController: NSObject {
    
    var captureSession = AVCaptureSession()
    var currentCameraPosition: CameraPosition = .rear
    
    var currentCamera: AVCaptureDevice?
    var currentCameraInput: AVCaptureDeviceInput?
    var rearCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    
    var photoOutput: AVCapturePhotoOutput?
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    var flashMode: AVCaptureDevice.FlashMode = .off
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    var cameraSetting: AVCaptureDevice.Format?
    
    let videoDataOutput = AVCaptureVideoDataOutput()
    
    struct State {
        let detectedFaceNumber = BehaviorRelay<Int>(value: 0)
    }
    
    let state = State()
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        func configureCaptureDevices() throws {
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera], mediaType: AVMediaType.video, position: .unspecified)
            
            let cameras = (session.devices.compactMap { $0 })
            guard !cameras.isEmpty else { throw CameraControllerError.noCamerasAvailable }
            
            for camera in cameras {
                if camera.position == .front {
                    self.frontCamera = camera
                }
                
                if camera.position == .back {
                    self.rearCamera = camera
                    
                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                }
            }
        }
        func configureDeviceInputs() throws {
            if let rearCamera = self.rearCamera, currentCameraPosition == .rear {
                self.currentCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            } else if let frontCamera = self.frontCamera, currentCameraPosition == .front {
                self.currentCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            }
            guard let cameraInput = self.currentCameraInput else { return }
            if captureSession.canAddInput(cameraInput) {
                captureSession.addInput(cameraInput)
            }
        }
        func configurePhotoOutput() throws {
            self.photoOutput = AVCapturePhotoOutput()
            guard let output = self.photoOutput else { throw
                CameraControllerError.inputsAreInvalid
            }
            output.setPreparedPhotoSettingsArray([
                AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.hevc])
            ], completionHandler: nil)
            if captureSession.canAddOutput(output) { captureSession.addOutput(output) }
            captureSession.startRunning()
        }
        
        DispatchQueue(label: "prepare").async {
            do {
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            } catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                return
            }
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
}

extension CameraController {
    
    func displayPreview(on view: UIView) throws {
        guard captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }

        self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer.connection?.videoOrientation = .portrait
     
        view.layer.addSublayer(self.previewLayer)
        self.previewLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: view.frame.size)
    }
    
    func updatePreview(on view: UIView) {
        self.previewLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: view.frame.size)
    }
    
    func displayCapture(on view: UIView, capture: UIImage) {
        DispatchQueue.main.async {
            let imageView = UIImageView(image: capture)
            imageView.contentMode = .scaleAspectFill
            imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            view.addSubview(imageView)
        }
    }
    
    func switchCameraPosition() throws {
        guard let currentCameraInput = self.currentCameraInput,
            let newCamera = self.currentCameraPosition == .front ? self.rearCamera : self.frontCamera else {
                return
        }
        
        captureSession.removeInput(currentCameraInput)
        let newCameraPosition = self.currentCameraPosition == .front ? CameraPosition.rear : CameraPosition.front
        let newCameraInput = try AVCaptureDeviceInput(device: newCamera)
        if captureSession.canAddInput(newCameraInput) {
            captureSession.addInput(newCameraInput)
            self.currentCameraInput = newCameraInput
            self.currentCameraPosition = newCameraPosition
            self.currentCamera = newCamera
        } else {
            throw CameraControllerError.invalidOperation
        }
    }
    
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard captureSession.isRunning else {
            completion(nil, CameraControllerError.captureSessionIsMissing)
            return
        }
        let settings = AVCapturePhotoSettings()
        settings.flashMode = self.flashMode
        
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }
    
    func updateCameraSetting() {
        
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            self.photoCaptureCompletionBlock?(nil, error)
        } else if let imageData = photo.fileDataRepresentation() {
            let image = UIImage(data: imageData)
            self.photoCaptureCompletionBlock?(image, nil)
        } else {
            self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
        }
    }
}

extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func getCameraFrames() {
        self.videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        self.captureSession.addOutput(self.videoDataOutput)
        guard let connection = self.videoDataOutput.connection(with: AVMediaType.video),
            connection.isVideoOrientationSupported else { return }
        connection.videoOrientation = .portrait
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
        self.detectFace(in: frame)
    }
    
    func detectFace(in image: CVPixelBuffer) {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
            if let results = request.results as? [VNFaceObservation] {
                self.state.detectedFaceNumber.accept(results.count)
            }
        })
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
        try? imageRequestHandler.perform([faceDetectionRequest])
    }
}
