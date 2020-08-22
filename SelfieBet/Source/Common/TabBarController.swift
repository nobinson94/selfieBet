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
        self.tabBar.barTintColor = .black
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        print(tabBar.bounds)
        print(tabBar.frame)
        tabBar.items?.forEach { item in
            item.image = nil
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
