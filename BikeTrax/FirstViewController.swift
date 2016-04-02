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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //This should be a method or something.
        self.view.addSubview(blueTooth.deviceSelect.tableView)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

