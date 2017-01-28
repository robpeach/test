

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import Firebase
import AVFoundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

//import SDWebImage
class ChatVC: JSQMessagesViewController {
    
    var messages = [JSQMessage]()
    var messagesRef = FIRDatabase.database().reference().child("screenmessages")
    var messagesRef2 = FIRDatabase.database().reference()
    var avatarDict = [String: JSQMessagesAvatarImage]()
    let photoCache = NSCache() //czaem wczytuje zły obrazek - do rozwiązania problemu
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.reloadData()
        collectionView?.collectionViewLayout.springinessEnabled = true
        
        self.automaticallyScrollsToMostRecentMessage = true
        
        
        
        
        if let currentUser = FIRAuth.auth()?.currentUser {
            self.senderId = currentUser.uid
            
            if currentUser.anonymous == true{
                self.senderDisplayName = "Anonymous"
            }else{
                self.senderDisplayName = (currentUser.displayName)
            }
        }
        observeMessages()
    }
    
    func observeUser(id: String){
        messagesRef2.child("users").child(id).observeEventType(.Value, withBlock: { snapshot in
 
            if let dict = snapshot.value as? [String: AnyObject]
            {
                
               // FIREBASE_REF.authData.providerData["profileImageURL"] as! NSString as String
                
               // print(dict)
                let avatarUrl = dict["profileImageURL"] as! String
                
                print(avatarUrl)
                self.setupAvatar(avatarUrl, messageId: id)
            }
        })
    }
            

    
    func setupAvatar(url: String, messageId: String){
        if url != "" {
            let fileUrl = NSURL(string: url)
            let data = NSData(contentsOfURL: fileUrl!)
            let image = UIImage(data: data!)
            let userImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: 30)
            avatarDict[messageId] = userImage
            
        }else{
            avatarDict[messageId] = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "profileimg"), diameter: 30)
            
        }
        collectionView.reloadData()
        
    }
    
    func observeMessages(){//wyrzucić ciężkie dane poza główny wątek = Photo i Video - Asynchroniczność
        messagesRef.observeEventType(.ChildAdded, withBlock: { snapshot in
            if let dict = snapshot.value as? [String: AnyObject]{
                let MediaType = dict["MediaType"] as! String
                let senderId = dict["senderId"] as! String
                let senderName = dict["senderName"] as! String
              //  let displayPic = snapshot.value!["displayPic"] as! String
                self.observeUser(senderId)
                let startTime = CFAbsoluteTimeGetCurrent()
                
                switch MediaType{ //switch zamiast else if - default -> gdy nie rozpozna MediaType
                    
                case "TEXT":
                    
                    let text = dict["text"] as! String
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
                    print(CFAbsoluteTimeGetCurrent() - startTime)
                    
                    
                    
                case "PHOTO": //OGARNĄĆ JESZCZE SDWebImage do asynchronicznego pobierania zdjęć !!! -> Problem z frameworkiem - niewidoczny
                    
                    var photo = JSQPhotoMediaItem(image: nil)
                    let fileUrl = dict["fileUrl"] as! String
                    
                    if let cachePhoto = self.photoCache.objectForKey(fileUrl) as? JSQPhotoMediaItem{
                        photo = cachePhoto
                        
                        self.collectionView.reloadData()
                    }else{
                        
                        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), {
                            let data = NSData(contentsOfURL: NSURL(string: fileUrl)!)
                            dispatch_async(dispatch_get_main_queue(), {
                                //let url = NSURL(string: fileUrl)
                                let image = UIImage(data: data!)
                                photo.image = image
                                self.collectionView.reloadData()
                                self.photoCache.setObject(photo, forKey: fileUrl)
                                if self.senderId != senderId{
                                    photo.image = UIImage(named: ("profileimg"))
                                    
                                }
                            })
                            //print("później test wątku")
                        })
                        
                        
                    }
                    //print("wcześniej test wątku")
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: photo))
                    
                    if self.senderId == senderId{
                        photo.appliesMediaViewMaskAsOutgoing = true
                        
                    }else{
                        photo.appliesMediaViewMaskAsOutgoing = false
                        photo.image = UIImage(named: ("profileimg"))
                        
                    }
                    print(CFAbsoluteTimeGetCurrent() - startTime)
                    
                case "VIDEO":
                    
                    let fileUrl = dict["fileUrl"] as! String
                    let video = NSURL(string: fileUrl)
                    let videoItem = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: videoItem))
                    
                    if self.senderId == senderId{
                        videoItem.appliesMediaViewMaskAsOutgoing = true
                    }else{
                        videoItem.appliesMediaViewMaskAsOutgoing = false
                        print(CFAbsoluteTimeGetCurrent() - startTime)
                        
                    }
                    
                default:
                    print("nieznany typ danych!")
                }
                
                self.collectionView.reloadData()
                
                
            }
            
        })
    }
    
    
    
    
    
    
    
     override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName senderDisplayPic: String!, date: NSDate!) {
        print("didpress")
        automaticallyScrollsToMostRecentMessage = true
        
        let newMessage = messagesRef.childByAutoId()
        let messageData = ["text": text, "senderId": senderId, "senderName": senderDisplayName, "MediaType": "TEXT"]
        newMessage.setValue(messageData)
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        print("accesrry")
        
        let sheet = UIAlertController(title: "Media Messages", message: "Select the media", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cancel = UIAlertAction(title: "cancel", style: UIAlertActionStyle.Cancel){ (alert: UIAlertAction) in
        }
        
        let photoLibrary = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default){ (alert: UIAlertAction) in
            self.getMediaFrom(kUTTypeImage)
            
        }
//        let videoLibrary = UIAlertAction(title: "Video Library", style: UIAlertActionStyle.Default){ (alert: UIAlertAction) in
//            self.getMediaFrom(kUTTypeMovie)
//        
//        }
        
        sheet.addAction(photoLibrary)
      //  sheet.addAction(videoLibrary)
        sheet.addAction(cancel)
        self.presentViewController(sheet, animated: true, completion: nil)
        
    }
    func getMediaFrom(type: CFString){
        print(type)
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.mediaTypes = [type as String]
        self.presentViewController(mediaPicker, animated: true, completion: nil)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
        
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        
        
        return avatarDict[message.senderId]
        
        
}
    
 

    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        
        
        if message.senderId == self.senderId{
            
            return bubbleFactory.outgoingMessagesBubbleImageWithColor(.blueColor())
            
        }else{
            
            return bubbleFactory.incomingMessagesBubbleImageWithColor(.grayColor())
            
        }
        
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        
        cell.backgroundColor = UIColor.clearColor()
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        cell.layer.shouldRasterize = true
        
        let message = messages[indexPath.item]
        if message.senderId == self.senderId {
            
        } else {
            
            cell.textView?.text = "📺"
        }
        
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        print("didTapMessageBubbleAtIndexPath")
        let message = messages[indexPath.item]
        if message.isMediaMessage{
            if let mediaItem = message.media as? JSQVideoMediaItem{
                let player = AVPlayer(URL: mediaItem.fileURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.presentViewController(playerViewController, animated: true, completion: nil)
            }
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var backBtn: UIBarButtonItem!
    
    
    @IBAction func backBtnPress(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func sendMedia(picture: UIImage?, video: NSURL?){
        print(picture)
        if let picture = picture{
            let filePath = "\(FIRAuth.auth()!.currentUser!)/\(NSDate.timeIntervalSinceReferenceDate())" //scieżka
            print(filePath)
            let data = UIImageJPEGRepresentation(picture, 0.1) //lżejsza wersja z 1 na 0.1
            let metadata = FIRStorageMetadata() //String!
            metadata.contentType = "image/jpg"
            FIRStorage.storage().reference().child(filePath).putData(data!, metadata: metadata){ (metadata, error) in
                if error != nil{
                    print(error?.localizedDescription)
                    return
                }
                let fileUrl = metadata!.downloadURLs![0].absoluteString
                let newMessage = self.messagesRef.childByAutoId()
                let messageData = ["fileUrl": fileUrl, "senderId": self.senderId, "senderName": self.senderDisplayName, "MediaType": "PHOTO"] // można wysłać w końcu zdjęcie, zapsane w storage, fileUrl z z storage
                newMessage.setValue(messageData)
            }
        }else if let video = video {
            let filePath = "\(FIRAuth.auth()!.currentUser!)/\(NSDate.timeIntervalSinceReferenceDate())" //scieżka
            print(filePath)
            let data = NSData(contentsOfURL: video)
            let metadata = FIRStorageMetadata() //String!
            metadata.contentType = "video/mp4"
            FIRStorage.storage().reference().child(filePath).putData(data!, metadata: metadata){ (metadata, error) in
                if error != nil{
                    print(error?.localizedDescription)
                    return
                }
                let fileUrl = metadata!.downloadURLs![0].absoluteString
                let newMessage = self.messagesRef.childByAutoId()
                let messageData = ["fileUrl": fileUrl, "senderId": self.senderId, "senderName": self.senderDisplayName, "MediaType": "VIDEO"]
                newMessage.setValue(messageData)
            }
            
        }
    }
    
    
    
  
    
    
    
    
    
    
}

extension ChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("finish picking")
        // bierzemy obrazek lub video
        print(info)
        
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
            sendMedia(picture, video: nil)
        }else if let video = info[UIImagePickerControllerMediaURL] as? NSURL{
            sendMedia(nil, video: video)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        collectionView.reloadData()
        
    }
}



