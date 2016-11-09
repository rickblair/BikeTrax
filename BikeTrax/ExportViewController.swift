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
        runData = (blueTooth?.getRuns())!
    }
    
    
    @IBAction func ExportAll_Pressed(_ sender: AnyObject) {
        Mail("all")
    }

    @IBAction func ExportSession_Pressed(_ sender: AnyObject) {
        Mail("session")
    }

//MARK: Mail *****************************************
    
    //For large exports this gives an empty mail
    func Mail(_ scope: String) {
        
        //Make an Email with all the data.
        let picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setSubject("Bike Trax Exports")
        picker.setMessageBody(Export(scope), isHTML: false)
        
        present(picker, animated: true, completion: nil)
        
    }
    
    
    //Mail Delegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
        //TODO Add handling for errors.
    }
    
    func upload(_ scope : String) {
        
        
        //if "all" iterate over all runs.
        //if session, iterate over recordingHandler_sessionRecordings
        
        if scope == "all" {
            for run in runData
            {
                let json = run.toJSONString();
             //   print(json);
              //  print("\n")
            }
        } else {
            for runID in recordingHandler_sessionRecordings
            {
                let run = blueTooth?.getRunByID(runID)
                
                let json = run?.toJSONString();
               // print(json);
               // print("\n")
            }
        }
        
        
        
        
        return
    }


    
//MARK: Export *****************************************
    func Export(_ scope : String) -> String{
        
        let header = "Time,Accel-X,Accel-Y,Accel-Z,Gyro-X,Gyro-Y,Gyro-Z,Latitude-y,Longitude-x,GPS-Z,Mag-X,Mag-Y,Mag-Z,Speed,MPH,Altitude\n"
        
        var body = ""

        var sensorData = [AnyObject]()

        //Upload runs to the server.
        upload(scope)
        
        //if "all" iterate over all runs.
        //if session, iterate over recordingHandler_sessionRecordings
        if scope == "all" {
            for run in runData{
                sensorData = blueTooth!.getRunData(String(run.runID)) as [AnyObject]
                
                body = body + header + run.name + "\n"
                
                for row in sensorData {
                    let rowData = row as! SensorTagData
                    body = body + SensorTagDataToString(rowData) + "\n"
                }
            }
        } else {
            for runID in recordingHandler_sessionRecordings{
                sensorData = blueTooth!.getRunData(String(runID)) as [AnyObject]
                
                //would be nice to be able to do
                //bluetooth.getRunName(runID) 
                
                for row in sensorData {
                    let rowData = row as! SensorTagData
                    body = body + SensorTagDataToString(rowData) + "\n"
                }
            }
        }
        
        
        let output = body
        print(output)

        return output
    }
    
    func SensorTagDataToString(_ dataRow: SensorTagData) -> String{
        
        var returnStrings = [String]()
        
        returnStrings.append(String(format:"%@", dataRow.getDateString()))
        
        returnStrings.append(String(format:"%.9f", dataRow.accelX))
        returnStrings.append(String(format:"%.9f", dataRow.accelY))
        returnStrings.append(String(format:"%.9f", dataRow.accelZ))
        
        returnStrings.append(String(format:"%.9f", dataRow.gyroX))
        returnStrings.append(String(format:"%.9f", dataRow.gyroY))
        returnStrings.append(String(format:"%.9f", dataRow.gyroZ))
        
        returnStrings.append(String(format:"%.9f", dataRow.locY))
        returnStrings.append(String(format:"%.9f", dataRow.locX))
        returnStrings.append(String(format:"%.9f", dataRow.locZ))
        
        returnStrings.append(String(format:"%.9f", dataRow.magX))
        returnStrings.append(String(format:"%.9f", dataRow.magY))
        returnStrings.append(String(format:"%.9f", dataRow.magZ))
        
        returnStrings.append(String(format:"%.9f", dataRow.speed))
        returnStrings.append(String(2.236936 * dataRow.speed)) //MPH
        
        returnStrings.append(String(format:"%.9f", dataRow.altitude))
        
        
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
