//
//  MainVC.swift
//  Britannia v2
//
//  Created by Rob Mellor on 10/07/2016.
//  Copyright © 2016 Robert Mellor. All rights reserved.
//

import UIKit
import SDWebImage
import PermissionScope
import SafariServices

class MainVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var scrollHeightConstant: NSLayoutConstraint!
    @IBOutlet var swiftPagesView: SwiftPages!
    
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    
    @IBOutlet weak var musicLibraryCollection: UICollectionView!
    @IBOutlet weak var dateLbl: UILabel!
    
    
    
    var arrGallery = NSMutableArray()
    var arrMusicLibrary = [AnyObject]()
    
    lazy var data = NSMutableData()
    var imageCache = [String:UIImage]()
    var intTapped = NSInteger()
    
    // MARK:- VIEW LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        musicLibraryCollection?.registerNib(UINib(nibName: "MusicCollectionHeader", bundle: nil), forSupplementaryViewOfKind:UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderCell")
        
        startConnection()
      
        
        
        
        
        
        //Periscope
        let pscope = PermissionScope()
        pscope.addPermission(NotificationsPermission(notificationCategories: nil),
                             message: "We use this to send you\r\ncoupons and love notes")
        
        
        // Show dialog with callbacks
        pscope.show({ finished, results in
            print("got results \(results)")
            }, cancelled: { (results) -> Void in
                print("thing was cancelled")
        })
        
        
        let now = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE"
        let weekday = formatter.stringFromDate(now)
        dateLbl.text = "Have an awesome \(weekday)!"
        
        
        //ScrollPageView
        
        automaticallyAdjustsScrollViewInsets = false
        
        // Initiation
        let VCIDs = ["FirstVC", "SecondVC", "ThirdVC"]
        let buttonTitles = ["ABOUT", "NEWS", "OFFERS"]
        
        
        // swiftPagesView.disableTopBar()
        
        // Sample customization
        swiftPagesView.setOriginY(0.0)
        swiftPagesView.enableAeroEffectInTopBar(false)
        swiftPagesView.setButtonsTextColor(UIColor.blackColor())
        swiftPagesView.setAnimatedBarColor(UIColor.blackColor())
        swiftPagesView.initializeWithVCIDsArrayAndButtonTitlesArray(VCIDs, buttonTitlesArray: buttonTitles)
        
    }
    
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        
        
        
        self.getMusicLibrary()
        //hide navigation for screen A
        self.navigationController?.navigationBarHidden = true
        
        //
    }
    
    // MARK:- WEB CALL METHODS
    func getMusicLibrary()
    {
        //        var url: NSURL = NSURL(string: "http://britanniaclub.co.uk/app/json/music_list.json")!
        //        var urlRequest: NSURLRequest = NSURLRequest(URL: url)
        //        var queue: NSOperationQueue = NSOperationQueue()
        let urlPath: String = "http://britanniaclub.co.uk/app/json/music_list.json?\(arc4random())"
        let url: NSURL = NSURL(string: urlPath)!
        let request1: NSURLRequest = NSURLRequest(URL: url)
        let queue:NSOperationQueue = NSOperationQueue()
        
        
        
        NSURLConnection.sendAsynchronousRequest(request1, queue: queue, completionHandler:{ (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    print("ASynchronous\(jsonResult)")
                    self.arrMusicLibrary = jsonResult.valueForKey("data") as! [AnyObject]
                    
                    //                    let arrStrains = objDict!["response"]!!["dispensary_strains"] as! [AnyObject]
                    
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        // code here
                        self.musicLibraryCollection.reloadData()
                        self.scrollHeightConstant.constant = CGFloat((290+(self.arrMusicLibrary.count*3)*(self.arrMusicLibrary.count)+290))
                        self.view.layoutIfNeeded()
                        
                    })
                    
                    
                    
                    
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            
        })
        
        
    }
    func startConnection()
    {
        let urlPath: String = "http://britanniaclub.co.uk/app/json/galary.json?\(arc4random())"
        let url: NSURL = NSURL(string: urlPath)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        let connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)!
        connection.start()
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
        self.data.appendData(data)
    }
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        var _: NSError
        
        
        
        do {
            
            let jsonResult  = try  NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as! NSDictionary
            arrGallery = jsonResult.valueForKey("data") as! NSMutableArray
            galleryCollectionView.reloadData()
            self.data = NSMutableData(data: NSMutableData())
            
            
        } catch {
            
        }
        
        
    }
    
    // MARK:- COLLECTION VIEW METHODS
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == musicLibraryCollection
        {
            return arrMusicLibrary.count
        }
        else
        {
            return arrGallery.count
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        
        
        if collectionView == galleryCollectionView
        {
            let cellIdentifier = "GalleryCell"
            let cell: CellClass = galleryCollectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! CellClass
            
            let rowData: NSDictionary = arrGallery[indexPath.row] as! NSDictionary
            let urlString: String = rowData["date"] as! String
            let dateString:String = urlString
            let dateFmt = NSDateFormatter()//03-08-2016
            // the format you want
            dateFmt.dateFormat = "dd-MM-yyyy"
            let date1:NSDate = dateFmt.dateFromString(dateString)!
            
            let dateFmt1 = NSDateFormatter()//03-08-2016
            // the format you want
            dateFmt1.dateFormat = "d LLLL yyyy"
            
            let strDate:NSString = dateFmt1.stringFromDate(date1)
            //if let coverImage = rowData["cover"] as! UIImage
            
            cell.contentView.alpha = 0
            cell.dateLbl.text = strDate as String
            
            //  let rowData: NSDictionary = arrGallery[indexPath.row] as! NSDictionary
            let coverurlString: String = rowData["cover"] as! String
            
            
            let imgURL = NSURL(string: coverurlString)
            // Get the formatted price string for display in the subtitle
            
            // If this image is already cached, don't re-download
            if let img = imageCache[coverurlString] {
                cell.Image?.image = img
            }
            else {
                // The image isn't cached, download the img data
                // We should perform this in a background thread
                let request: NSURLRequest = NSURLRequest(URL: imgURL!)
                let mainQueue = NSOperationQueue.mainQueue()
                NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                    if error == nil {
                        // Convert the downloaded data in to a UIImage object
                        let image = UIImage(data: data!)
                        // Store the image in to our cache
                        self.imageCache[urlString] = image
                        // Update the cell
                        dispatch_async(dispatch_get_main_queue(), {
                            if let _ = self.galleryCollectionView.cellForItemAtIndexPath(indexPath) {
                                cell.Image?.image = image
                            }
                        })
                    }
                    else {
                    }
                })
            }
            return cell
            
        }
            
        else
        {
            let cellIdentifier = "MusicLibraryCell"
            let cell: MusicLibraryCell = musicLibraryCollection.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! MusicLibraryCell
            
            let dictData: NSDictionary = arrMusicLibrary[indexPath.row] as! NSDictionary
            
            cell.lblMusicTitle.text = dictData["title"] as? String
            cell.contentView.alpha = 1
            
            
            
            //  let rowData: NSDictionary = arrGallery[indexPath.row] as! NSDictionary
            let coverurlString: String = dictData["pic"] as! String
            
            let imgURL = NSURL(string: coverurlString)
            
            
            let block: SDWebImageCompletionBlock! = {(image: UIImage!, error: NSError!, cacheType: SDImageCacheType!, imageURL: NSURL!) -> Void in
                
            }
            
            
            cell.imgMusicCover.sd_setImageWithURL(imgURL, completed: block)
            
            
            return cell
        }
        
        
        
    }
    
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        
        if collectionView == galleryCollectionView
        {
        
        
        let cellSpacing = CGFloat(3) //Define the space between each cell
        let leftRightMargin = CGFloat(20) //If defined in Interface Builder for "Section Insets"
        let numColumns = CGFloat(2.7) //The total number of columns you want
        
        let totalCellSpace = cellSpacing * (numColumns - 1)
        let screenWidth = UIScreen.mainScreen().bounds.width
        let width = (screenWidth - leftRightMargin - totalCellSpace) / numColumns
        let height = CGFloat(120) //whatever height you want
        
            return CGSizeMake(width, height);
            
        }
        else
        {
            
            let cellSpacing = CGFloat(2) //Define the space between each cell
            let leftRightMargin = CGFloat(20) //If defined in Interface Builder for "Section Insets"
            let numColumns = CGFloat(2) //The total number of columns you want
            
            let totalCellSpace = cellSpacing * (numColumns - 1)
            let screenWidth = UIScreen.mainScreen().bounds.width
            let width = (screenWidth - leftRightMargin - totalCellSpace) / numColumns
            let height = (screenWidth - leftRightMargin - totalCellSpace) / numColumns
            
            return CGSizeMake(width, height);
        }
            
        
       
        
        
        
    }
    


    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        UIView.animateWithDuration(0.5, animations: {
            cell.contentView.alpha = 1.0
        })
        
    }
    
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if collectionView == galleryCollectionView
        {
            
            intTapped = indexPath.row
            self.performSegueWithIdentifier("galleryGridSegue", sender: self)
        }
        else{
            intTapped = indexPath.row
            self.performSegueWithIdentifier("musicPlayerSegue", sender: self)
            
        }
        
        
        
    }
    
    // MARK:- NATIGATION METHODS
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "galleryGridSegue" {
            let viewController:GridViewController = segue.destinationViewController as! GridViewController
            
            let rowData: NSDictionary = arrGallery[intTapped] as! NSDictionary
            
            let arrTempGallery: NSMutableArray = rowData["images"] as! NSMutableArray
            
            viewController.arrGallery = arrTempGallery
        }
        else if segue.identifier == "musicPlayerSegue" {
            let viewController:MusicPlayerVC = segue.destinationViewController as! MusicPlayerVC
            
            //            let arrMusicLibrary: NSDictionary = arrMusicLibrary[intTapped] as! NSDictionary
            
            viewController.currentAudioIndex = intTapped
            viewController.arrMusicLibrary = arrMusicLibrary as NSArray
            
        }
    }
    
    
    
    
    //StatusBarColour
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        //LightContent
        //return UIStatusBarStyle.LightContent
        
        //Default
        return UIStatusBarStyle.Default
        
    }
    
    
    
    
}
