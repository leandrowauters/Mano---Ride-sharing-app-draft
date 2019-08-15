//
//  DriveTableViewCell.swift
//  Mano
//
//  Created by Leandro Wauters on 7/24/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit

class DriveTableViewCell: UITableViewCell {

    @IBOutlet weak var passangerName: UILabel!
    @IBOutlet weak var pickUpAddress: UILabel!
    @IBOutlet weak var dropoffAddress: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var duration: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
