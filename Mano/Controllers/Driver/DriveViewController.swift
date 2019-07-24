//
//  DriveViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/23/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import CoreLocation

class DriveViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    

    @IBOutlet weak var ridesTableView: UITableView!
    
    private var userLocation = CLLocation()
    private var locationManager = CLLocationManager()
    private var duration: Int?
    private var distance: Int?
    private var rides = [Ride]() {
        didSet {
            DispatchQueue.main.async {
                self.checkForRideToday()
                self.ridesTableView.reloadData()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        fetchYourAcceptedRides()
        setupCoreLocation()

        // Do any additional setup after loading the view.
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

    private func setup() {
        locationManager.delegate = self
        ridesTableView.register(UINib(nibName: "DriveTableViewCell", bundle: nil), forCellReuseIdentifier: "DriveTableViewCell")
        ridesTableView.delegate = self
        ridesTableView.dataSource = self
        
    }
    
    private func checkForRideToday() {
        if rides.isEmpty {
            showAlert(title: "No Rides Today", message: nil)
        }
    }
    
    private func fetchYourAcceptedRides() {
        DBService.fetchDriverAcceptedRides(driverId: DBService.currentManoUser.userId) { (error, rides) in
            if let error = error {
                self.showAlert(title: "Error fetching your rides", message: error.localizedDescription)
            }
            if let rides = rides {
                self.rides = rides.filter{ Calendar.current.isDateInToday($0.appointmentDate.stringToDate())}
            }
        }
    }
    
    private func updateRideToOnItsWay(ride: Ride) {
        DBService.updateDriverOntItsWay(ride: ride) { (error) in
            if let error = error {
                self.showAlert(title: "Error updating ride", message: error.localizedDescription)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rides.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DriveTableViewCell", for: indexPath) as? DriveTableViewCell else {return
            UITableViewCell()
        }
        let ride = rides[indexPath.row]
        cell.passangerName.text = ride.passanger
        cell.pickUpAddress.text = "Pick-up:\n \(ride.pickupAddress)"
        cell.dropoffAddress.text = "Drop-off:\n \(ride.dropoffAddress)"
        cell.distance.text = "Calculating..."
        cell.duration.text = "Calculating..."
        GoogleHelper.calculateDistanceToLocation(originLat: userLocation.coordinate.latitude, originLon: userLocation.coordinate.longitude, destinationLat: ride.dropoffLat, destinationLon: ride.dropoffLon) { (appError, distanceText, distanceInt) in
            if let appError = appError {
                self.showAlert(title: "Error", message: appError.localizedDescription)
            }
            if let distanceText = distanceText {
                DispatchQueue.main.async {
                    cell.distance.text = "Distance: \(distanceText)"
                }

            }
            if let distanceInt = distanceInt {
                self.distance = distanceInt
            }
        }
        GoogleHelper.calculateEta(originLat: userLocation.coordinate.latitude, originLon: userLocation.coordinate.longitude, destinationLat: ride.dropoffLat, destinationLon: ride.dropoffLon) { (appError, durationText, durationInt) in
            if let appError = appError {
                self.showAlert(title: "Error", message: appError.localizedDescription)
            }
            if let durationText = durationText {
                DispatchQueue.main.async {
                    cell.duration.text = "Duration: \(durationText)"
                }
            }
            if let durationInt = durationInt {
                self.duration = durationInt
            }
        }

        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 315
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ride = rides[indexPath.row]
        showAlert(title: "Begin Drive?", message: "\(ride.passanger) will be notified") { (yes) in
            self.updateRideToOnItsWay(ride: ride)
            let onItsWayVc = OnItsWayViewController(nibName: nil, bundle: nil, duration: self.duration!, distance: self.distance!, ride: ride)
            self.navigationController?.pushViewController(onItsWayVc, animated: true)
        }
        
    }
}

extension DriveViewController: CLLocationManagerDelegate {
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