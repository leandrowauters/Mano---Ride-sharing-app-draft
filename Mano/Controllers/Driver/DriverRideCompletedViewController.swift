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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateToRideIsOver()
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
    private func updateToRideIsOver() {
        DBService.updateRideStatus(ride: ride, status: RideStatus.rideIsOver.rawValue) { (error, ride) in
            if let error = error {
                self.showAlert(title: "Error updating ride status", message: error.localizedDescription)
            }
            if let ride = ride {
                self.ride = ride
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func addToRegularPressed(_ sender: Any) {
        DBService.addUserToRegulars(regularId: ride.passangerId) { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Error adding user", message: error.localizedDescription)
            } else {
                self?.showAlert(title: "\(self?.ride.passanger ?? "") added to regulars", message: nil)
            }
        }
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        activityIndicator.startAnimating()
        DBService.addRideToRides(ride: ride) { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Error adding ride", message: error.localizedDescription)
            } else {
                self?.activityIndicator.stopAnimating()
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}
