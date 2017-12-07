//
//  Utilites.swift
//  ROKOKeyboard
//
//  Created by Maslov Sergey on 11.10.16.
//  Copyright © 2016 ROKOLABS. All rights reserved.
//

import UIKit

extension UIColor {
    
    class var rokoLightColor: UIColor {
        return UIColor(red: 210/255.0, green: 230/255.0, blue: 243/255.0, alpha: 1.0)
    }
    
    class var rokoDarkColor: UIColor {
        return UIColor(red: 31/255.0, green: 131/255.0, blue: 197/255.0, alpha: 1.0)
    }
    
    class var rokoDeepColor: UIColor {
        return UIColor(red: 32/255.0, green: 59/255.0, blue: 104/255.0, alpha: 0.5)
    }
}

class Utilites {

    class func getFullImage(url: URL) -> UIImage? {
        let hash = url.absoluteString.hash
        let pathURL = URL.getStickersDirectory.appendingPathComponent("\(hash)." + kStickersExtensionName)
        
        if let data = FileManager.default.contents(atPath: pathURL.path) {
            if let image = UIImage(data: data) {
                return image
            }
        }
        
        return nil
    }
}
