//
//  DriveViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/23/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit

class DriveViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    

    @IBOutlet weak var ridesTableView: UITableView!
    
    
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

        // Do any additional setup after loading the view.
    }
    

    private func setup() {
        ridesTableView.register(UINib(nibName: "UpcomingCell", bundle: nil), forCellReuseIdentifier: "UpcomingCell")
        ridesTableView.delegate = self
        ridesTableView.dataSource = self
        
    }
    private func checkForRideToday() {
        if rides.isEmpty {
            showAlert(title: "No Rides Today", message: nil)
        }
    }
    private func fetchYourAcceptedRides() {
        DBService.driverAcceptedRides(driverId: DBService.currentManoUser.userId) { (error, rides) in
            if let error = error {
                self.showAlert(title: "Error fetching your rides", message: error.localizedDescription)
            }
            if let rides = rides {
                self.rides = rides.filter{ Calendar.current.isDateInToday($0.appointmentDate.stringToDate())}
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rides.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingCell", for: indexPath) as? UpcomingCell else {return
            UITableViewCell()
        }
        let ride = rides[indexPath.row]
        cell.upcomingDate.text = ride.appointmentDate
        cell.riderName.text = ride.passanger
        cell.ridePickupAddress.text = ride.pickupAddress
        cell.rideDropoffAddress.text = ride.dropoffAddress
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 230
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ride = rides[indexPath.row]
        GoogleHelper.calculateEta(originLat: DBService.currentManoUser.homeLat!, originLon: DBService.currentManoUser.homeLon!, destinationLat: ride.dropoffLat, destinationLon: ride.dropoffLon) { (appError, etaText, etaInt) in
            if let appError = appError {
                print(appError)
            }
            if let etaText = etaText {
                print(etaText)
            }
            if let etaInt = etaInt {
                print(etaInt)
            }
        }
        GoogleHelper.calculateDistanceToLocation(originLat: DBService.currentManoUser.homeLat!, originLon: DBService.currentManoUser.homeLon!, destinationLat: ride.dropoffLat, destinationLon: ride.dropoffLon) { (appError, distanceText, distanceInt) in
            if let appError = appError {
                
            }
            if let distanceText = distanceText {
                print(distanceText)
            }
            if let distanceInt = distanceInt {
                print(distanceInt)
            }
        }
    }
}
