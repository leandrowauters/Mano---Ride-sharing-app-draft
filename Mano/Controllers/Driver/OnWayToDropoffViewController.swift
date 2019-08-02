//
//  OnWayToDropoffViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 8/1/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import CoreLocation

class OnWayToDropoffViewController: UIViewController {
    
    let ride: Ride!
    private var graphics =  GraphicsClient()
    var thirtySecondTimer = 0
    private var userLocation = CLLocation()
    private var locationManager = CLLocationManager()
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var destinationName: UILabel!
    @IBOutlet weak var destinationAddress: UILabel!
    @IBOutlet weak var pulseView: CircularView!
    @IBOutlet weak var driverImage: UIImageView!
    @IBOutlet weak var arrivedButton: CircularButton!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var driverMakeModelLabel: UILabel!
    @IBOutlet weak var driverLicencePlateLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupCoreLocation()
        thirtyMinTimer()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        thirtyMinTimer()
        calculateMilesToDropoff()
    }
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, ride: Ride) {
        self.ride = ride
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setup() {
        locationManager.delegate = self
        graphics.pulsating(view: pulseView)
        if let userPhotoURL = URL(string: ride.driveProfileImage)
        {
            driverImage.kf.setImage(with: userPhotoURL)
            driverNameLabel.text = ride.driverName
            driverMakeModelLabel.text = ride.driverMakerModel
            driverLicencePlateLabel.text = ride.licencePlate
            destinationName.text = ride.dropoffName
            destinationAddress.text = ride.dropoffAddress
        }
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Rider.rawValue {
            arrivedButton.isHidden = true
        }
    }
    
    private func setupCoreLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            // we need to say how accurate the data should be
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // closest location accuracy
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()// this is only while the app is unlocked
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    @objc private func thirtyMinTimer() {
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            if self.thirtySecondTimer == 30 {
                self.calculateMilesToDropoff()
                self.thirtySecondTimer = 0
            } else {
                self.thirtySecondTimer += 1
            }
        }
    }
    func calculateMilesToDropoff() {
        GoogleHelper.calculateMilesAndTimeToDestination(pickup: false, ride: ride, userLocation: userLocation) { (miles, time) in
            self.distanceLabel.text = "Distance: \n \(miles) Mil"
            self.durationLabel.text = "Duration: \n \(time)"
            self.activityIndicator.stopAnimating()
        }
    }
    private func searchGoogleForDirections() {
        GoogleHelper.openGoogleMapDirection(currentLat: ride.originLat, currentLon: ride.originLon, destinationLat: self.ride.pickupLat, destinationLon: self.ride.pickupLon, completion: { (error) in
                if let error = error {
                    self.showAlert(title: "Error opening google maps", message: error.localizedDescription)
                }
            })
    }
    
    @IBAction func arrivedPressed(_ sender: Any) {
    }
    
    @IBAction func googleMapsPressed(_ sender: Any) {
        showConfimationAlert(title: "Open Google Maps", message: nil) { (okay) in
            self.searchGoogleForDirections()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension OnWayToDropoffViewController: CLLocationManagerDelegate {
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
