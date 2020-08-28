//
//  ModalController.swift
//  SelfieBet
//
//  Created by USER on 2020/08/25.
//  Copyright © 2020 Yongtae.Kwon. All rights reserved.
//

import Foundation
import UIKit

class ModalController: NSObject {
    
    override init() {
        super.init()
    }
    
    class func show() {
        guard let window = UIApplication.shared.keyWindow else { return }
        
        UIView.animate(withDuration: 0.3) {
            
        }
    }
}


class ModalView: UIView {
    
}
