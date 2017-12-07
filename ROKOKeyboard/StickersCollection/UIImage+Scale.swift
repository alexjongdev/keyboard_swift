//
//  UIImage+Scale.swift
//  ROKOKeyboard
//
//  Created by Maslov Sergey on 21.10.16.
//  Copyright © 2016 ROKOLABS. All rights reserved.
//

import UIKit

extension UIImage {
    func resizeImage(scale: CGFloat) -> UIImage? {
        let newWidth = scale * self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
