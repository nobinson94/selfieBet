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
    }
    
    let action = Action()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //openCameraButton.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        openAlbumButton.addTarget(self, action: #selector(openAlbum), for: .touchUpInside)
        setRx()
    }
    
    func setRx() {
        self.openCameraButton.rx.tap.bind(to: action.openCamera).disposed(by: disposeBag)
        
        action.openCamera
            .subscribe(onNext: { [weak self] _ in
                guard let cameraViewController = self?.storyboard?.instantiateViewController(identifier: "Main") as? CameraViewController else { return }
                self?.navigationController?.pushViewController(cameraViewController, animated: true)
            }).disposed(by: disposeBag)
    }

    func openCamera() {
        guard let cameraViewController = self.storyboard?.instantiateViewController(identifier: "Main") as? CameraViewController else { return }
        self.navigationController?.pushViewController(cameraViewController, animated: true)
    }
    
    @objc
    func openAlbum() {
        guard let albumViewController = self.storyboard?.instantiateViewController(identifier: "Main") as?
            AlbumViewController else { return }
        self.navigationController?.pushViewController(albumViewController, animated: true)
    }

}

