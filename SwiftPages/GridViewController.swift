//
//  GridViewController.swift
//  Britannia v2
//
//  Created by Rob Mellor on 11/07/2016.
//  Copyright © 2016 Robert Mellor. All rights reserved.
//

import UIKit
import SDWebImage

class GridViewController: UIViewController,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    lazy var data = NSMutableData()
    var arrGallery : NSMutableArray!
    var objImagedata: NSData?
    var imageCache = [String:UIImage]()
    var btnTag = NSInteger()
    var cellIndexPath = NSIndexPath()
    var refreshControl: UIRefreshControl!
    var actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
    var intTapped = NSInteger()
    @IBOutlet var lblPhotoCount: UILabel!
    @IBOutlet var collectionGalleryView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.hidden = true
        lblPhotoCount.text = String(format: "%d Photos", arrGallery.count)
        
        
        
        // Do any additional setup after loading the view.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrGallery.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionGalleryView.dequeueReusableCellWithReuseIdentifier("CellCollectionView", forIndexPath: indexPath) as! GridCollectionViewCell
        cell.backgroundColor = UIColor.blackColor()
        cell.contentView.alpha = 0
        
        
        
        let rowData: NSDictionary = arrGallery[indexPath.row] as! NSDictionary
        // Grab the artworkUrl60 key to get an image URL for the app's thumbnail
        let urlString: String = rowData["pic"] as! String
        let imgURL = NSURL(string: urlString)
        
        // If this image is already cached, don't re-download
        if let img = imageCache[urlString] {
           // cell.activityIndicator.stopAnimating()
            cell.imgGalleryPicture?.image = img
        }
        else {
            // The image isn't cached, download the img data
            // We should perform this in a background thread
            
            
            
            //Loading image from server using SDWebImage library
            
            //Image Fetching is done in background GCD thread
            
            SDWebImageManager.sharedManager().downloadImageWithURL(imgURL, options: [],progress: nil, completed: {[weak self] (image, error, cached, finished, url) in
                
                if let _ = self {
                    
                    //On Main Thread
                    dispatch_async(dispatch_get_main_queue()){
                        if let _ = collectionView.cellForItemAtIndexPath(indexPath){
                           // cell.activityIndicator.stopAnimating()
                            
                            
                            cell.imgGalleryPicture?.image = image
                        }
                    }
                }
                else {
                    NSOperationQueue.mainQueue().addOperationWithBlock(collectionView.reloadData)
                    print("Error: \(error!.localizedDescription)")
                }
                })
        }
        return cell
        
        
        
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width / 2.09, height: self.view.frame.width / 3)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        intTapped = indexPath.row
        self.performSegueWithIdentifier("pagedScrollViewSegue", sender: self)
        
    }
    
    @IBAction func btnBackTapped(sender: AnyObject) {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        UIView.animateWithDuration(0.7, animations: {
            cell.contentView.alpha = 1.0
        })
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        //LightContent
        return UIStatusBarStyle.LightContent
        
        //Default
        //return UIStatusBarStyle.Default
        
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "pagedScrollViewSegue" {
            let viewController:PagedScrollViewController = segue.destinationViewController as! PagedScrollViewController
            
            viewController.arrGallery = arrGallery
            viewController.imageCache = imageCache
            viewController.intPage = intTapped
        }
    }

}
