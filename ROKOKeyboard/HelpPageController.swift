//
//  HelpPageController.swift
//  ROKOKeyboard
//
//  Created by Maslov Sergey on 06.06.16.
//  Copyright © 2016 ROKOLABS. All rights reserved.
//
import UIKit
import MessageUI

let kShowDuration = 0.5
let kHideDuration = 0.2

class HelpPageController: UIViewController {
    @IBOutlet fileprivate weak  var pageControl : UIPageControl!
    
    lazy var pageViewController =  UIPageViewController.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    @IBOutlet weak var hiddingView: UIView!
    
    var pageImages = ["text_0", "text_1", "text_2", "text_3", "text_4", "text_5"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height + 40)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        let startingViewController = self.viewControllerAtIndex(0)
        pageViewController.setViewControllers([startingViewController!], direction: .forward, animated: false, completion: nil)
        
        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
        
        self.automaticallyAdjustsScrollViewInsets = false
        navigationController?.isNavigationBarHidden = false
        
        configurePageControl()
        updateStackState()
        view.bringSubview(toFront: hiddingView)
    }
    override func viewWillAppear(_ animated: Bool) {
        pageViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height + 40)
    }
    private func configurePageControl() {
        pageControl.pageIndicatorTintColor = UIColor.rokoLightColor
        pageControl.currentPageIndicatorTintColor = UIColor.rokoDarkColor
        pageControl.numberOfPages = pageImages.count
        pageControl.currentPage = 0
        view.bringSubview(toFront: pageControl)
    }
    
    @IBAction func clickAboutStickers(_ sender: UIButton) {
        if let url = URL(string: "https://www.roko.mobi/stickers") {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func clickHowToInstall(_ sender: AnyObject) {
        changePage(newPageIndex: 0)
    }
    
    @IBAction func clickContactUs(_ sender: AnyObject) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["info@rokolabs.com"])
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    @IBAction func clickPrivacyPolicy(_ sender: AnyObject) {
        if let url = URL(string: "https://www.roko.mobi/privacy") {
            UIApplication.shared.openURL(url)
        }
    }
    
    func updateStackState() {
        if pageControl.currentPage != 5 {
            if hiddingView.alpha == 1.0 {
                UIView.animate(withDuration: kHideDuration, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.hiddingView.alpha = 0.0
                }, completion:nil)
            } else {
                hiddingView.alpha = 0.0
            }
        } else {
            hiddingView.alpha = 0.0
            UIView.animate(withDuration: kShowDuration, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.hiddingView.alpha = 1
            }, completion:nil)
        }
    }
    
    func updatePageControl() {
        if pageControl.currentPage != 5 {
            pageControl.isHidden = false
        } else {
            pageControl.isHidden = true
        }
    }
    
    fileprivate func viewControllerAtIndex(_ index: Int) -> UIViewController? {
        let controller = HelpControllerFactory.getPageContentViewController()
        controller.imageFile = pageImages[index]
        controller.pageIndex = index
        controller.delegate = self
        return controller
    }
    
    fileprivate func changePage(newPageIndex: Int) {
        guard newPageIndex < pageImages.count else { return}
        pageControl.currentPage = newPageIndex
        updateStackState()
        updatePageControl()
        let startingViewController = self.viewControllerAtIndex(newPageIndex)
        pageViewController.setViewControllers([startingViewController!], direction: .forward, animated: false, completion: nil)
    }
}

extension HelpPageController: UIPageViewControllerDataSource{
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int{
        return pageImages.count + 1
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int  {
        return 0
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let controller = viewController as? PageContentViewController else { return nil}
        var index = controller.pageIndex
        
        if index == 0 {
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let controller = viewController as? PageContentViewController else { return nil}
        
        var index = controller.pageIndex
        
        index += 1
        
        if index >= self.pageImages.count {
            return nil
        }
        
        return self.viewControllerAtIndex(index)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed {
            return;
        }
        
        if let controller = pageViewController.viewControllers?.last as? PageContentViewController {
            pageControl.currentPage = Int(controller.pageIndex)
            updatePageControl()
            updateStackState()
        }
    }
    
}

extension HelpPageController: UIPageViewControllerDelegate{
    
}

extension HelpPageController: PageContentViewControllerDelegate{
    func imageClick(contoller: PageContentViewController, pageIndex: Int) {
        
    }
}
extension HelpPageController: MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
