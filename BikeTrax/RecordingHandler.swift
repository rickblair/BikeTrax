//
//  RecordingHandler.swift
//  BikeTrax
//
//  Created by Christian Hagel-Sorensen on 4/3/16.
//  Copyright © 2016 Blair, Rick. All rights reserved.
//

import Foundation
class RecordingHandler {
    
    private var isRecording: Bool!
    
    init(){
        isRecording = false
    }
    
    func StartRecording(currentlyRecording: String) -> Void {
        isRecording = true
        print(currentlyRecording)
    }
    
    func StopRecording() -> Void {
        isRecording = false
    }
    
    func IsRecording() -> Bool {
        return isRecording
    }
    
}