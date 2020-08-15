//
//  UIImage+Extension.swift
//  SelfieBet
//
//  Created by 용태권 on 2020/08/11.
//  Copyright © 2020 Yongtae.Kwon. All rights reserved.
//

import UIKit

extension UIImage {
    
    func resize(scale: CGFloat) -> UIImage? {
        let image = self
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let size = image.size.applying(transform)
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resultImage
    }
    
    func resize(width: CGFloat) -> UIImage? {
        let scale = width / self.size.width
        return self.resize(scale: scale)
    }
    
    func resize(scale: CGFloat, completionHandler: ((UIImage?) -> Void)?) {
        let image = self
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let size = image.size.applying(transform)
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let completion = completionHandler {
            completion(resultImage)
        }
    }
    
    func resize(width: CGFloat, completionHandler: ((UIImage?) -> Void)?) {
        let scale = width / self.size.width
        self.resize(scale: scale, completionHandler: completionHandler)
    }
}
