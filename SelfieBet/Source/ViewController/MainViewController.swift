//
//  ViewController.swift
//  SelfieBet
//
//  Created by 용태권 on 2020/06/04.
//  Copyright © 2020 Yongtae.Kwon. All rights reserved.
//

import AVFoundation
import RxSwift
import RxCocoa
import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var openCameraButton: UIButton!
    @IBOutlet weak var openAlbumButton: UIButton!
    
    struct Action {
        let openCamera = PublishSubject<Void>()
        let openPhotoLibrary = PublishSubject<Void>()
    }
    
    let action = Action()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRx()
    }
    
    func setRx() {
        self.openCameraButton.rx.tap
            .bind(to: action.openCamera)
            .disposed(by: disposeBag)
        
        self.openAlbumButton.rx.tap
            .bind(to: action.openPhotoLibrary)
            .disposed(by: disposeBag)
        
        action.openCamera
            .subscribe(onNext: { [weak self] _ in
                guard let cameraViewController = self?.storyboard?.instantiateViewController(withIdentifier: "Camera") as? CameraViewController else { return }
                self?.navigationController?.pushViewController(cameraViewController, animated: true)
            }).disposed(by: disposeBag)
        
        action.openPhotoLibrary
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                guard let imagePickerViewController = self.storyboard?.instantiateViewController(withIdentifier: "ImagePicker") as? ImagePickerViewController else { return }
                self.present(imagePickerViewController, animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
}
