//
//  MusicPlayerVC.swift
//  Britannia v2
//
//  Created by Milap on 7/28/16.
//  Copyright © 2016 Robert Mellor. All rights reserved.
//

import UIKit
import AVFoundation
import SDWebImage
import MediaAccessibility
import MediaPlayer





class MusicPlayerVC: UIViewController ,AVAudioPlayerDelegate{
    var audioPlayer = AVPlayer()
//    var currentAudio = "";
    var currentAudioPath:NSURL!
    var audioList:NSArray!
    var currentAudioIndex: Int!
    var timer:NSTimer!
    var audioLength = 0.0
    var toggle = true
    var effectToggle = true
    var totalLengthOfAudio = ""
    
    var arrMusicLibrary:NSArray!
    let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
    
    
    @IBOutlet weak var btnPlayPause: UIButton!
   
    @IBOutlet weak var forwardSkip: UIButton!
    @IBOutlet weak var backSkip: UIButton!
    @IBOutlet weak var lblArtistLabel: UILabel!
    @IBOutlet weak var lblMusicTitle: UILabel!
    @IBOutlet weak var lblCurrentTime: UILabel!
    @IBOutlet weak var lblTotalTime: UILabel!
    @IBOutlet weak var sliderMusic: UISlider!
    @IBOutlet weak var imgMusicCover: UIImageView!
    
    @IBOutlet weak var sliderVolume: UISlider!
    

    
    
    
    
    // MARK:- view  lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        audioPlayer.volume = 1
        sliderVolume.minimumValue = 0
        sliderVolume.maximumValue = 1
        sliderVolume.value = audioPlayer.volume
        prepareAudio()
        playAudio()
        updateLabels()

       // btnPlayPause.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
       // backSkip.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
       // forwardSkip.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        
        sliderMusic.setThumbImage(UIImage(named: "player_slider_playback_thumb.png"), forState: UIControlState.Normal)


        
        commandCenter.previousTrackCommand.enabled = true;
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(MusicPlayerVC.playPreviousAudio))
        
        commandCenter.nextTrackCommand.enabled = true
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(MusicPlayerVC.playNextAudio))
        
