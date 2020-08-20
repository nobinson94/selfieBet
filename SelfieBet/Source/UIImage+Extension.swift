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
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!

        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!

        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)

        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
}
