//
//  PhotoViewController.swift
//  SelfieBet
//
//  Created by 용태권 on 2020/08/05.
//  Copyright © 2020 Yongtae.Kwon. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import Photos

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var resultImageView: UIImageView?
    @IBOutlet weak var openCameraButton: UIButton!
    @IBOutlet weak var openPhotoLibraryButton: UIButton!
    
    var resultImage: UIImage?
    
    struct Action {
        let openCamera = PublishSubject<Void>()
        let openPhotoLibrary = PublishSubject<Void>()
    }
    
    let action = Action()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        setRx()
        resultImageView?.image = resultImage
    }
    
    func setRx() {
        self.openCameraButton.rx.tap
            .bind(to: action.openCamera)
            .disposed(by: disposeBag)
        
        self.openPhotoLibraryButton.rx.tap
            .bind(to: action.openPhotoLibrary)
            .disposed(by: disposeBag)
        
        action.openCamera
            .subscribe(onNext: { [weak self] _ in
                guard let cameraViewController = self?.storyboard?.instantiateViewController(withIdentifier: "Camera") as? CameraViewController else { return }
                self?.dismiss(animated: true, completion: {
                    self?.navigationController?.pushViewController(cameraViewController, animated: true)
                })
                
            }).disposed(by: disposeBag)
        
        action.openPhotoLibrary
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                guard let imagePickerViewController = self.storyboard?.instantiateViewController(withIdentifier: "ImagePicker") as? ImagePickerViewController else { return }
                self.present(imagePickerViewController, animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
}
