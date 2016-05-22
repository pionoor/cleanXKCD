//
//  ViewController.swift
//  comic
//
//  Created by Noor Thabit on 9/24/15.
//  Copyright © 2015 Noor Thabit. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var imgScroll: UIScrollView!
    @IBOutlet weak var transcriptLable: UILabel!
    @IBOutlet weak var num: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var prev: UIButton!
    @IBOutlet weak var next: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet var img: UIImageView!
    @IBOutlet  weak var transcript: UITextView!
    
    var comicObj: Xkcd!
    
    @IBOutlet weak var alt: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        comicObj = Xkcd(JsonURL: "http://xkcd.com/info.0.json")
        
        transcriptLable.text = "Transcript"
        
        
        let doubleTap = UITapGestureRecognizer(target: self, action: "randImgDoubleTap:")
        doubleTap.numberOfTapsRequired = 2
        self.imgScroll.addGestureRecognizer(doubleTap)
        
        
        let saveImglongPress = UILongPressGestureRecognizer(target: self, action: "saveImgLongPress:")
        saveImglongPress.minimumPressDuration = 0.8
        self.imgScroll.addGestureRecognizer(saveImglongPress)
        
        let latestComiclongPress = UILongPressGestureRecognizer(target: self, action: "loadLatestComicLongPress:")
        latestComiclongPress.minimumPressDuration = 0.8
        self.next.addGestureRecognizer(latestComiclongPress)
        
        let firstComiclongPress = UILongPressGestureRecognizer(target: self, action: "loadFirstComicLongPress:")
        firstComiclongPress.minimumPressDuration = 0.8
        self.prev.addGestureRecognizer(firstComiclongPress)
        
        //adding swip gesture to img:UIImageView
        let swipRigh = UISwipeGestureRecognizer(target: self, action: "swipedGesture:")
        swipRigh.direction = UISwipeGestureRecognizerDirection.Right
        self.imgScroll.addGestureRecognizer(swipRigh)
        
        
        let swipLeft = UISwipeGestureRecognizer(target: self, action: "swipedGesture:")
        swipLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.imgScroll.addGestureRecognizer(swipLeft)
        
        //settig the minimum and max zoom scale for the image.
        self.imgScroll.minimumZoomScale = 1.0
        self.imgScroll.maximumZoomScale = 3.0
        
        //adding boarder to the trascript textview.
        transcript.layer.borderWidth = 1.0;
        transcript.layer.cornerRadius = 5.0;
        
        loadImg()
        loadText()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.img
    }
    
    //load the comic text info, such as title, transcript, and date.
    func loadText(){
        
        if self.comicObj.transcript == "" {
            self.transcript.text = "No transcript is avialable for this comic!"
        } else { transcript.text = comicObj.transcript }
        alt.text = comicObj.alt
        name.text = comicObj.title
        date.text = String("\(comicObj.month)/\(comicObj.day)/\(comicObj.year)")
        num.text = String("#\(comicObj.num)")
        
    }
    
    @IBAction func loadPrev(sender: UIButton) {
        
        //animation
        sender.highlighted = false
        UIView.animateWithDuration(0.2,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: {sender.alpha = 0.5},
            completion:{(finished:Bool) -> Void in
                
                UIView.animateWithDuration(0.1,
                    delay: 0.0,
                    options: UIViewAnimationOptions.CurveEaseIn,
                    animations: {sender.alpha = 1.0},
                    completion: nil)
        })
        prevComic()
    }
    
    @IBAction func loadNext(sender: UIButton) {
        //animation
        sender.highlighted = false
        UIView.animateWithDuration(0.2,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: {sender.alpha = 0.5},
            completion:{(finished:Bool) -> Void in
                UIView.animateWithDuration(0.1,
                    delay: 0.0,
                    options: UIViewAnimationOptions.CurveEaseIn,
                    animations: {sender.alpha = 1.0},
                    completion: nil)
        })
        nextComic()
    }
    
    
    //loads a new image into the UIImageview from a URL
    func loadImg(){
        let url = NSURL(string: comicObj.imageURL)
        let data = NSData(contentsOfURL: url!)
        img.image = UIImage(data: data!)
    }
    
    
    //loads the next webcomic image from xkcd.com
    func nextComic(){
        
        let nextPageNum = comicObj.num + 1;
        if nextPageNum == comicObj.latestNum + 1 {
            self.view.makeToast(message: "Latest Comic!", duration: 1.0, position: "center")        }
        guard nextPageNum > comicObj.latestNum  else {
            UIView.animateWithDuration(0.3,
                delay: 0.0,
                options: UIViewAnimationOptions.CurveEaseOut,
                animations: {self.img.alpha = 0.0},
                completion:{(finished:Bool) -> Void in
                    
                    let url = "http://xkcd.com/\(nextPageNum)/info.0.json"
                    self.comicObj.fetchJSON(url)
                    self.comicObj.parse()
                    self.loadImg()
                    self.loadText()
                    self.imgScroll.setZoomScale(1.0, animated: true)
                    UIView.animateWithDuration(0.3,
                        delay: 0.0,
                        options: UIViewAnimationOptions.CurveEaseIn,
                        animations: {self.img.alpha = 1.0},
                        completion: nil)
            })
            
            return
        }
        
    }
    
    
    
    func prevComic(){
        
        let prevPageNum = comicObj.num - 1;
        if prevPageNum == 0 {
            self.view.makeToast(message: "First Comic!", duration: 1.0, position: "center")
        }
        guard prevPageNum == 0 else {
            UIView.animateWithDuration(0.3,
                delay: 0.0,
                options: UIViewAnimationOptions.CurveEaseOut,
                animations: {self.img.alpha = 0.0},
                completion:{(finished:Bool) -> Void in
                    
                    let url = "http://xkcd.com/\(prevPageNum)/info.0.json"
                    self.comicObj.fetchJSON(url)
                    self.comicObj.parse()
                    self.loadImg()
                    self.loadText()
                    self.imgScroll.setZoomScale(1.0, animated: true)
                    if self.comicObj.transcript == "" {
                        self.transcript.text = "No transcript is avialable for this comic!"
                    }
                    UIView.animateWithDuration(0.3,
                        delay: 0.0,
                        options: UIViewAnimationOptions.CurveEaseIn,
                        animations: {self.img.alpha = 1.0},
                        completion: nil)
                    
            })
            return
        }
        
    }
    
    func latestComic(){
        
        let url = "http://xkcd.com/info.0.json"
        UIView.animateWithDuration(0.3,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: {self.imgScroll.alpha = 0.0},
            completion:{(finished:Bool) -> Void in
                self.comicObj.fetchJSON(url)
                self.comicObj.parse()
                self.loadImg()
                self.loadText()
                self.imgScroll.setZoomScale(1.0, animated: true)
                if self.comicObj.transcript == "" {
                    self.transcript.text = "No transcript is avialable for this comic!"
                }
                UIView.animateWithDuration(0.3,
                    delay: 0.0,
                    options: UIViewAnimationOptions.CurveEaseIn,
                    animations: {self.imgScroll.alpha = 1.0},
                    completion: nil)
        })
        
        
    }
    
    func firstComic(){
        
        let url = "http://xkcd.com/1/info.0.json"
        UIView.animateWithDuration(0.3,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: {self.imgScroll.alpha = 0.0},
            completion:{(finished:Bool) -> Void in
                self.comicObj.fetchJSON(url)
                self.comicObj.parse()
                self.loadImg()
                self.loadText()
                self.imgScroll.setZoomScale(1.0, animated: true)
                if self.comicObj.transcript == "" {
                    self.transcript.text = "No transcript is avialable for this comic!"
                }
                UIView.animateWithDuration(0.3,
                    delay: 0.0,
                    options: UIViewAnimationOptions.CurveEaseIn,
                    animations: {self.imgScroll.alpha = 1.0},
                    completion: nil)
        })
        
        
    }
    
    
    func randComic(){
        
        let rand = Int(arc4random_uniform(UInt32((comicObj.latestNum - 1) + 1))) + 1;
        let url = "http://xkcd.com/\(rand)/info.0.json"
        UIView.animateWithDuration(0.3,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: {self.imgScroll.alpha = 0.0},
            completion:{(finished:Bool) -> Void in
                
                self.comicObj.fetchJSON(url)
                self.comicObj.parse()
                self.loadImg()
                self.loadText()
                self.imgScroll.setZoomScale(1.0, animated: true)
                if self.comicObj.transcript == "" {
                    self.transcript.text = "No transcript is avialable for this comic!"}
                UIView.animateWithDuration(0.3,
                    delay: 0.0,
                    options: UIViewAnimationOptions.CurveEaseIn,
                    animations: {self.imgScroll.alpha = 1.0},
                    completion: nil)
        })
        
        
    }
    
    
    
    //handles swip left and right gestures on the image.
    func swipedGesture(gesture: UISwipeGestureRecognizer) {
        
        
        switch gesture.direction {
            
        case UISwipeGestureRecognizerDirection.Right :
            prevComic()
            
            
        case UISwipeGestureRecognizerDirection.Left:
            nextComic()
            
        default:
            break
            
        }
        
    }
    
    func randImgDoubleTap(gesture: UITapGestureRecognizer){
        
        randComic()
    }
    
    func saveImgLongPress(gesture: UILongPressGestureRecognizer){
        
        if (gesture.state == UIGestureRecognizerState.Ended) {
            
            
        } else if (gesture.state == UIGestureRecognizerState.Began) {
            
            let saveImgAlert = UIAlertController(title: nil, message: "Wanna save this one?", preferredStyle: UIAlertControllerStyle.Alert)
            
            saveImgAlert.addAction(UIAlertAction(title: "Sure", style: .Default, handler: { action in
                UIImageWriteToSavedPhotosAlbum(self.img.image!, self, nil, nil)
                     self.view.makeToast(message: "Saved!", duration: 1.0, position: "center")
            }))
            saveImgAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
            }))
            self.presentViewController(saveImgAlert, animated: true, completion: nil)
        }
        
        
    }
    
    func loadLatestComicLongPress(gesture: UILongPressGestureRecognizer){
        if (gesture.state == UIGestureRecognizerState.Ended) {
            
            
        }else if (gesture.state == UIGestureRecognizerState.Began) {
            
            latestComic()
        }
    }
    
    func loadFirstComicLongPress(gesture: UILongPressGestureRecognizer){
        if (gesture.state == UIGestureRecognizerState.Ended) {
            
            
        } else if (gesture.state == UIGestureRecognizerState.Began) {
            
            firstComic()
        }
    }
}

