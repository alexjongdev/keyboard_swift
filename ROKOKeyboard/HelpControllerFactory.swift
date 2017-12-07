//
//  MainFabric.swift
//  ROKOKeyboard
//
//  Created by Maslov Sergey on 06.06.16.
//  Copyright © 2016 ROKOLABS. All rights reserved.
//

import UIKit

class HelpControllerFactory {
    static let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    class func getHelpPageController() -> HelpPageController {
        return storyboard.instantiateViewController(withIdentifier: "HelpPageController") as! HelpPageController
    }
    
    class func getPageViewController() -> UIPageViewController {
        return storyboard.instantiateViewController(withIdentifier: "PageViewController") as! UIPageViewController
    }
    
    class func getPageContentViewController() -> PageContentViewController {
        return storyboard.instantiateViewController(withIdentifier: "PageContentViewController") as! PageContentViewController
    }
    
}
