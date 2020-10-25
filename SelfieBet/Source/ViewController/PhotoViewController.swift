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
    @IBOutlet weak var faceDetectionLayerView: UIView!
    
    var resultImage: UIImage?
    var isMirrored: Bool?
    var drawings: [CAShapeLayer] = []
    
    struct Action {
        let openCamera = PublishSubject<Void>()
        let openPhotoLibrary = PublishSubject<Void>()
    }
    
    let action = Action()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        setRx()
        resultImageView?.contentMode = .scaleAspectFill
        resultImageView?.image = resultImage
        descriptionLabel.text = ""
        drawings.forEach({ [weak self] faceBoundingBox in
            self?.faceDetectionLayerView.layer.addSublayer(faceBoundingBox)
        })
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
        
        startRandomButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.animateRandomWork()
            }).disposed(by: disposeBag)
        
    }
    
    func animateRandomWork() {
        UIView.animateKeyframes(withDuration: Double(self.drawings.count)*3, delay: 0, options: [],
                                animations: {
                                    var startTime = 0.0
                                    var duration = 1.0/Double(self.drawings.count)

                                    self.drawings.enumerated().forEach { (index, shape) in
                                        UIView.addKeyframe(withRelativeStartTime: Double(index)*duration, relativeDuration: duration) {
                                            shape.strokeColor = UIColor.red.cgColor
                                        }
                                    }
        },
                                completion: nil)
    }
}
