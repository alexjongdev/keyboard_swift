//
//  StickerLoader.swift
//  ROKOKeyboard
//
//  Created by Alexey Golovenkov on 01.11.16.
//  Copyright © 2016 ROKOLABS. All rights reserved.
//

import UIKit
import ROKOMobi

let kIconSize: CGFloat = 100.0

class StickerLoader: NSObject {
    let pack: ROKOStickerPack
    var block: StickerLoadCompletion
    var filesToLoad = 0
    
    init (stickerPack: ROKOStickerPack, completion completionBlock:@escaping StickerLoadCompletion) {
        self.pack = stickerPack
        self.block = completionBlock
        super.init()
        DispatchQueue.global(qos: .background).async {
            self.loadPack()
        }
    }
    
    func loadPack() {
        let stickers = self.pack.stickers as! [ROKOSticker]
        for sticker in stickers {
            self.loadIfNeeded(sticker)
        }
        
        self.loadIconIfNeeded(active: true)
        self.loadIconIfNeeded(active: false)
        
        let lastImageLoaded = self.filesToLoad == 0
        if lastImageLoaded {
            DispatchQueue.main.async {
                self.block(self.pack)
            }
        }
    }
    
    func loadIfNeeded(_ sticker: ROKOSticker) {
        if FileManager.isLoaded(sticker, inPack: self.pack) {
            return
        }
        let url = URL(string: sticker.imageInfo.imageURL)
        guard url != nil else {
            return
        }
        filesToLoad += 1
        let task = URLSession.shared.dataTask(with: url!) { (imageData, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = imageData, error == nil,
                let image = UIImage(data: data)
                else { return }
            do {
                try data.write(to: FileManager.imageURL(forSticker: sticker, inPack: self.pack))
                let bigDimension = image.size.width > image.size.height ? image.size.width : image.size.height
                let scale: CGFloat = kIconSize / bigDimension
                let icon = image.resizeImage(scale: scale)!
                let iconData = UIImagePNGRepresentation(icon)!
                try iconData.write(to: FileManager.iconURL(forSticker: sticker, inPack: self.pack))
            } catch {
                
            }
            self.filesToLoad = self.filesToLoad - 1
            let lastImageLoaded = self.filesToLoad == 0
            if lastImageLoaded {
                DispatchQueue.main.async {
                    self.block(self.pack)
                }
            }
        }
        task.resume()
    }
    
    func loadIconIfNeeded(active: Bool) {
        let isLoaded = active ? FileManager.isSelectedIconLoaded(inPack: self.pack) : FileManager.isIconLoaded(inPack: self.pack)
        if isLoaded {
            return // Nothing to load
        }
        guard let urlString = active ? self.pack.selectedIcon.imageURL : self.pack.unselectedIcon.imageURL else {
            return
        }
        guard let url = URL(string: urlString) else {
            return
        }
        filesToLoad += 1
        
        let task = URLSession.shared.dataTask(with: url) { (imageData, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = imageData, error == nil
                else { return }
            do {
                let urlToSave = active ? FileManager.selectedPackIconURL(forPack: self.pack) : FileManager.packIconURL(forPack: self.pack)
                try data.write(to: urlToSave)
            } catch {
                
            }
            self.filesToLoad = self.filesToLoad - 1
            let lastImageLoaded = self.filesToLoad == 0
            if lastImageLoaded {
                DispatchQueue.main.async {
                    self.block(self.pack)
                }
            }
        }
        task.resume()
    }
}


extension URL {
    static var getStickersDirectory: URL {
        let manager = FileManager.default
        let paths = manager.urls(for: .cachesDirectory, in:.userDomainMask)
        let stickersDirectory = paths.first!.appendingPathComponent(kStickersDirectoryName, isDirectory: true)
        
        if !manager.fileExists(atPath: stickersDirectory.path) {
            do {
                try manager.createDirectory(at: stickersDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                
            }
        }
        
        return stickersDirectory
    }
    
    static var getWarmStickersDirectory: URL {
        let manager = FileManager.default
        let paths = manager.urls(for: .cachesDirectory, in:.userDomainMask)
        let stickersDirectory = paths.first!.appendingPathComponent(kWarmDirectoryName, isDirectory: true)
        
        if !manager.fileExists(atPath: stickersDirectory.path) {
            do {
                try manager.createDirectory(at: stickersDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                
            }
        }
        
        return stickersDirectory
    }
    
}
