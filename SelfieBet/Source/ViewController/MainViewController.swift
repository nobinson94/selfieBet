//
//  ViewController.swift
//  SelfieBet
//
//  Created by 용태권 on 2020/06/04.
//  Copyright © 2020 Yongtae.Kwon. All rights reserved.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController {
    
    
    @IBOutlet weak var openCameraButton: UIButton!
    @IBOutlet weak var openAlbumButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openCameraButton.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        openAlbumButton.addTarget(self, action: #selector(openAlbum), for: .touchUpInside)
        
    }
     
    @objc
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

