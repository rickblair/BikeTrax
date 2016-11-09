//
//  FirstViewController.swift
//  BikeTrax
//
//  Created by Blair, Rick on 3/31/16.
//  Copyright © 2016 Blair, Rick. All rights reserved.
//

import UIKit
import MessageUI

class FirstViewController: UIViewController, ButtonProtocol, UITextFieldDelegate {

    let blueTooth = BTDelegate.sharedInstance();
    var timer = Timer()
    
    var currentlyRecording = "straight"
    var currentSwitch: UISwitch!
    var isRecording: Bool = false

    @IBOutlet weak var runNameText: UITextField!
    
    @IBOutlet weak var right_switch: UISwitch!
    @IBOutlet weak var straight_switch: UISwitch!
    @IBOutlet weak var left_switch: UISwitch!
    @IBOutlet weak var standup_switch: UISwitch!
    @IBOutlet weak var sitdown_switch: UISwitch!
    @IBOutlet weak var slalom_switch: UISwitch!
    
    
    @IBOutlet weak var record_btn: UIButton!
    

    @IBOutlet weak var output_textview: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.runNameText.delegate = self;

        currentSwitch = straight_switch
        
        //TODO: This should be a method or something.
        self.view.addSubview((blueTooth?.deviceSelect.tableView)!)
        
        blueTooth?.buttonDelegate = self;
       
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
//MARK: Recording *****************************************
    func RecordingHandler() {
        
        if (isRecording){
            isRecording = false
            record_btn.setTitle("Record", for: UIControlState())
            //TODO:change background color to green. maybe via an image.
            
            timer.invalidate()

            blueTooth?.stopRecording();
            blueTooth?.getRunData("0");
            
        } else {
            isRecording = true
            record_btn.setTitle("Stop Recording", for: UIControlState())
            //TODO:change background color to red. maybe via an image.
            
            
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(FirstViewController.RecordingFeedback), userInfo: nil, repeats: true)
            
            blueTooth?.startRecording(withRunName: currentlyRecording);

            //GIves a way to add context to the run
            var runName = currentlyRecording

            if !(runNameText.text?.isEmpty)! {
                runName = runName + " " + runNameText.text!
            }
            
            
            recordingHandler_sessionRecordings.append((blueTooth?.startRecording(withRunName: runName))!)
        }
    }
    
    
    func RecordingFeedback(){
        let tagData = blueTooth?.getCurrentData()
        
        if(tagData != nil){
            output_textview.text = String(describing: tagData?.getOutputString())
        } else {
            output_textview.text = "NO DATA"
        }
    }
    
// ****************************************************************************************
    
    
    
//MARK: These are the callbacks for button presses
    func key1Pressed() {
        RecordingHandler()
        //TODO: need a way to record soemthign in the data here and a sound to sync video and data. 
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
    @IBAction func record_btn_pressed(_ sender: AnyObject) {
        RecordingHandler()
    }
    
    @IBAction func switch_on(_ sender: UISwitch) {
        
        if sender.isOn {
            if currentSwitch != nil {
                currentSwitch.setOn(false, animated: true)
            }
            currentSwitch = sender

            if sender.isEqual(left_switch) {
                currentlyRecording = "Left turn"
            }
            
            if sender.isEqual(straight_switch){
                currentlyRecording = "Straight"
            }
            
            if sender.isEqual(right_switch) {
                currentlyRecording = "Right turn"
            }

            if sender.isEqual(standup_switch) {
                currentlyRecording = "Standup pedallng"
            }

            if sender.isEqual(sitdown_switch) {
                currentlyRecording = "Sit down pedalling"
            }

            if sender.isEqual(slalom_switch) {
                currentlyRecording = "Slalom"
            }

        } else {
            currentlyRecording = "Other"
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

