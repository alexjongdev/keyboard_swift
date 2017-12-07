//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by Maslov Sergey on 06.06.16.
//  Copyright © 2016 ROKOLABS. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    @IBOutlet weak var hintView: UIView!
    @IBOutlet weak var hintButton: UIButton!
    @IBOutlet weak var keyboardView: UIView!
    @IBOutlet weak var buttonShare: UIButton!
    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet weak var buttonDelete: UIButton!
    
    @IBOutlet weak var stickersPanel: StickersPanel!
    @IBOutlet weak var stickersPackPanel: StickerPacksPanel!
    
    private var dataSource: ROKOPortalStickersDataSource!
    fileprivate var stickersDataProvider = StickersDataProvider()
    fileprivate var guid = NSUUID().uuidString
    private var deleteButtonTimer: Timer?
    private var deleteCharactersCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stickersDataProvider.getWarmCache {
            self.stickersPackPanel.reloadCollection()
            self.stickersPanel.reloadCollection()
        }
        
        loadKeyboard()
        configureStikers()
        hintView.isHidden = true
        configuteHintButton()
        
        buttonDelete.addTarget(self, action: #selector(KeyboardViewController.deleteButtonPressed), for: .touchUpInside)
        
        let deleteButtonLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(KeyboardViewController.handleLongPressForDeleteButtonWithGestureRecognizer))
        buttonDelete.addGestureRecognizer(deleteButtonLongPressGestureRecognizer)
        buttonDelete.addGestureRecognizer(deleteButtonLongPressGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guid = NSUUID().uuidString
        ROKOStickers.logEnteredStickersPanel()
        stickersPackPanel.scrollTo()
    }
    
    override func advanceToNextInputMode() {
        super.advanceToNextInputMode()
        updateBackground()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateBackground()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBackground()
    }
    
    fileprivate func updateBackground() {
        if self.textDocumentProxy.keyboardAppearance == .dark {
            keyboardView.backgroundColor = UIColor.darkGray
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // For better memory drain - we manually remove all
        hintView.removeFromSuperview()
        hintButton.removeFromSuperview()
        keyboardView.removeFromSuperview()
        buttonShare.removeFromSuperview()
        labelInfo.removeFromSuperview()
        
        stickersPanel.removeFromSuperview()
        stickersPackPanel.removeFromSuperview()
        
        //        deleteButton.removeGestureRecognizer(longPress) // TODO: check it
        
        dataSource = nil
        stickersDataProvider.stickerPacks?.removeAll()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func clickGlobe(_ sender: AnyObject) {
        ROKOStickers.logExitedStickersPanel()
        advanceToNextInputMode()
    }
    
    @IBAction func clickHide(_ sender: AnyObject) {
        self.dismissKeyboard()
    }
    
    @IBAction func clickShare(_ sender: AnyObject) {
        ROKOLinkManager().createLink(withName: kLinkName, type: .share, sourceURL: nil, channelName: kLinkChannelName, sharingCode: nil, advancedSettings: nil, completionBlock: {
            [weak self] linkURL, linkId, error in
            if error == nil, let url = linkURL{
                self?.textDocumentProxy.insertText(kGreetingText + url)
            } else {
                self?.textDocumentProxy.insertText(kGreetingText + kAppLink)
            }
        })
        
        ROKOStickers.logSharedImage(withId: self.guid)
    }
    
    fileprivate func loadKeyboard(){
        Bundle.main.loadNibNamed("KeyboardViewController", owner: self, options: nil)
        self.keyboardView.frame = self.view.frame
        self.view.addSubview(self.keyboardView)
    }
    
    fileprivate func configuteHintButton() {
        hintView.backgroundColor = UIColor(red: 32/255.0, green: 59/255.0, blue: 104/255.0, alpha: 0.7)
        
        let fontSize:CGFloat = 16.0
        let button = UIButton(frame: CGRect(x:0, y: 0, width: 140, height: 100))
        hintButton = button
        let font1 = UIFont(name: "SFUIText-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        let font2 = UIFont(name: "SFUIText-Bold", size:fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        let color = UIColor.white
        
        let myNormalAttributedTitle = NSMutableAttributedString(string: "Copied to the clipboard. Now tap and\n",
                                                                attributes: [NSAttributedStringKey.font : font1, NSAttributedStringKey.foregroundColor: color ])
        
        let myBoldAttributedTitle = NSAttributedString(string: " paste ",
                                                       attributes: [NSAttributedStringKey.font : font2, NSAttributedStringKey.foregroundColor: color])
        let myLastAttributedTitle = NSAttributedString(string: " into the message field",
                                                       attributes: [NSAttributedStringKey.font : font1, NSAttributedStringKey.foregroundColor: color])
        myNormalAttributedTitle.append(myBoldAttributedTitle)
        myNormalAttributedTitle.append(myLastAttributedTitle)
        hintButton.translatesAutoresizingMaskIntoConstraints = false
        hintButton.setAttributedTitle(myNormalAttributedTitle, for: .normal)
        
        
        hintButton.layer.cornerRadius = 10
        hintButton.titleLabel!.numberOfLines = 2
        hintButton.titleLabel!.lineBreakMode = .byWordWrapping;
        hintButton.titleLabel!.textAlignment = .center;
        
        
        hintView.addSubview(hintButton)
        
        let centerX = NSLayoutConstraint(item: hintView, attribute: .centerX, relatedBy: .equal, toItem: hintButton, attribute: .centerX, multiplier: 1, constant: 0)
        
        let centerY = NSLayoutConstraint(item: hintView, attribute: .centerY, relatedBy: .equal, toItem: hintButton, attribute: .centerY, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([centerX, centerY])
    }
    
    fileprivate func configureStikers(){
        stickersPanel.delegate = self
        stickersPackPanel.delegate = self
        
        let isDefaultPackProvided = stickersDataProvider.loadData()
        if  isDefaultPackProvided {
            stickersPanel.configure(withDatasource: stickersDataProvider)
            stickersPackPanel.configure(withDatasource: stickersDataProvider, stickersPanel: stickersPanel)
            
            if let oldPackIndex = UserDefaults.standard.object(forKey: kLastPackKey) as? Int {
                if oldPackIndex < (stickersDataProvider.numberOfStickerPacks()) {
                    stickersPackPanel.selectedPackIndex = oldPackIndex
                    stickersPanel.selectedPackIndex = oldPackIndex
                    let info = stickersDataProvider.composer(infoForStickerPackAt: oldPackIndex)
                    labelInfo.text = info.name
                }
            }
            
            stickersPanel.reloadCollection()
            stickersPackPanel.reloadCollection()
        }
        
        dataSource =  ROKOPortalStickersDataSource(manager: ROKOComponentManager.shared())
        dataSource.reloadStickers { [weak self](object, error) in
            if error == nil {
                if let stickerPacks = object as? [ROKOStickerPack] {
                    self?.stickersDataProvider.initWithDataSource(stickerPacks: stickerPacks)
                    
                    var packsCount = stickerPacks.count
                    for pack in stickerPacks {
                        StickerCache.load(stickerPack: pack) { (pack) in
                            packsCount = packsCount - 1
                            if packsCount == 0 {
                                DispatchQueue.main.async() { () -> Void in
                                    self?.stickersPanel.reloadCollection()
                                    self?.stickersPackPanel.reloadCollection()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func hideHint(){
        self.hintView.isHidden = true
    }
    
    fileprivate func showHint(){
        self.hintView.isHidden = false
        self.hintView.alpha = 0
        UIView.animate(withDuration: kPressPasteTitleAppearDuration, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.hintView!.alpha = 1
        }, completion: { (Bool) -> () in
            UIView.animate(withDuration: kPressPasteTitleAppearDuration, delay: kPressPasteTitleShowDuration, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.hintView!.alpha = 0
            }, completion: nil)
        })
    }
    
    // MARK: - Delete button handling
    @objc func deleteButtonPressed(sender: AnyObject) {
        switch textDocumentProxy.documentContextBeforeInput {
        case let s where s?.hasSuffix("    ") == true: // Cursor in front of tab, so delete tab.
            for _ in 0..<4 { // TODO: Update to use tab setting.
                textDocumentProxy.deleteBackward()
            }
        default:
            textDocumentProxy.deleteBackward()
        }
        
    }
    
    @objc func handleLongPressForDeleteButtonWithGestureRecognizer(gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began, .changed:
            if deleteButtonTimer == nil {
                deleteButtonTimer = Timer(timeInterval: 0.1, target: self, selector: #selector(KeyboardViewController.handleDeleteButtonTimerTick), userInfo: nil, repeats: true)
                deleteButtonTimer!.tolerance = 0.01
                RunLoop.main.add(deleteButtonTimer!, forMode: RunLoopMode.defaultRunLoopMode)
            }
        default:
            deleteButtonTimer?.invalidate()
            deleteButtonTimer = nil
            deleteCharactersCount = 0
        }
    }
    
    @objc func handleDeleteButtonTimerTick(timer: Timer) {
        var charactersToDelete = 1
        defer {
            for _ in 0..<charactersToDelete {
                textDocumentProxy.deleteBackward()
            }
            deleteCharactersCount += 1
        }
        
        if deleteCharactersCount > 5 {
            if let documentContextBeforeInput = textDocumentProxy.documentContextBeforeInput as NSString? {
                let range = documentContextBeforeInput.rangeOfCharacter(from: CharacterSet.whitespaces, options: .backwards)
                if range.location != NSNotFound {
                    charactersToDelete = documentContextBeforeInput.length - range.location
                }
            }
        }
    }
    
}

extension KeyboardViewController: StickersPanelDelegate {
    func didSelect(image: UIImage!, pack: ROKOStickerPack, stickerInfo: ROKOSticker) {
        if let image = image!.resizeImage(scale: CGFloat(stickerInfo.scaleFactor)) {
            ClipboardManager.copy(image)
            
            let info = RLStickerInfo()
            info.stickerID = stickerInfo.imageInfo.objectId as! Int
            info.scale = CGFloat(stickerInfo.scaleFactor)
            
            let packInfo = RLStickerPackInfo()
            packInfo.packID = pack.objectId as! Int
            packInfo.title = pack.name
            ROKOStickers.logStickerSelection(info, inPack: packInfo, withImageId: guid)
            
            
            let item = ROKOStickersEventItem()
            item.stickerId = stickerInfo.objectId as! Int
            item.stickerPackId = pack.objectId as! Int
            item.stickerPackName = pack.name
            ROKOStickers.logSaving(withStickers: [item], onImageWithId: guid, fromCamera: false)
            showHint()
        }
    }
}

extension KeyboardViewController: StickerPacksPanelDelegate {
    func didSelectPack(at packPosition: Int) {
        UserDefaults.standard.set(packPosition, forKey: kLastPackKey)
        let info = stickersDataProvider.composer(infoForStickerPackAt: packPosition)
        labelInfo.text = info.name
    }
}
