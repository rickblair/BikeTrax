//
//  FirstViewController.swift
//  BikeTrax
//
//  Created by Blair, Rick on 3/31/16.
//  Copyright © 2016 Blair, Rick. All rights reserved.
//

import UIKit



class FirstViewController: UIViewController {

    var blueTooth = BTDelegate();
    var timer = NSTimer()
    let recordingHandler: RecordingHandler = RecordingHandler()
    
    @IBOutlet weak var right_switch: UISwitch!
    @IBOutlet weak var straight_switch: UISwitch!
    @IBOutlet weak var left_switch: UISwitch!
    @IBOutlet weak var record_btn: UIButton!

    @IBOutlet weak var output_textview: UITextView!
    
    var currentlyRecording = "straight"
    var currentSwitch: UISwitch!
    var isRecording: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

//        currentlyRecording = "straight"
        currentSwitch = straight_switch
        
        //TODO: This should be a method or something.
        self.view.addSubview(blueTooth.deviceSelect.tableView)
        
        //TODO: small hardware button (btn 2) should start recording play a sound (ding) and the big hardware button (btn 1) should stop recording and play a sound twice (ding ding)
    }
    
    func recordFunction ()
    {
        
        output_textview.text = String(blueTooth.currentData.getOutputString())
    }
    

    @IBAction func record_btn_pressed(sender: AnyObject) {
     
        if (isRecording){
            recordingHandler.StopRecording()
            isRecording = false
            record_btn.setTitle("Record", forState: UIControlState.Normal)
            timer.invalidate()

        } else {
            recordingHandler.StartRecording(currentlyRecording)
            isRecording = true
            record_btn.setTitle("Stop Recording", forState: UIControlState.Normal)

            //TODO: the intent here is to display frequent readings as a way to give feedback to the user.
            //CHS: I chose light because sometimes other values are empty and the app crashes
            
             timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(FirstViewController.recordFunction), userInfo: nil, repeats: true)
            output_textview.text = String(blueTooth.currentData.light)
        }
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


}

