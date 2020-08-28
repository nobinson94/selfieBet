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
        self.setTabBarTheme()
        // Do any additional setup after loading the view.
    }
    
    func setTabBarTheme() {
//        tabBar.barTintColor = UIColor(red: 112, green: 112, blue: 112, alpha: 0.5)
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        let height = tabBar.frame.height
        tabBar.items?.forEach { item in
            item.image = UIImage()
            item.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -height/2 + 16)
            item.selectedImage = nil
            let attributes: [NSAttributedString.Key: Any] = [
                .font : UIFont.systemFont(ofSize: 16, weight: .medium)
            ]
            item.setTitleTextAttributes(attributes, for: .normal)
        }
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
