//
//  DrawerViewCell.swift
//  NavigationDrawer
//
//  Created by treecat on 9/25/14.
//  Copyright (c) 2014 treecat. All rights reserved.
//

import UIKit

class DrawerViewCell: UITableViewCell {

    @IBOutlet var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
