//
//  CopyboardManager.swift
//  Keyboard
//
//  Created by Maslov Sergey on 08.06.16.
//  Copyright © 2016 ROKOLABS. All rights reserved.
//
import UIKit

class ClipboardManager {
    class func copy(_ image: UIImage) {
        let pasteboard = UIPasteboard.general
        if let type = UIPasteboardTypeListImage[0] as? String {
            if !type.isEmpty {
                if let data = UIImagePNGRepresentation(image) {
                    pasteboard.setData(data, forPasteboardType: type)
                }
            }
        }
    }
    
    class func isOpenAccessGranted() -> Bool {
        return UIPasteboard.general.isKind(of: UIPasteboard.self)
    }
}
