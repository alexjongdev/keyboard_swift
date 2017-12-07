//
//  StickerDataSource.swift
//  ROKOKeyboard
//
//  Created by Alexey Golovenkov on 01.11.16.
//  Copyright © 2016 ROKOLABS. All rights reserved.
//

import Foundation
import ROKOMobi

public protocol StickerDataSource : class {
	
	func numberOfStickerPacks() -> Int
	
	func numberOfStickersInPack(at packIndex: Int) -> Int
	
	func composer(infoForStickerPackAt packIndex: Int) -> ROKOStickerPack
	
	func composer(infoForStickerAt stickerIndex: Int, pack packIndex: Int) -> ROKOSticker
}
