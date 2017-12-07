//
//  StickerPacksPanel.swift
//  ROKOKeyboard
//
//  Created by Maslov Sergey on 18.10.16.
//  Copyright © 2016 ROKOLABS. All rights reserved.
//

import UIKit
import ROKOMobi

let stickerIconSize: CGFloat = 30.0
let stickerSpacing: CGFloat = 17.0

protocol StickersPanelDelegate: class {
    func didSelect(image: UIImage!, pack: ROKOStickerPack, stickerInfo: ROKOSticker)
}

class StickersPanel: UIView {
    var dataSource: StickerDataSource?
    weak var delegate: StickersPanelDelegate?
    var collectionView: UICollectionView!
    
    var selectedPackIndex: Int = 0
    var iconSize: CGSize {
        set(newSize) {
            _iconSize = newSize
            collectionView.reloadData()
        }
        get {
            return _iconSize
        }
    }
    var _iconSize = CGSize(width: stickerIconSize, height: stickerIconSize)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = iconSize
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = stickerSpacing
        flowLayout.minimumLineSpacing = stickerSpacing
        
        collectionView = UICollectionView(frame: self.frame, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.frame = self.bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = UIColor.clear
        let nib = UINib(nibName: StickerIcon.identifier, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: StickerIcon.identifier)
        collectionView.scrollIndicatorInsets   = UIEdgeInsetsMake(0, 0, 0, -3.0)
        collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 3.0)
        self.addSubview(collectionView)
    }
    
    func configure(withDatasource: StickerDataSource) {
        self.dataSource = withDatasource
    }
    
    func reloadCollection() {
        collectionView.reloadData()
    }
}

extension StickersPanel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let dataSource = dataSource {
            return dataSource.numberOfStickersInPack(at: self.selectedPackIndex)
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerIcon.identifier, for: indexPath) as! StickerIcon
            
        let stickerInfo = dataSource!.composer(infoForStickerAt: indexPath.item, pack: self.selectedPackIndex)
        
		let pack = dataSource!.composer(infoForStickerPackAt: self.selectedPackIndex)
        cell.configure(for: stickerInfo, inPack: pack)
        return cell
    }
}

extension StickersPanel: UICollectionViewDelegate { 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? StickerIcon {
            let image = StickerCache.sticker(sticker: cell.sticker!, fromPack: cell.pack!)
            delegate?.didSelect(image: image, pack: cell.pack!, stickerInfo: cell.sticker!)
        }
    }
}

extension StickersPanel : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return iconSize
    }
}
