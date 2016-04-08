//
//  FirstViewController.swift
//  BikeTrax
//
//  Created by Blair, Rick on 3/31/16.
//  Copyright © 2016 Blair, Rick. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, ButtonProtocol {

    let blueTooth = BTDelegate.sharedInstance();
    var timer = NSTimer()
    var sessionRecordings = [String]()
    
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
        
        //TODO: small hardware button (btn 2) should start recording play a sound (ding) and the big hardware button (btn 1) should stop recording and play a sound twice (ding ding)
        
        //RnB added button BTDelegate
        blueTooth.buttonDelegate = self;
       
    }
    
    func RecordingHandler() {
        if (isRecording){
            isRecording = false
            record_btn.setTitle("Record", forState: UIControlState.Normal)
            timer.invalidate()

            blueTooth.stopRecording();
            blueTooth.getRunData("0");
            
        } else {
            isRecording = true
            record_btn.setTitle("Stop Recording", forState: UIControlState.Normal)
            
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "RecordingFeedback", userInfo: nil, repeats: true)
            
            sessionRecordings.append(blueTooth.startRecordingWithRunName(currentlyRecording))
        }
    }
    
    
    func RecordingFeedback(){
        let tagData = blueTooth.getCurrentData()
        
        if(tagData != nil)
        {
            output_textview.text = String(tagData.getOutputString())
        }
        else
        {
            output_textview.text = "NO DATA"
        }
    }
    
    func Export(){
    
        let header = "Accel X, Accel Y, Accel Z, Gyro X, Gyro Y, Gyro Z, Loc X, Loc, Y, Loc Z, Mag X, Mag Y, Mag Z"

        var body = ""
        
        //TODO: THEN APPEND ALL THE OTHER STRINGS TO IT TO MAKE A CSV
        
        var sensorData = [AnyObject]()
        
        for runID in sessionRecordings {
            body = body + "\n" + runID + "\n"
            //TODO: add runID.name -> RnB can we expose that please?
            
            sensorData = blueTooth.getRunData(runID)
            
            for row in sensorData {
                let rowData = row as! SensorTagData
                body = body + SensorTagDataToString(rowData) + "\n"
            }
        }
        
        //TODO: Actually do an export
        let output = header + body
        print(output)
    }
    

    func SensorTagDataToString(dataRow: SensorTagData) -> String{
        
        var returnStrings = [String]()
        
        //TODO: Incomplete
        returnStrings.append(String(format:"%.2f", dataRow.accelX))
        returnStrings.append(String(format:"%.2f", dataRow.accelY))
        returnStrings.append(String(format:"%.2f", dataRow.accelZ))

        returnStrings.append(String(format:"%.2f", dataRow.gyroX))
        returnStrings.append(String(format:"%.2f", dataRow.gyroY))
        returnStrings.append(String(format:"%.2f", dataRow.gyroZ))

        returnStrings.append(String(format:"%.2f", dataRow.locX))
        returnStrings.append(String(format:"%.2f", dataRow.locY))
        returnStrings.append(String(format:"%.2f", dataRow.locZ))

        returnStrings.append(String(format:"%.2f", dataRow.magX))
        returnStrings.append(String(format:"%.2f", dataRow.magY))
        returnStrings.append(String(format:"%.2f", dataRow.magZ))

        var returnString = ""
        
        for value in returnStrings{
            returnString = returnString + value + ","
        }
        
        //TODO: trim the last comma
        return returnString
    }
    
    
    
//MARK: These are the callbacks for button presses
    
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
   
    
    
    
//MARK: UI EVENT HANDLERS /////////////////////////////////////////
    @IBAction func record_btn_pressed(sender: AnyObject) {
        RecordingHandler()
    }
    
    @IBAction func export_btn_pressed(sender: AnyObject) {
        Export()
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

