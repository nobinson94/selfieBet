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
    @IBOutlet weak var startRandomButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var resultImage: UIImage?
    var isMirrored: Bool?
    
    struct Action {
        let openCamera = PublishSubject<Void>()
        let openPhotoLibrary = PublishSubject<Void>()
    }
    
    let action = Action()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        setRx()
        resultImageView?.contentMode = .scaleAspectFit
        resultImageView?.image = resultImage
        if isMirrored ?? false {
            resultImageView?.transform = CGAffineTransform(scaleX: -1, y: 1);
        }
        startRandomButton.layer.cornerRadius = 10
    }
    
    func setRx() {
        dismissButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
        
    }
}
