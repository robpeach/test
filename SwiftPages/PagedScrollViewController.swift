//
//  PagedScrollViewController.swift
//  Britannia v2
//
//  Created by Rob Mellor on 11/07/2016.
//  Copyright © 2016 Robert Mellor. All rights reserved.
//

import UIKit
import SDWebImage




class PagedScrollViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    var arrGallery : NSMutableArray!
    var imageCache : [String:UIImage]!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var lblPhotoCount: UILabel!
    var pageViews: [UIImageView?] = []
    var intPage : NSInteger!
    @IBOutlet var viewLower: UIView!
    @IBOutlet var viewUpper: UIView!
    
    @IBOutlet weak var newPageView: UIView!
    
    
    //var newPageView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        scrollView.needsUpdateConstraints()
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
        //
        //
        //Manually added constraints at runtime
        let constraintTS = NSLayoutConstraint(item: scrollView, attribute: .Top, relatedBy: .Equal, toItem: viewUpper, attribute: .Bottom, multiplier: 1.0, constant: 0)
        let constraintBS = NSLayoutConstraint(item: scrollView, attribute: .Bottom, relatedBy: .Equal, toItem: viewLower, attribute: .Top, multiplier: 1.0, constant: 0)
        let constraintLS = NSLayoutConstraint(item: scrollView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0)
        let constraintRS = NSLayoutConstraint(item: scrollView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0)
        view.addConstraint(constraintTS)
        view.addConstraint(constraintBS)
        view.addConstraint(constraintLS)
        view.addConstraint(constraintRS)

        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        centerScrollViewContents()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        centerScrollViewContents()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        let pageCount = arrGallery.count
        for _ in 0..<pageCount {
            pageViews.append(nil)
        }
        
        let pagesScrollViewSize = scrollView.frame.size
        scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * CGFloat(arrGallery.count), pagesScrollViewSize.height)
        
        scrollView.contentOffset.x = CGFloat(intPage) * self.view.frame.size.width
        
        
        
        
        
        lblPhotoCount.text = String(format: "%d of %d Photos",intPage+1, arrGallery.count)
        
        loadVisiblePages()
        
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(PagedScrollViewController.handleTap(_:)))
        // 4
        recognizer.delegate = self
        scrollView.addGestureRecognizer(recognizer)
        scrollView.showsVerticalScrollIndicator = false
        viewUpper.alpha = 1.0
        viewLower.alpha = 1.0
        
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        viewUpper.alpha = 1.0
        viewLower.alpha = 1.0
    }
    func loadPage(page: Int) {
        
        if page < 0 || page >= arrGallery.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
         if let page = pageViews[page] {
            // Do nothing. The view is already loaded.
        } else {
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            
            let rowData: NSDictionary = arrGallery[page] as! NSDictionary
            let urlString: String = rowData["pic"] as! String
            let imgURL = NSURL(string: urlString)
            // If this image is already cached, don't re-download
            if let img = imageCache[urlString] {
                let newPageView = UIImageView(image: img)
                newPageView.contentMode = .ScaleAspectFit
                newPageView.frame = frame
                scrollView.addSubview(newPageView)
                
                
                pageViews[page] = newPageView
            }
            else {
              
                
                SDWebImageManager.sharedManager().downloadImageWithURL(imgURL, options: [],progress: nil, completed: {[weak self] (image, error, cached, finished, url) in
                    
                    if error == nil {
                        
                        //   let image = UIImage(data: data!)
                        //On Main Thread
                        dispatch_async(dispatch_get_main_queue()){
                            self?.imageCache[urlString] = image
                            // Update the cell
                            let newPageView = UIImageView(image: image)
                            newPageView.contentMode = .ScaleAspectFit
                            newPageView.frame = frame
                            self?.scrollView.addSubview(newPageView)
                            
                            // 4
                            self?.pageViews[page] = newPageView
                        }
                    }
                    else {
                        print("Error: \(error!.localizedDescription)")
                    }
                    })
            }
            
            
            
            
            
        }
        
        
        
        
        
        
    }
    
    func purgePage(page: Int) {
        
        if page < 0 || page >= arrGallery.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        if let pageView = pageViews[page] {
            pageView.removeFromSuperview()
            pageViews[page] = nil
        }
        
        
    }
    
    func loadVisiblePages() {
        
        // First, determine which page is currently visible
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        intPage = page
        // Update the page control
        lblPhotoCount.text = String(format: "%d of %d Photos",intPage+1, arrGallery.count)
        
        // Work out which pages you want to load
        let firstPage = max(0,page - 1)
        let lastPage = min(page + 1, arrGallery.count - 1)
        
        // Purge anything before the first page
        for index in 0..<firstPage {
            purgePage(index)
        }
        
        // Load pages in our range
        for index in firstPage...lastPage {
            loadPage(index)
        }
        
        // Purge anything after the last page
        for index in (lastPage + 1)..<(arrGallery.count) {
            purgePage(index)
        }
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        if scrollView.contentSize.width > 320{
            viewLower.alpha = 1
            viewUpper.alpha = 1
            loadVisiblePages()
            
        }
    }
    
    @IBAction func btnBackTapped(sender: AnyObject) {
        scrollView.delegate = nil
        if let navController = self.navigationController {
            navController.popToRootViewControllerAnimated(true)
        }
        
    }
    @IBAction func btnShareTapped(sender: AnyObject) {
        var sharingItems = [AnyObject]()
        
        let rowData: NSDictionary = arrGallery[intPage] as! NSDictionary
        // Grab the artworkUrl60 key to get an image URL for the app's thumbnail
        let urlString: String = rowData["pic"] as! String
        // let imgURL = NSURL(string: urlString)
        
        let img = imageCache[urlString]
        
        sharingItems.append(img!)
        //  sharingItems.append(imgURL!)
        
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
        
    }
    @IBAction func btnGalleryTapped(sender: AnyObject) {
        scrollView.delegate = nil
        
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
    
    
    
    func centerScrollViewContents() {
        let boundsSize = scrollView.bounds.size
        var contentsFrame =  newPageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.height - self.topLayoutGuide.length) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        
        
        
        newPageView.frame = contentsFrame
    }
    

    
    
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        //LightContent
        return UIStatusBarStyle.LightContent
        
        //Default
        //return UIStatusBarStyle.Default
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
