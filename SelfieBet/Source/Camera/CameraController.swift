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
    func captureImage(_ image: UIImage)
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
    var videoOutput: AVCaptureVideoDataOutput?
    
    lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    var flashMode: AVCaptureDevice.FlashMode = .off
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    var videoCaptureCompletionBlock: ((CVImageBuffer?, Error?) -> Void)?
    var cameraSetting: AVCaptureDevice.Format?
    
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
            
        }
        
        func configureVideoOutput() {
            self.videoOutput = AVCaptureVideoDataOutput()
            self.videoOutput?.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
            self.videoOutput?.alwaysDiscardsLateVideoFrames = true
            self.videoOutput?.setSampleBufferDelegate(self, queue: DispatchQueue.main)
            guard let output = self.videoOutput else { return }
            if captureSession.canAddOutput(output) { captureSession.addOutput(output) }
            guard let connection = output.connection(with: AVMediaType.video),
                connection.isVideoOrientationSupported else { return }
            connection.videoOrientation = .portrait
        }
        
        DispatchQueue(label: "prepare").async {
            do {
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
                configureVideoOutput()
                self.captureSession.startRunning()
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
        self.previewLayer.frame = view.bounds
    }
    
    func updatePreview(on view: UIView) {
        self.previewLayer.frame = view.bounds
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
        // photoCaptureCompletionBlock 부분을 delegate로 바꿔주자
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
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            self.videoCaptureCompletionBlock?(nil, nil)
            return
        }
        self.videoCaptureCompletionBlock?(buffer, nil)
    }
       
}
