//
//  EventsVC.swift
//  Britannia v2
//
//  Created by Rob Mellor on 06/08/2016.
//  Copyright © 2016 Robert Mellor. All rights reserved.
//

import UIKit
import SafariServices

class EventsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var items = [Item]()
    private var network: NetworkCalls!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
      //  self.tableView.reloadData()
        network = NetworkCalls()
        tableView.registerNib(UINib(nibName: "EventsTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventsVC.loadData), name: UIApplicationWillEnterForegroundNotification, object: nil)
    
        
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
        self.view.layoutIfNeeded()

        
       
        
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func loadData() {
        
        network.items { (items) in
            if items.count > 0 {
                self.items = items
                self.tableView.reloadData()
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - TableView Data Source
    extension EventsVC: UITableViewDataSource {
        
        
        
        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items.count
        }
        
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EventsTableViewCell
            let item = items[indexPath.row]
            
            cell.contentView.alpha = 1
            cell.descriptionLabel.text = item.des
            cell.titleLabel.text = item.title
            cell.photoView.sd_setImageWithURL(item.imageURL)
            cell.descriptionLabel.textColor = UIColor.lightGrayColor()
            
            return cell
        }
        
        
        
        
        
        
    }




    
    // MARK: - TableView Delegate
    extension EventsVC: UITableViewDelegate {
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            let item = items[indexPath.row]
            
            if #available(iOS 9.0, *) {
                let safariVC = SFSafariViewController(URL: item.pageURL!)
                safariVC.delegate = self
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.view.window!.rootViewController?.presentViewController(safariVC, animated: true, completion: nil)
                })
            } else {
                // Fallback on earlier versions
            }
            
            
           // performSegueWithIdentifier("detailsSegue", sender: item)
           // print("null")
        }
}
@available(iOS 9.0, *)
extension EventsVC: SFSafariViewControllerDelegate
        {
            func safariViewControllerDidFinish(controller: SFSafariViewController) {
                controller.dismissViewControllerAnimated(true, completion: nil)
            }
        }

    


