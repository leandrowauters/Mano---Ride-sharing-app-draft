//
//  WaitingForRequestViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 8/7/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import CoreLocation

class WaitingForRequestViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var driverView: UIView!
    @IBOutlet weak var passengerView: UIView!
    @IBOutlet weak var pulsingView: CircularViewNoBorder!
    
    private var userLocation = CLLocation()
    private var locationManager = CLLocationManager()
    var thirtySecondTimer = 0
    var ride: Ride!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCoreLocation()
        setup()
    }
    override func viewDidAppear(_ animated: Bool) {
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Driver.rawValue {
            thirtyMinTimer()
            calculateCurrentMilesToPickup()
        } else {
            DBService.listenForDistanceDurationUpdates(ride: ride) { (error, ride) in
                if let error = error {
                    self.showAlert(title: "Error listening", message: error.localizedDescription)
                }
                if let ride = ride {
                    self.distanceLabel.text = "Distance: \n \(ride.durtation) Mins away"
                }
            }
        }
    }
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, ride: Ride) {
        self.ride = ride
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Driver.rawValue {
            locationManager.delegate = self
            titleLabel.text = "Waiting For  Request "
            messageLabel.text = "PLEASE KEEP APP OPEN TO SHARE LOCATION"
        } else {
            messageLabel.text = "PLEASE GIVE DRIVER ENOUGH TIME BEFORE YOUR REQUEST"
            titleLabel.text = "Request Ride Back Home"
            passengerView.isHidden = false
            driverView.isHidden = true
        }
    }
    
    private func setupCoreLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    @objc private func thirtyMinTimer() {
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            if self.thirtySecondTimer == 30 {
                self.calculateCurrentMilesToPickup()
                self.thirtySecondTimer = 0
            } else {
                self.thirtySecondTimer += 1
            }
        }
    }
    
    func calculateCurrentMilesToPickup() {
        GoogleHelper.calculateMilesAndTimeToDestination(pickup: false, ride: ride, userLocation: userLocation) { (miles, time, milesInt, timeInt) in
            self.distanceLabel.text = "Distance: \n \(time) Away"
            DBService.updateRideDurationDistance(ride: self.ride, distance: milesInt, duration: timeInt, completion: { (error) in
                if let error = error {
                    self.showAlert(title: "Error updating duration", message: error.localizedDescription)
                }
            })
        }
    }
    
    @IBAction func requestRidePressed(_ sender: Any) {
        
    }
    @IBAction func phonePressed(_ sender: Any) {
        
    }
    @IBAction func messagePressed(_ sender: Any) {
        
    }
    
    


}

extension WaitingForRequestViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        //        locationManager.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {return}
        userLocation = currentLocation
    }
}
