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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        openCameraButton.addTarget(self, action: #selector(onTapButton), for: .touchUpInside)
        
    }
     
    @objc
    func onTapButton() {
        guard let cameraViewController = self.storyboard?.instantiateViewController(identifier: "Main") as? CameraViewController else { return }
        self.present(cameraViewController, animated: true, completion: nil)
    }

}

