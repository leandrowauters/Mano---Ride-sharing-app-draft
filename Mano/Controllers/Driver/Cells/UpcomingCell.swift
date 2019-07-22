//
//  UpcomingCell.swift
//  Mano
//
//  Created by Leandro Wauters on 7/20/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit

class UpcomingCell: UITableViewCell {

    @IBOutlet weak var upcomingDate: UILabel!
    @IBOutlet weak var riderName: UILabel!
    @IBOutlet weak var ridePickupAddress: UILabel!
    @IBOutlet weak var rideDropoffAddress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
