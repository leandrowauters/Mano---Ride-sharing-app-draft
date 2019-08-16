//
//  DriverRideCompletedViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 8/15/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit

class DriverRideCompletedViewController: UIViewController {

    private var ride: Ride!
    
    @IBOutlet weak var passengerNameLabel: UILabel!
    @IBOutlet weak var milesTodayLabel: UILabel!
    @IBOutlet weak var totalMilesLabel: UILabel!
    @IBOutlet weak var numberOfRides: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        updateDriverStats(ride: ride)
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, ride: Ride) {
        self.ride = ride
        super.init(nibName: nil, bundle: nil)
    }
    
    private func setup() {
        passengerNameLabel.text = ride.passanger
        milesTodayLabel.text = "Miles Today:\n\(ride.totalMiles.description)"
    }
    
    private func updateDriverStats(ride: Ride) {
        DBService.updateDriverStats(ride: ride) { (error, manoUser) in
            if let error = error {
                self.showAlert(title: "Error updating stats", message: error.localizedDescription)
            }
            if let manoUser = manoUser {
                self.totalMilesLabel.text = "Total Miles:\n\(manoUser.numberOfMiles?.description ?? "N/A")"
                self.numberOfRides.text = "Number Of Rides:\n\(manoUser.numberOfRides?.description ?? "N/A")"
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func addToRegularPressed(_ sender: Any) {
        
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        
    }
    

    
}
