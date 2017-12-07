//
//  StickerPacksPanel.swift
//  ROKOKeyboard
//
//  Created by Maslov Sergey on 18.10.16.
//  Copyright © 2016 ROKOLABS. All rights reserved.
//

import UIKit
import ROKOMobi

let stickerPackIconSize: CGFloat = 35.0
let stickerPackSpacing: CGFloat = 7.0

protocol StickerPacksPanelDelegate: class {
    func didSelectPack(at packIndex: Int)
}

class StickerPacksPanel: UIView {
    var dataSource: StickerDataSource?
    weak var delegate: StickerPacksPanelDelegate?
    var collectionView: UICollectionView!
    var stickersPanel: StickersPanel!
    
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
    var _iconSize = CGSize(width: stickerPackIconSize, height: stickerPackIconSize)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = iconSize
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = stickerPackSpacing
        flowLayout.minimumLineSpacing = stickerPackSpacing
        
        collectionView = UICollectionView(frame: self.frame, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.frame = self.bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = UIColor.clear
        let nib = UINib(nibName: StickerPackIcon.identifier, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: StickerPackIcon.identifier)
        self.addSubview(collectionView)
    }
    
    func configure(withDatasource: StickerDataSource, stickersPanel: StickersPanel?) {
        self.dataSource = withDatasource
        self.stickersPanel = stickersPanel
    }
    
    func scrollTo() {
        let itemIndex = NSIndexPath(item: self.selectedPackIndex, section: 0)
        self.collectionView.scrollToItem(at: itemIndex as IndexPath, at: .right, animated: true)
    }
    
    func reloadCollection() {
        self.collectionView.reloadData()
    }
}

extension StickerPacksPanel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let dataSource = dataSource {
            return dataSource.numberOfStickerPacks()
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerPackIcon.identifier, for: indexPath) as! StickerPackIcon
        
        let pack = dataSource?.composer(infoForStickerPackAt: indexPath.item)
        cell.configure(pack: pack!, isSelected: (indexPath.item == self.selectedPackIndex))
        return cell
    }
}

extension StickerPacksPanel: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (self.stickersPanel.selectedPackIndex != indexPath.item) {
            let index = NSIndexPath(item: self.selectedPackIndex, section: 0)
            if let previousCell = collectionView.cellForItem(at: index as IndexPath) as? StickerPackIcon{
                previousCell.setPackSelected(false)
            }
            self.stickersPanel.selectedPackIndex = indexPath.item
            self.selectedPackIndex = indexPath.item
            self.collectionView.reloadData()
            delegate?.didSelectPack(at: indexPath.item)
            self.stickersPanel.reloadCollection()
        }
    }
}

extension StickerPacksPanel : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return iconSize
    }
}
