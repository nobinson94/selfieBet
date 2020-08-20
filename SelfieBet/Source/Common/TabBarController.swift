//
//  TabBarController.swift
//  SelfieBet
//
//  Created by 용태권 on 2020/08/17.
//  Copyright © 2020 Yongtae.Kwon. All rights reserved.
//

import UIKit
import RxSwift

class TabBarController: UITabBarController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TabBarController: UITabBarControllerDelegate {
    
}
