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
    @IBOutlet weak var cancelledLabel: UILabel!
    @IBOutlet weak var subView: RoundedView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with ride: Ride) {
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Passenger.rawValue {
            riderName.isHidden = true
        }
        if ride.rideStatus == RideStatus.rideCancelled.rawValue {
            cancelledLabel.isHidden = false
            ridePickupAddress.isHidden = true
            rideDropoffAddress.isHidden = true
            subView.backgroundColor = #colorLiteral(red: 0.995932281, green: 0.2765177786, blue: 0.3620784283, alpha: 1)
        } 
        upcomingDate.text = ride.appointmentDate
        riderName.text = ride.passanger
        ridePickupAddress.text = "Pick-up: \(ride.pickupAddress)"
        rideDropoffAddress.text = "Drop-off \(ride.dropoffAddress)"
        selectionStyle = .none
    }
    
}
