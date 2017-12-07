//
//  FileManager+Stickers.swift
//  ROKOKeyboard
//
//  Created by Alexey Golovenkov on 01.11.16.
//  Copyright © 2016 ROKOLABS. All rights reserved.
//

import Foundation
import ROKOMobi

let kStickersDirectoryName = "StickerCache"

extension FileManager {
    
    class func create(folder url: URL) {
        let manager = FileManager.default
        
        if !manager.fileExists(atPath: url.path) {
            do {
                try manager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                
            }
        }
    }
    
    class func stickerPackCacheURL() -> URL {
        let manager = FileManager.default
        let paths = manager.urls(for: .cachesDirectory, in:.userDomainMask)
        let stickerDirectory = paths.first!.appendingPathComponent(kStickersDirectoryName, isDirectory: true)
        self.create(folder: stickerDirectory)
        
        return stickerDirectory
    }
    
    class func folderURLForPack(pack: ROKOStickerPack) -> URL {
        let folderURL = self.stickerPackCacheURL()
        let packFolderURL = folderURL.appendingPathComponent("Pack_\(pack.objectId.stringValue)")
        self.create(folder: packFolderURL)
        return packFolderURL
    }
    
    class func imageURL(forSticker sticker: ROKOSticker, inPack pack: ROKOStickerPack) -> URL {
        let folderURL = self.folderURLForPack(pack: pack)
        let imageURL = folderURL.appendingPathComponent("image_\(sticker.imageInfo.objectId.stringValue)")
        return imageURL
    }
    
    class func iconURL(forSticker sticker: ROKOSticker, inPack pack: ROKOStickerPack) -> URL {
        let folderURL = self.folderURLForPack(pack: pack)
        let iconURL = folderURL.appendingPathComponent("icon_\(sticker.imageInfo.objectId.stringValue)")
        return iconURL
    }
    
    class func packIconURL(forPack pack: ROKOStickerPack) -> URL {
        let folderURL = self.folderURLForPack(pack: pack)
        let hash = abs(pack.unselectedIcon.imageURL.hash)
        let iconURL = folderURL.appendingPathComponent("packIcon_\(hash)")
        return iconURL
    }
    
    class func selectedPackIconURL(forPack pack: ROKOStickerPack) -> URL {
        let folderURL = self.folderURLForPack(pack: pack)
        let hash = abs(pack.selectedIcon.imageURL.hash)
        let iconURL = folderURL.appendingPathComponent("selectedPackIcon_\(hash)")
        return iconURL
    }
    
    class func isLoaded(_ sticker: ROKOSticker, inPack pack: ROKOStickerPack) -> Bool {
        let imageURL = self.imageURL(forSticker: sticker, inPack: pack)
        let iconURL = self.iconURL(forSticker: sticker, inPack: pack)
        return FileManager.default.fileExists(atPath: imageURL.path) && FileManager.default.fileExists(atPath: iconURL.path)
    }
    
    class func isIconLoaded(inPack pack: ROKOStickerPack) -> Bool {
        let imageURL = self.packIconURL(forPack: pack)
        return FileManager.default.fileExists(atPath: imageURL.path)
    }
    
    class func isSelectedIconLoaded(inPack pack: ROKOStickerPack) -> Bool {
        let imageURL = self.selectedPackIconURL(forPack: pack)
        return FileManager.default.fileExists(atPath: imageURL.path)
    }
}
