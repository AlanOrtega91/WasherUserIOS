//
//  CarCell.swift
//  Vashen
//
//  Created by Alan on 8/16/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import UIKit

class CarCell: UITableViewCell {

    @IBOutlet weak var plates: UILabel!
    @IBOutlet weak var brand: UILabel!
    @IBOutlet weak var selectedIndicator: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