//        commandCenter.playCommand.enabled = true
        commandCenter.playCommand.addTarget(self, action: #selector(MusicPlayerVC.btnPlayPauseAction(_:)))
        
//        commandCenter.pauseCommand.enabled = true
//        commandCenter.pauseCommand.addTarget(self, action: "pauseAudioPlayer")
//        commandCenter.pla
        
        MPRemoteCommandCenter.sharedCommandCenter().pauseCommand.addTargetWithHandler { (e) -> MPRemoteCommandHandlerStatus in
            self.audioPlayer.pause()
            let infoCenter = MPNowPlayingInfoCenter.defaultCenter()
            infoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
            
            let timeNow = Int(self.audioPlayer.currentTime().value) / Int(self.audioPlayer.currentTime().timescale)

            infoCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = timeNow
            
            _ = try? AVAudioSession.sharedInstance().setActive(false)
            
            return MPRemoteCommandHandlerStatus.Success
        }

//        var info = [String: AnyObject]()
//        info[MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(double: audioPlayer.rate != 0 && audioPlayer.error == nil ? 1.0 : 0)
//        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = info

        

//        commandCenter.playCommand.enabled = true commandCenter.previousTrackCommand.addTarget(self, action: "playAudio") It should say playCommand.addTarget

    }
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        
        
        
        // audioPlayer.pause()
    }
    override func viewWillDisappear(animated: Bool) {
        audioPlayer.pause()
        audioPlayer.replaceCurrentItemWithPlayerItem(nil)

        
        
//audioPlayer.
    }
    
    
        // MARK:- AUDIO PLAYER METHODS
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool){
        if flag{
            currentAudioIndex! += 1
            if currentAudioIndex>arrMusicLibrary.count-1{
                currentAudioIndex! -= 1
                return
            }
            prepareAudio()
            playAudio()
        }
    }
    
    
    
    @IBAction func backBtnAction(sender: AnyObject)
    {
        self.navigationController?.popViewControllerAnimated(true)
       // if let navController = self.navigationController {
         //   navController.popViewControllerAnimated(true) }
    }
    
    @IBAction func btnNextAction(sender: AnyObject)
    {
        playNextAudio()
    }
    @IBAction func btnPlayPauseAction(sender: AnyObject)
    {
        
        let play = UIImage(named: "play")
        let pause = UIImage(named: "pause")
        
        if (audioPlayer.rate != 0 && audioPlayer.error == nil) {
            print("playing")
            pauseAudioPlayer()

        audioPlayer.rate != 0 && audioPlayer.error == nil ? "\(btnPlayPause.setImage( pause, forState: UIControlState.Normal))" : "\(btnPlayPause.setImage(play , forState: UIControlState.Normal))"

        }
        else{
        playAudio()
        audioPlayer.rate != 0 && audioPlayer.error == nil ? "\(btnPlayPause.setImage( pause, forState: UIControlState.Normal))" : "\(btnPlayPause.setImage(play , forState: UIControlState.Normal))"

        }
        
//        var info = [String: AnyObject]()
//        info[MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(double: audioPlayer.rate != 0 && audioPlayer.error == nil ? 1.0 : 0)
//        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = info

    }
    @IBAction func btnPreviousAction(sender: AnyObject)
    {
        playPreviousAudio()
    }
    
    
    
    // MARK:- CUSTOM METHODS
    func setCurrentAudioPath()
    {
        currentAudioPath = NSURL(string: arrMusicLibrary.objectAtIndex(currentAudioIndex)["music_url"] as! String)
        
        print("\(currentAudioPath)")
    }
    func saveCurrentTrackNumber(){
        NSUserDefaults.standardUserDefaults().setObject(currentAudioIndex, forKey:"currentAudioIndex")
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    
    func prepareAudio(){
        setCurrentAudioPath()
//        do {
//            //keep alive audio at background
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//        } catch _ {
//        }
//        do {
//            try AVAudioSession.sharedInstance().setActive(true)
//        } catch _ {
//        }
//        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        
        
        
        
        let playerItem = AVPlayerItem( URL:NSURL( string:currentAudioPath.absoluteString )! )
        audioPlayer = AVPlayer(playerItem:playerItem)


        
        let seconds = Float(CMTimeGetSeconds(audioPlayer.currentItem!.asset.duration));
        audioLength = CMTimeGetSeconds(audioPlayer.currentItem!.asset.duration)

//        let t2 = Float(audioPlayer.currentTime().timescale)

                sliderMusic.maximumValue = CFloat(seconds)
                sliderMusic.minimumValue = 0.0
                sliderMusic.value = 0.0
//                audioPlayer.prepareToPlay()
                showTotalSurahLength()
                updateLabels()
                lblCurrentTime.text = "00:00:00"
        audioPlayer.rate = 1.0;
        audioPlayer.play()
        
        
        let play = UIImage(named: "play")
        let pause = UIImage(named: "pause")
        
        if (audioPlayer.rate != 0 && audioPlayer.error == nil) {
            print("playing")
           
            
            audioPlayer.rate != 0 && audioPlayer.error == nil ? "\(btnPlayPause.setImage( pause, forState: UIControlState.Normal))" : "\(btnPlayPause.setImage(play , forState: UIControlState.Normal))"
            
        }
        else{
            audioPlayer.rate != 0 && audioPlayer.error == nil ? "\(btnPlayPause.setImage( pause, forState: UIControlState.Normal))" : "\(btnPlayPause.setImage(play , forState: UIControlState.Normal))"
            
        }

    }
    
    func  playAudio(){
        

//        commandCenter.playCommand.enabled = true
        audioPlayer.play()
        startTimer()
        updateLabels()
        
        UIView.animateWithDuration(1.0, delay:0, options: [], animations: {
            
            
            var frm: CGRect = self.imgMusicCover.frame
            //  frm.origin.x = frm.origin.x - 50
            // frm.origin.y = frm.origin.y - 50
            frm.size.width = frm.size.width + 0
            frm.size.height = frm.size.height + 10
            self.imgMusicCover.frame = frm
            
          //  self.imgMusicCover.frame = CGRect(x: 40, y: 80, width: 300, height: 250)
            self.imgMusicCover.layer.shadowColor = UIColor.blackColor().CGColor
            self.imgMusicCover.layer.shadowOpacity = 0.5
            self.imgMusicCover.layer.shadowOffset = CGSizeZero
            self.imgMusicCover.layer.shadowRadius = 5
            
            }, completion: nil)
    
        
//        saveCurrentTrackNumber()
    }
    
    func playNextAudio(){
        currentAudioIndex! += 1
        audioPlayer.pause()
        if currentAudioIndex>arrMusicLibrary.count-1{
            currentAudioIndex! -= 1
            
            return
        }
        if audioPlayer.rate != 0 && audioPlayer.error == nil{
            prepareAudio()
            playAudio()
        }else{
            prepareAudio()
        }
        
    }
    
    
    func playPreviousAudio(){
        currentAudioIndex! -= 1
        audioPlayer.pause()
        if currentAudioIndex<0{
            currentAudioIndex! += 1
            return
        }
        if audioPlayer.rate != 0 && audioPlayer.error == nil{
            
            prepareAudio()
            playAudio()
        }else{
            prepareAudio()
        }
        
    }
    
    
    func stopAudiplayer(){
        
        audioPlayer.replaceCurrentItemWithPlayerItem(nil)
    }
    
    func pauseAudioPlayer()
    {
        audioPlayer.pause()
        
        UIView.animateWithDuration(1.0, delay:0, options: [], animations: {
            
            
            var frm: CGRect = self.imgMusicCover.frame
            frm.origin.x = frm.origin.x - 0
            frm.origin.y = frm.origin.y - 0
            frm.size.width = frm.size.width - 0
            frm.size.height = frm.size.height - 10
            self.imgMusicCover.frame = frm
            
            
            
          //  self.imgMusicCover.frame = CGRect(x: 40, y: 80, width: 300, height: 225)
            self.imgMusicCover.layer.shadowColor = UIColor.grayColor().CGColor
            self.imgMusicCover.layer.shadowOpacity = 0.5
            self.imgMusicCover.layer.shadowOffset = CGSizeZero
            self.imgMusicCover.layer.shadowRadius = 2
            
            }, completion: nil)
        
        
        
    }
    
    func startTimer(){
        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(MusicPlayerVC.update(_:)), userInfo: nil,repeats: true)
            timer.fire()
        }
    }
    
    func stopTimer(){
        timer.invalidate()
        
    }
    
    func updateLabels(){
        updateSongNameLabel()
        
    }
    
    
    func updateSongNameLabel()
    {
       let songName = arrMusicLibrary.objectAtIndex(currentAudioIndex)["title"]
        let artistname = arrMusicLibrary.objectAtIndex(currentAudioIndex)["artist"]

        lblMusicTitle.text = songName as? String
        
        let content = arrMusicLibrary.objectAtIndex(currentAudioIndex)["content"]
        lblArtistLabel.text = content as? String
        
        
        let coverurlString: String = arrMusicLibrary.objectAtIndex(currentAudioIndex)["pic"] as! String
        
        let imgURL = NSURL(string: coverurlString)
        
        
        let block: SDWebImageCompletionBlock! = {(image: UIImage!, error: NSError!, cacheType: SDImageCacheType!, imageURL: NSURL!) -> Void in
            
        }
        
        
        imgMusicCover.sd_setImageWithURL(imgURL, completed:block)
        imgMusicCover.sd_setImageWithURL(imgURL) { (img, objerror, nil, imgURL) in
            let artImage: UIImage = self.imgMusicCover.image!
            let artwork: MPMediaItemArtwork = MPMediaItemArtwork(image: artImage)
            //
            
            //        let artImage: UIImage = UIImage(named: "BackGallery.png")!
            //        var artwork: MPMediaItemArtwork = MPMediaItemArtwork(image: artImage)
            
            
            
            
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
                MPMediaItemPropertyArtist: artistname as! String,
                MPMediaItemPropertyTitle: songName as! String,
                MPNowPlayingInfoPropertyPlaybackRate : NSNumber(double: self.audioPlayer.rate != 0 && self.audioPlayer.error == nil ? 1.0 : 0),
                //            MPMediaItemPropertyArtwork: UIImage(named: "play.png")!,
                MPMediaItemPropertyArtwork: artwork
                
            ]

        }
        //arrMusicLibrary.objectAtIndex(currentAudioIndex)["pic"] as! String
        
        if (imgMusicCover.image != nil) {
            
        }
        
       

 

    }
    
    func downloadImage(url:NSURL, completion: ((image: UIImage?) -> Void)){
        print("Started downloading \"\(url.URLByDeletingPathExtension!.lastPathComponent!)\".")
        getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                print("Finished downloading \"\(url.URLByDeletingPathExtension!.lastPathComponent!)\".")
                
                
                completion(image: UIImage(data: data!))
                
            }
        }
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data)
            }.resume()
    }
    
    func update(timer: NSTimer){
        if !(audioPlayer.rate != 0 && audioPlayer.error == nil){
            return
        }
        
        
        
        let timeNow = Double(audioPlayer.currentTime().value) / Double(audioPlayer.currentTime().timescale)
        
//        let currentMins = timeNow / 60
//        let currentSec = timeNow % 60
        
        let hour_   = abs(Int(timeNow)/3600)
        let minute_ = abs(Int(timeNow) / 60)
        let second_ = abs(Int(timeNow)  % 60)

        let hour = hour_ > 9 ? "\(hour_)" : "0\(hour_)"
        let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
        let second = second_ > 9 ? "\(second_)" : "0\(second_)"

        lblCurrentTime.text  = "\(hour):\(minute):\(second)"
        sliderMusic.value = Float(timeNow)
    }
    
    
    
    
    func showTotalSurahLength(){
        calculateSurahLength()
        lblTotalTime.text = totalLengthOfAudio
    }
    
    
    func calculateSurahLength(){
        let hour_ = abs(Int(audioLength/3600))
        let minute_ = abs(Int((audioLength/60) % 60))
        let second_ = abs(Int(audioLength % 60))
        
        let hour = hour_ > 9 ? "\(hour_)" : "0\(hour_)"
        let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
        let second = second_ > 9 ? "\(second_)" : "0\(second_)"
        totalLengthOfAudio = "\(hour):\(minute):\(second)"
    }
    @IBAction func sliderVolumeAction(sender: UISlider) {
        
        let selectedValue = Float(sender.value)
        audioPlayer.volume = selectedValue
        
    }
    @IBAction func sliderMusicAction(sender: UISlider)
    {
        //        audioPlayer.currentTime = NSTimeInterval(sender.value)
        
        let maxDuration : CMTime = CMTimeMake(Int64(sliderMusic.value), 1)
        
        audioPlayer.seekToTime(maxDuration)
        audioPlayer.play()
        
    }
    
    @IBAction func btnShareTapped(sender: AnyObject) {
        var sharingItems = [AnyObject]()
        
     //   let songName = imgMusicCover.image as! UIImage
        let google = NSURL(string:"https://appsto.re/gb/gYOo8.i")!
        
        
        sharingItems.append(google)
        
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
        
    }
    
    
    
    
    

}
