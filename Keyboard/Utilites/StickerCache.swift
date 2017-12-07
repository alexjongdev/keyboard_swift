//
//  StickerCache.swift
//  ROKOKeyboard
//
//  Created by Alexey Golovenkov on 01.11.16.
//  Copyright © 2016 ROKOLABS. All rights reserved.
//

import UIKit
import ROKOMobi

typealias StickerLoadCompletion = (ROKOStickerPack) -> Void

class StickerCache: NSObject {
    
    static var activeLoadingSessions = [Int: StickerLoader]()
    
    class func load(stickerPack pack: ROKOStickerPack, completion closure: @escaping StickerLoadCompletion) {
        let loader = StickerLoader(stickerPack: pack) {(pack) in
            closure(pack)
            activeLoadingSessions[pack.objectId as! Int] = nil
        }
        activeLoadingSessions[pack.objectId as! Int] = loader
    }
    
    class func sticker(sticker: ROKOSticker, fromPack pack:ROKOStickerPack) -> UIImage? {
        let url = FileManager.imageURL(forSticker: sticker, inPack: pack)
        return self.imageWithURL(url)
    }
    
    class func icon(sticker: ROKOSticker, fromPack pack:ROKOStickerPack) -> UIImage? {
        let url = FileManager.iconURL(forSticker: sticker, inPack: pack)
        return self.imageWithURL(url)
    }
    
    class func packIcon(fromPack pack:ROKOStickerPack) -> UIImage? {
        let url = FileManager.packIconURL(forPack: pack)
        return self.imageWithURL(url)
    }
    
    class func selectedPackIcon(fromPack pack:ROKOStickerPack) -> UIImage? {
        let url = FileManager.selectedPackIconURL(forPack: pack)
        return self.imageWithURL(url)
    }
    
    private class func imageWithURL(_ url: URL) -> UIImage? {
        var imageData: Data? = nil
        do {
            try imageData = Data(contentsOf: url)
        } catch {
            return nil
        }
        if imageData == nil {
            return nil
        }
        return UIImage(data: imageData!)
    }
}
