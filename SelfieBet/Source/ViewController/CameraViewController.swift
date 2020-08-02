//
//  CameraViewController.swift
//  SelfieBet
//
//  Created by 용태권 on 2020/07/07.
//  Copyright © 2020 Yongtae.Kwon. All rights reserved.
//

import AVFoundation
import Photos
import RxSwift
import RxCocoa
import UIKit

class CameraViewController: UIViewController {
    let cameraController = CameraController()
 
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var capturePreviewView: UIView?
    @IBOutlet weak var toggleCameraButton: UIButton!
    @IBOutlet weak var recognizedTargetNumber: UILabel!
    @IBOutlet weak var targetMessageButton: UIButton!
    
//    @IBOutlet fileprivate var toggleFlashButton: UIButton!
 
    override var prefersStatusBarHidden: Bool { return true }
    
    struct Action {
        let capturePhoto = PublishSubject<Void>()
        let savePhoto = PublishSubject<Void>()
        let toggleCameraPosition = PublishSubject<Void>()
    }
    
    struct State {
        
    }
    
    let action = Action()
    let state = State()
    let disposeBag = DisposeBag()
}
 
extension CameraViewController {
    
    override func viewDidLoad() {
        self.cameraControllerSetup()
        self.setRx()
    }
    
    func setRx() {
        action.capturePhoto
            .subscribe(onNext: { [weak self] _ in
                self?.cameraController.captureImage { [weak self] (image, error) in
                    guard let image = image else {
                        return
                    }
                    self?.savePhoto(image: image) { [weak self] (isSaved, _) in
                        if isSaved, let previewView = self?.capturePreviewView {
                            self?.cameraController.displayCapture(on: previewView, capture: image)
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        action.toggleCameraPosition
            .subscribe(onNext: { [weak self] _ in
                try? self?.cameraController.switchCameraPosition()
            })
            .disposed(by: disposeBag)
        
        captureButton.rx.tap
            .bind(to: self.action.capturePhoto)
            .disposed(by: disposeBag)
        
        toggleCameraButton.rx.tap
            .bind(to: self.action.toggleCameraPosition)
            .disposed(by: disposeBag)
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
}


