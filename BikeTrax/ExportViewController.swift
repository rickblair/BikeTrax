//
//  ExportViewController.swift
//  BikeTrax
//
//  Created by Christian Hagel-Sorensen on 4/8/16.
//  Copyright © 2016 Blair, Rick. All rights reserved.
//


import UIKit
import MessageUI

class ExportViewController: UIViewController, ButtonProtocol, MFMailComposeViewControllerDelegate {
    
    let blueTooth = BTDelegate.sharedInstance();
    var runData: [RunInfo] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get all runs ever
        runData = blueTooth.getRuns()

        
    }
    
    
    @IBAction func ExportAll_Pressed(sender: AnyObject) {
        Export("all")
    }

    @IBAction func ExportSession_Pressed(sender: AnyObject) {
        Export("session")
    }
    
    

    
//MARK: Export *****************************************
    func Export(scope : String){
        
        let header = "TimeStamp (secs), Accel X, Accel Y, Accel Z, Gyro X, Gyro Y, Gyro Z, Loc X, Loc Y, Loc Z, Mag X, Mag Y, Mag Z"
        
        var body = ""
        

        //TODO: if "all" iterate over all runs. 
        //if session, iterate over recordingHandler_sessionRecordings

        //this is a hack to get everything;
        //6 plus has #of runs 65
        // 5s has #of runs 113
        
        var sensorData = [AnyObject]()
        
        //for runID in sessionRecordings
        
        for runID in 1...113 {
            body = body + "\n \(runID) \n"
            //TODO: add runID.name -> RnB can we expose that please?
            
            sensorData = blueTooth.getRunData(String(runID))
            
            for row in sensorData {
                let rowData = row as! SensorTagData
                body = body + SensorTagDataToString(rowData) + "\n"
            }
        }
        
        let output = header + body
        
        //This makes it possible to get the information from the debug console
        print(output)
        
        //Make an Email with all the data.
        let picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setSubject("Bike Trax Exports 5s")
        picker.setMessageBody(output, isHTML: false)
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    
    //Mail Delegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
        //TODO Add handling for errors.
    }
    
    func SensorTagDataToString(dataRow: SensorTagData) -> String{
        
        var returnStrings = [String]()
        
        returnStrings.append(String(format:"%f", dataRow.timestamp))
        
        returnStrings.append(String(format:"%.4f", dataRow.accelX))
        returnStrings.append(String(format:"%.4f", dataRow.accelY))
        returnStrings.append(String(format:"%.4f", dataRow.accelZ))
        
        returnStrings.append(String(format:"%.4f", dataRow.gyroX))
        returnStrings.append(String(format:"%.4f", dataRow.gyroY))
        returnStrings.append(String(format:"%.4f", dataRow.gyroZ))
        
        returnStrings.append(String(format:"%.4f", dataRow.locX))
        returnStrings.append(String(format:"%.4f", dataRow.locY))
        returnStrings.append(String(format:"%.4f", dataRow.locZ))
        
        returnStrings.append(String(format:"%.4f", dataRow.magX))
        returnStrings.append(String(format:"%.4f", dataRow.magY))
        returnStrings.append(String(format:"%.4f", dataRow.magZ))
        
        
        var returnString = ""
        
        for value in returnStrings{
            returnString = returnString + value + ","
        }
        
        //TODO: trim the last comma
//        returnString = returnString.stringby... 
        
        return returnString
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
