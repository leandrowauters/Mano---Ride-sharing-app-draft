//
//  OnItsWayViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/24/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class OnItsWayViewController: UIViewController {

    private var duration: Int!
    private var distance: Int!
    private var ride: Ride!
    private var graphics =  GraphicsClient()
    var time = 0
    private var firstLocation = CLLocation()
    private var userLocation = CLLocation() {
        didSet {
            
        }
    }
    private var locationManager = CLLocationManager()
    
    private var distanceToLocation: Double! {
        didSet {
            self.distanceLabel.text = distanceToLocation.description
        }
    }

    @IBOutlet weak var driverImage: RoundedImageViewBlue!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var driverMakerModel: UILabel!

    @IBOutlet weak var driverLicense: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var arrivedButton: RoundedButton!
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var driverView: UIView!
    @IBOutlet weak var callDriverButton: UIButton!
    @IBOutlet weak var passangerName: UILabel!
    @IBOutlet weak var destinationAddress: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pulseView: CircularView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Driver.rawValue {
           sixtySecondTimer()
        } else {
            DBService.listenForDistanceDurationUpdates(ride: ride) { (error, ride) in
                if let error = error {
                    self.showAlert(title: "Error listening to updates", message: error.localizedDescription)
                }
                if let ride = ride {
                    self.durationLabel.text = "Duration: \n\(ride.durtation)"
                    self.distanceLabel.text = "Distance: \n\(ride.distance)"
                }
            }
        }
        setupCoreLocation()
        

    }
    override func viewDidAppear(_ animated: Bool) {
        calculateCurrentMilesToPickup()
    }

    @objc private func sixtySecondTimer() {
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            if self.time == 30 {
                self.calculateCurrentMilesToPickup()
                self.time = 0
            } else {
                self.time += 1
                print(self.time)
            }
        }
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
    private func searchGoogleForDirections() {
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Driver.rawValue{
            GoogleHelper.openGoogleMapDirection(currentLat: ride.originLat, currentLon: ride.originLon, destinationLat: self.ride.pickupLat, destinationLon: self.ride.pickupLon, completion: { (error) in
                if let error = error {
                    self.showAlert(title: "Error opening google maps", message: error.localizedDescription)
                }
            })
        }
    }
//    func getAverageDistance() -> Double {
//
//        let coreLocDistance = firstLocation.distance(from: userLocation)
//
//        let googleDistance = Double(self.distance)
//        let milesDistance = (googleDistance - Double(coreLocDistance)) * 0.000621371
//        return milesDistance
//    }
    func calculateCurrentMilesToPickup() {
        var destinationCLLocation = CLLocation()
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Rider.rawValue {
            destinationCLLocation = CLLocation(latitude: ride.originLat, longitude: ride.originLon)
        } else {
            destinationCLLocation = CLLocation(latitude: ride.pickupLat, longitude: ride.pickupLon)
        }

        let request = MKDirections.Request()
        let source = MKPlacemark(coordinate: userLocation.coordinate)
        let destination = MKPlacemark(coordinate: destinationCLLocation.coordinate)
        request.source = MKMapItem(placemark: source)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = MKDirectionsTransportType.automobile
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            if let response = response, let route = response.routes.last {
                let responseDistance = route.distance
                let miles = responseDistance * 0.000621371
                let milesRounded = Double(round(10*miles)/10)
                let time = route.expectedTravelTime
                let timeRoundedToSeconds = Int((time / 60).rounded(FloatingPointRoundingRule.down))
                self.distanceLabel.text = "Distance: \n \(milesRounded.description) Mil"
                self.durationLabel.text = "Duration: \n \(timeRoundedToSeconds.description) Min"
                self.activityIndicator.stopAnimating()
                DBService.updateDistanceAndDuration(ride: self.ride, duration: timeRoundedToSeconds, distance: milesRounded, completion: { (error) in
                    if let error = error {
                       self.showAlert(title: "Error updating", message: error.localizedDescription)
                    }
                    
                })
            }
        }

//        let distanceInMeters = userLocation.distance(from: destinationCLLocation)
//        let miles = distanceInMeters * 0.000621371
//        let milesRounded = Double(round(10*miles)/10)

    }
    private func setup() {
        locationManager.delegate = self
        graphics.pulsating(view: pulseView)
        if let userPhotoURL = URL(string: ride.driveProfileImage)
           {
            driverImage.kf.setImage(with: userPhotoURL)
            driverNameLabel.text = ride.driverName
            driverMakerModel.text = ride.driverMakerModel
            driverLicense.text = ride.licencePlate
        }
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Driver.rawValue {
            passangerName.text = ride.passanger
            destinationAddress.text = ride.pickupAddress
            carImageView.isHidden = true
            callDriverButton.isHidden = true
            
        } else {
            if let userCarPhotoURL = URL(string: ride.carPicture) {
                carImageView.kf.setImage(with: userCarPhotoURL)
                driverView.isHidden = true
                
            }
        }

    }
    
    @IBAction func morePressed(_ sender: Any) {
        
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
    
    @IBAction func arrivedPressed(_ sender: Any) {
    }
    
    @IBAction func callDriverPressed(_ sender: Any) {
        
    }
    
    @IBAction func googleMapsPressed(_ sender: Any) {
        showConfimationAlert(title: "Open Google Maps", message: nil) { (okay) in
            self.searchGoogleForDirections()
        }
    }
    
    
    @IBAction func callPassanger(_ sender: Any) {
    }
    
}
extension OnItsWayViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
//        locationManager.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {return}
        userLocation = currentLocation
        firstLocation = locations.first!
        
    }
}
