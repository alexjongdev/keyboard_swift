//
//  PageContentViewController.swift
//  ROKOKeyboard
//
//  Created by Maslov Sergey on 06.06.16.
//  Copyright © 2016 ROKOLABS. All rights reserved.
//

import UIKit

protocol PageContentViewControllerDelegate: class {
    func imageClick(contoller: PageContentViewController, pageIndex: Int)
}

protocol PageIndexable {
    var pageIndex: Int {get set}
}

class PageContentViewController: UIViewController, PageIndexable  {
    @IBOutlet weak var backgroundImageView: UIImageView!
    var imageFile: String = ""
    internal var pageIndex: Int = 0
    weak var delegate: PageContentViewControllerDelegate?
    
    @IBOutlet weak var topConstratint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImageView.image = UIImage(named: self.imageFile)
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
}
