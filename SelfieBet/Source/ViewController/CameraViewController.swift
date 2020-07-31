//
//  CameraViewController.swift
//  SelfieBet
//
//  Created by 용태권 on 2020/07/07.
//  Copyright © 2020 Yongtae.Kwon. All rights reserved.
//

import AVFoundation
import Photos
import UIKit

class CameraViewController: UIViewController {
    let cameraController = CameraController()
 
    @IBOutlet weak var captureButton: UIButton?
    @IBOutlet weak var capturePreviewView: UIView?
    @IBOutlet weak var toggleCameraButton: UIButton!
    @IBOutlet weak var recognizedTargetNumber: UILabel!
    @IBOutlet weak var targetMessageButton: UIButton!
    
//    @IBOutlet fileprivate var toggleFlashButton: UIButton!
 
    override var prefersStatusBarHidden: Bool { return true }
}
 
extension CameraViewController {
    override func viewDidLoad() {
        self.cameraControllerSetup()
    }
    
    func cameraControllerSetup() {
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            guard let capturePreviewView = self.capturePreviewView else { return }
            try? self.cameraController.displayPreview(on: capturePreviewView)
        }
    }
    
    func savePhoto(image: UIImage, completion: ((Bool, Error?) -> ())? = nil) {
        PHPhotoLibrary.shared().performChanges( {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }, completionHandler: completion)
    }
    
    @IBAction func capturePhoto(_ sender: UIButton) {
        cameraController.captureImage { [weak self] (image, error) in
            guard let image = image else {
                return
            }
            self?.savePhoto(image: image) { [weak self] (isSaved, _) in
                if isSaved, let previewView = self?.capturePreviewView {
                    self?.cameraController.displayCapture(on: previewView, capture: image)
                }
            }
        }
    }
    
    @IBAction func toogleCameraPosition(_ sender: UIButton) {
        cameraController.toggleCameraPosition()
    }
}


