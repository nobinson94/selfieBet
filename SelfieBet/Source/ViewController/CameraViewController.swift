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
    @IBOutlet weak var photoLibraryOpenButton: UIButton!
    
    
//    @IBOutlet fileprivate var toggleFlashButton: UIButton!
 
    override var prefersStatusBarHidden: Bool { return true }
    
    struct Action {
        let capturePhoto = PublishSubject<Void>()
        let savePhoto = PublishSubject<Void>()
        let toggleCameraPosition = PublishSubject<Void>()
        let openPhotoLibrary = PublishSubject<Void>()
        let pickPhoto = PublishSubject<Void>()
    }
    
    struct State {
        
    }
    
    let action = Action()
    let state = State()
    let disposeBag = DisposeBag()
}
 
extension CameraViewController {
    
    override func viewDidLoad() {
        cameraController.getCameraFrames()
        self.cameraControllerSetup()
        self.setRx()
        setView()
    }
    
    func setRx() {
        action.capturePhoto
            .subscribe(onNext: { [weak self] _ in
                self?.cameraController.captureImage { [weak self] (image, error) in
                    guard let image = image else {
                        return
                    }
                    DispatchQueue.main.async {
                        guard let photoViewController = self?.storyboard?.instantiateViewController(identifier: "Photo") as? PhotoViewController else { return }
                        photoViewController.resultImage = image
                        self?.navigationController?.pushViewController(photoViewController, animated: true)
                    }
                    ///// todo : Save Option 고려하기
//                    self?.savePhoto(image: image) { [weak self] (isSaved, _) in
//                        if isSaved {
//                            DispatchQueue.main.async {
//                                guard let photoViewController = self?.storyboard?.instantiateViewController(identifier: "Photo") as? PhotoViewController else { return }
//                                photoViewController.resultImage = image
//                                self?.navigationController?.pushViewController(photoViewController, animated: true)
//                            }
//                        }
//                    }
                }
            })
            .disposed(by: disposeBag)
        
        action.toggleCameraPosition
            .subscribe(onNext: { [weak self] _ in
                try? self?.cameraController.switchCameraPosition()
            })
            .disposed(by: disposeBag)
        
        action.openPhotoLibrary
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                guard let imagePickerViewController = self.storyboard?.instantiateViewController(identifier: "ImagePicker") as? ImagePickerViewController else { return }
                self.present(imagePickerViewController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        captureButton.rx.tap
            .bind(to: self.action.capturePhoto)
            .disposed(by: disposeBag)
        
        toggleCameraButton.rx.tap
            .bind(to: self.action.toggleCameraPosition)
            .disposed(by: disposeBag)
        
        photoLibraryOpenButton.rx.tap
            .bind(to: self.action.openPhotoLibrary)
            .disposed(by: disposeBag)
        
        cameraController.state.detectedFaceNumber.asObservable()
            .distinctUntilChanged()
            .observeOn(MainScheduler())
            .subscribe(onNext: { [weak self] number in
                if number == 0 {
                    self?.recognizedTargetNumber.text = "인식된 사람이 없어서 내기를 진행할 수 없습니다"
                } else {
                    self?.recognizedTargetNumber.text = "내기에 참가하는 사람은 \(number)명 입니다!"
                }
            }).disposed(by: disposeBag)
    }
    
    func setView() {
        self.toggleCameraButton.setImage(UIImage(imageLiteralResourceName: "cameraSwitchIcon"), for: .normal)
        self.captureButton.setImage(UIImage(imageLiteralResourceName: "cameraApertureIcon"), for: .normal)
        self.photoLibraryOpenButton.setImage(UIImage(imageLiteralResourceName: "cameraAlbumIcon"), for: .normal)
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

extension CameraViewController {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let capturePreviewView = self.capturePreviewView else { return }
        cameraController.updatePreview(on: capturePreviewView)
    }
}
