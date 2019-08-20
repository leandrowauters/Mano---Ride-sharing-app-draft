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

    override func prepareForReuse() {
        super.prepareForReuse()
        subView.alpha = 1
        cancelledLabel.isHidden = true
        isUserInteractionEnabled = true
        ridePickupAddress.isHidden = false
        rideDropoffAddress.isHidden = false
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Passenger.rawValue {
            riderName.isHidden = false
        }
        
    }
    func configure(with ride: Ride, upcoming: Bool) {
        if upcoming {

            if ride.rideStatus == RideStatus.rideRequested.rawValue {
                riderName.text = "Ride Status: Requested"
                subView.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            } else if ride.rideStatus == RideStatus.rideAccepted.rawValue {
                riderName.text = "Ride Status: Accepted!"
                subView.backgroundColor = #colorLiteral(red: 0, green: 0.7077997327, blue: 0, alpha: 1)
            } else if ride.rideStatus == RideStatus.rideCancelled.rawValue {
                if DBService.currentManoUser.typeOfUser == TypeOfUser.Passenger.rawValue {
                    riderName.isHidden = true
                }
                cancelledLabel.isHidden = false
                ridePickupAddress.isHidden = true
                rideDropoffAddress.isHidden = true
                subView.backgroundColor = #colorLiteral(red: 0.995932281, green: 0.2765177786, blue: 0.3620784283, alpha: 1)
                subView.alpha = 0.5
                isUserInteractionEnabled = false
            }
            
            
            rideDropoffAddress.text = "Drop-off \(ride.dropoffAddress)"
            if DBService.currentManoUser.typeOfUser == TypeOfUser.Driver.rawValue {
                riderName.text = ride.passanger
            }
        } else {
            rideDropoffAddress.text = "Total Miles: \(Int(ride.totalMiles))"
            if DBService.currentManoUser.typeOfUser == TypeOfUser.Driver.rawValue {
                riderName.text = ride.passanger
            } else {
              riderName.isHidden = true
            }
            subView.backgroundColor = #colorLiteral(red: 0.9882352941, green: 0.5137254902, blue: 0.2039215686, alpha: 1)
        }
        
        upcomingDate.text = ride.appointmentDate
        ridePickupAddress.text = "Pick-up: \(ride.pickupAddress)"

        selectionStyle = .none
    }
    
}
