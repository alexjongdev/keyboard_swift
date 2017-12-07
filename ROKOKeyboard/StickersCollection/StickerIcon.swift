//
//  StickerIcon.swift
//  ROKOKeyboard
//
//  Created by Maslov Sergey on 18.10.16.
//  Copyright © 2016 ROKOLABS. All rights reserved.
//

import UIKit
import ROKOMobi

class StickerIcon: UICollectionViewCell {
    static let identifier = "StickerIcon"
    
    @IBOutlet weak var stickerImage: UIImageView!
	var pack: ROKOStickerPack?
    var sticker: ROKOSticker?

    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.stickerImage.image = nil
    }
	
	func configure(for sticker: ROKOSticker, inPack pack:ROKOStickerPack) {
		self.pack = pack
		self.sticker = sticker
		self.stickerImage.image = StickerCache.icon(sticker: sticker, fromPack: pack)
	}
}
