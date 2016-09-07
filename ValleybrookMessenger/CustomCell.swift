//
//  CustomCell.swift
//  ValleybrookMessenger
//
//  Created by Adam Zarn on 9/6/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    
    
    @IBOutlet weak var group: UILabel!
    @IBOutlet weak var subscribed: UISwitch!
    
    func setCell(group: String, subscribed: Bool) {
        self.group.text = group
        self.subscribed.on = subscribed
    }
    
}
