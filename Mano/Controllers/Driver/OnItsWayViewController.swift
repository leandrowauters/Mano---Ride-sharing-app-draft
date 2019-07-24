//
//  OnItsWayViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/24/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import CoreLocation

class OnItsWayViewController: UIViewController {

    private var duration: Int!
    private var distance: Int!
    private var ride: Ride!
    
    private var userLocation = CLLocation()
    private var locationManager = CLLocationManager()
    
    @IBOutlet weak var driversImage: RoundedImageView!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var driverMakerModel: UILabel!
    @IBOutlet weak var pickupAddressLabel: UILabel!
    @IBOutlet weak var dropoffAddressLabel: UILabel!
    @IBOutlet weak var distanceLabelAndDuration: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, duration: Int, distance: Int, ride: Ride) {
        self.duration = duration
        self.distance = distance
        self.ride = ride
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        locationManager.delegate = self
        if let photoURL = URL(string: ride.driveProfileImage) {
            driversImage.kf.setImage(with: photoURL)
            driverNameLabel.text = ride.driverName
            driverMakerModel.text = ride.driverMakerModel
            pickupAddressLabel.text = ride.pickupAddress
            dropoffAddressLabel.text = ride.dropoffAddress
            distanceLabelAndDuration.text = "15 Mins / 5 Miles"
            
        }
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Driver.rawValue{
            GoogleHelper.openGoogleMapDirection(currentLat: self.userLocation.coordinate.latitude, currentLon: self.userLocation.coordinate.longitude, destinationLat: self.ride.pickupLat, destinationLon: self.ride.pickupLon, completion: { (error) in
                if let error = error {
                    self.showAlert(title: "Error opening google maps", message: error.localizedDescription)
                }
            })
        }
    }

}
extension OnItsWayViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        locationManager.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {return}
        userLocation = currentLocation
        locationManager.stopUpdatingLocation()
    }
}
