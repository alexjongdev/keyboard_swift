//
//  StickersDataProvider.swift
//  ROKOKeyboard
//
//  Created by Maslov Sergey on 21.10.16.
//  Copyright © 2016 ROKOLABS. All rights reserved.
//

import ROKOMobi

let kStickersExtensionName = "Stickers"
let kStickersDataFile = "StickersDataFile." + kStickersExtensionName
let kStickersWarmCacheKey = "isWarmCacheCopyed"
let kWarmDirectoryName = "WarmCache"
let kFirstTimeKey = "FirstTimeKey"

class StickersDataProvider: NSObject {
    var stickerPacks: [ROKOStickerPack]?
    
    func initWithDataSource(stickerPacks: [ROKOStickerPack]?) {
        guard let stickerPacks = stickerPacks else {
            return
        }

        let packs = stickerPacks // .sorted(by: { $0.isActive == true && $1.isActive == false } )
        
        if let _ = UserDefaults.standard.object(forKey: kFirstTimeKey) as? Int {
        } else {
            UserDefaults.standard.set(1, forKey: kFirstTimeKey)
            self.stickerPacks = packs
        }
        
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: packs)
        do {
            try encodedData.write(to: storePathURL)
        } catch {
             print("write file error: \(error)")
        }
    }
    
    func loadData() -> Bool {
        guard let packs = NSKeyedUnarchiver.unarchiveObject(withFile: storePathURL.path) as? [ROKOStickerPack] else {
            return false
        }
        stickerPacks = packs
        return packs.count > 0
    }
    
    fileprivate var storePathURL: URL {
        return URL.getStickersDirectory.appendingPathComponent(kStickersDataFile)
    }
}

extension StickersDataProvider: StickerDataSource {
    func numberOfStickerPacks() -> Int {
        guard let stickerPacks = stickerPacks else {
            return 0
        }
        return stickerPacks.count
    }
    
    func numberOfStickersInPack(at packIndex: Int) -> Int {
        guard let stickerPacks = stickerPacks else {
            return 0
        }
        
        guard packIndex < stickerPacks.count else {
            return 0
        }
 
        let pack = stickerPacks[packIndex]
        return pack.stickers.count
    }
    
    
    func composer(infoForStickerPackAt packIndex: Int) -> ROKOStickerPack {
//        guard packIndex >= 0 && packIndex < stickerPacks!.count else {
//            return nil
//        }
		
        let pack = stickerPacks![packIndex]
        return pack
    }
    
    func composer(infoForStickerAt stickerIndex: Int, pack packIndex: Int) -> ROKOSticker {
//        guard packIndex >= 0 && packIndex < stickerPacks!.count else {
//            return nil
//        }
		
        let pack = stickerPacks![packIndex]
        let sticker = pack.stickers[stickerIndex] as! ROKOSticker
		return sticker
    }
}

extension StickersDataProvider {
    func saveWarmCache() {
        guard let stickerPacks = stickerPacks else {
            return
        }
        let packs = [stickerPacks.first!]
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: packs)
        do {
            try encodedData.write(to: storePathURL)
        } catch {
            print("write file error: \(error)")
        }
        
        for pack in packs {
            let url = FileManager.folderURLForPack(pack: pack)
            print(url.absoluteString)
            
            for sticker in (pack.stickers as! [ROKOSticker]) {
                let urls = [FileManager.imageURL(forSticker: sticker, inPack: pack),
                            FileManager.iconURL(forSticker: sticker, inPack: pack),
                            FileManager.packIconURL(forPack: pack),
                            FileManager.selectedPackIconURL(forPack: pack)]
                
                for url in urls {
                    let array = url.path.components(separatedBy: "/")
                    let packName = array[array.count - 2]
                    let stickerName = array[array.count - 1]
                    let newName = "\(packName).\(stickerName).\(kStickersExtensionName)"
                    
                    let destinationURL = URL.getWarmStickersDirectory
                    let atPath = url.path
                    let toPath = destinationURL.path.appending("/").appending(newName)
                    do {
                        try FileManager.default.copyItem(atPath: atPath, toPath: toPath)
                    } catch {
                    }
                }
            }
        }
        let atPath = storePathURL.path
        let destinationURL = URL.getWarmStickersDirectory
        let toPath = destinationURL.path.appending("/").appending(kStickersDataFile)
        print("save WARM cache to \(toPath)")
        do {
            try FileManager.default.copyItem(atPath: atPath, toPath: toPath)
        } catch {
        }
    }
    
	func getWarmCache(completionBlock:@escaping ()->Void) {
        if let _ = UserDefaults.standard.object(forKey: kStickersWarmCacheKey) as? Bool {
            return
        }
        
        UserDefaults.standard.set(true, forKey: kStickersWarmCacheKey)
        
        let docPath = Bundle.main.resourcePath!
        let fileManager = FileManager.default
        let dataFile = docPath.appending("/").appending(kStickersDataFile)
        print(dataFile)
        if fileManager.fileExists(atPath: dataFile) {
            do {
                let toPath = URL.getStickersDirectory.path.appending("/").appending(kStickersDataFile)
                try fileManager.copyItem(atPath: dataFile, toPath: toPath)
            } catch {
                print("copy \(kStickersDataFile) error: \(error)")
            }
            
            DispatchQueue.global(qos: .background).async {
                do {
                    let filesFromBundle = try fileManager.contentsOfDirectory(atPath: docPath)
                    let stickerFiles = filesFromBundle.filter{ $0.hasSuffix(kStickersExtensionName) }
                    for stickerFile in stickerFiles {
                        guard stickerFile != kStickersDataFile else {
                            continue
                        }
                        let atPath = docPath.appending("/").appending(stickerFile)
                        
                        let array = stickerFile.components(separatedBy: ".")
                        let packName = array[0]
                        let stickerName = array[1]
                        
                        let paths = fileManager.urls(for: .cachesDirectory, in:.userDomainMask)
                        let newDirectory = paths.first!.appendingPathComponent(kStickersDirectoryName, isDirectory: true).appendingPathComponent(packName, isDirectory: true)
                        
                        if !fileManager.fileExists(atPath: newDirectory.path) {
                            do {
                                try fileManager.createDirectory(at: newDirectory, withIntermediateDirectories: true, attributes: nil)
                            } catch {
                            }
                        }
                        
                        
                        let toPath = newDirectory.appendingPathComponent(stickerName).path
                        do {
                            try fileManager.copyItem(atPath: atPath, toPath: toPath)
                        } catch {
                            print("copy \(stickerFile) error: \(error)")
                        }
                    }
					DispatchQueue.main.async {
						completionBlock()
					}
                } catch {
                    print("write file error: \(error)")
                }
            }
            
        }
    }
    
}
