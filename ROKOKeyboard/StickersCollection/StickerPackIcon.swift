//
//  StickerPackIcon.swift
//  ROKOKeyboard
//
//  Created by Maslov Sergey on 18.10.16.
//  Copyright © 2016 ROKOLABS. All rights reserved.
//

import UIKit
import ROKOMobi

class StickerPackIcon: UICollectionViewCell {
    static let identifier = "StickerPackIcon"
    
    @IBOutlet weak var stickerImage: UIImageView!
    private var pack: ROKOStickerPack?
    
    var isPackSelected: Bool = false
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.stickerImage.image = nil
    }
    
    func configure(pack:ROKOStickerPack, isSelected: Bool) {
        self.pack = pack
        self.isPackSelected = isSelected
        updateIcon()
    }
    
    func setPackSelected(_ newValue: Bool = true) {
        isPackSelected = newValue
        updateIcon()
    }
    
    private func updateIcon() {
        if isPackSelected {
            stickerImage.image = StickerCache.selectedPackIcon(fromPack: pack!)
        } else {
            stickerImage.image = StickerCache.packIcon(fromPack: pack!)
        }
    }
}
