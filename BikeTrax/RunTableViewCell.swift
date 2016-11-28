//
//  RunTableViewCell.swift
//  BikeTrax
//
//  Created by blair on 4/8/16.
//  Copyright © 2016 Blair, Rick. All rights reserved.
//

import UIKit

class RunTableViewCell: UITableViewCell {

    @IBOutlet var dateField: UITextField!
    
    @IBOutlet var nameField: UITextField!
    
    @IBOutlet var uploadLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
