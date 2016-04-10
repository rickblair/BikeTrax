//
//  FirstViewController.swift
//  BikeTrax
//
//  Created by Blair, Rick on 3/31/16.
//  Copyright © 2016 Blair, Rick. All rights reserved.
//

import UIKit
import MessageUI

class FirstViewController: UIViewController, ButtonProtocol {

    let blueTooth = BTDelegate.sharedInstance();
    var timer = NSTimer()
    
    var currentlyRecording = "straight"
    var currentSwitch: UISwitch!
    var isRecording: Bool = false

    
    @IBOutlet weak var right_switch: UISwitch!
    @IBOutlet weak var straight_switch: UISwitch!
    @IBOutlet weak var left_switch: UISwitch!
    @IBOutlet weak var record_btn: UIButton!

    @IBOutlet weak var output_textview: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        currentSwitch = straight_switch
        
        //TODO: This should be a method or something.
        self.view.addSubview(blueTooth.deviceSelect.tableView)
        
        blueTooth.buttonDelegate = self;
       
    }

    
//MARK: Recording *****************************************
    func RecordingHandler() {
        
        if (isRecording){
            isRecording = false
            record_btn.setTitle("Record", forState: UIControlState.Normal)
            //TODO:change background color to green. maybe via an image.
            
            timer.invalidate()

            blueTooth.stopRecording();
            blueTooth.getRunData("0");
            
        } else {
            isRecording = true
            record_btn.setTitle("Stop Recording", forState: UIControlState.Normal)
            //TODO:change background color to red. maybe via an image.
            
            
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "RecordingFeedback", userInfo: nil, repeats: true)
            
            recordingHandler_sessionRecordings.append(blueTooth.startRecordingWithRunName(currentlyRecording))
        }
    }
    
    
    func RecordingFeedback(){
        let tagData = blueTooth.getCurrentData()
        
        if(tagData != nil){
            output_textview.text = String(tagData.getOutputString())
        } else {
            output_textview.text = "NO DATA"
        }
    }
    
// ****************************************************************************************
    
//MARK: These are the callbacks for button presses ****************************************
    
    func key1Pressed() {
        RecordingHandler()
        print("****** Key One Pressed");
    }
    
    func key1Released() {
        print("****** Key One Released");
    }
    
    func key2Pressed() {
        RecordingHandler()
        print("****** Key TWO Pressed");
    }
    
    func key2Released() {
        print("****** Key TWO Released");
    }
    
    func reedRelayOn() {
        print("****** REED On");
    }
    
    func reedRelayOff() {
        print("****** REED OFF");
    }
   
    
//MARK: UI EVENT HANDLERS ****************************************
    @IBAction func record_btn_pressed(sender: AnyObject) {
        RecordingHandler()
    }
    
    @IBAction func switch_on(sender: UISwitch) {
        
        if sender.on {
            if currentSwitch != nil {
                currentSwitch.setOn(false, animated: true)
            }
            currentSwitch = sender

            if sender.isEqual(left_switch) {
                currentlyRecording = "left turn"
            }
            
            if sender.isEqual(straight_switch){
                currentlyRecording = "straight"
            }
            
            if sender.isEqual(right_switch) {
                currentlyRecording = "right turn"
            }
            
        } else {
            currentlyRecording = "unknown"
            currentSwitch = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//NOTES. PLaying sound
    //http://stackoverflow.com/questions/33068930/swift-2-xcode-7-sound-playing-when-wrong-button-is-pressed
    
    
    
}

