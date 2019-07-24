//
//  DriverProfileViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/20/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import Kingfisher
class DriverProfileViewController: UIViewController {

    @IBOutlet weak var driverImage: UIImageView!
    @IBOutlet weak var driverName: UILabel!
    @IBOutlet weak var upcomingTableView: UITableView!
    @IBOutlet weak var manoDriveLabel: UILabel!
    @IBOutlet weak var messageAlert: CircularView!
    
    var upcomingEvents = [Ride]() {
        didSet {
            DispatchQueue.main.async {
                self.upcomingTableView.reloadData()

            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }

    func setup() {
        let currentUser = DBService.currentManoUser!
        if currentUser.typeOfUser == TypeOfUser.Rider.rawValue {
            manoDriveLabel.isHidden = true
            driverImage.image = UIImage(named: "ManoLogo1")
            DBService.fetchPassangerRides(passangerId: currentUser.userId) { (error, rides) in
                if let error = error {
                    self.showAlert(title: "Error fetching rides", message: error.localizedDescription)
                }
                if let rides = rides {
                    self.upcomingEvents = rides
                }
            }
            
        } else {
            DBService.driverAcceptedRides(driverId: currentUser.userId) { (error, rides) in
                if let error = error {
                    self.showAlert(title: "Error fetching rides", message: error.localizedDescription)
                }
                if let rides = rides {
                    self.upcomingEvents = rides
                }
            }
            guard let profilePicURL = URL(string: currentUser.profileImage!) else {
                self.showAlert(title: "Error fetching profile image", message: nil)
                return
            }
            driverImage.kf.setImage(with: profilePicURL)
        }
        upcomingTableView.register(UINib(nibName: "UpcomingCell", bundle: nil), forCellReuseIdentifier: "UpcomingCell")
        upcomingTableView.delegate = self
        upcomingTableView.dataSource = self
        upcomingTableView.separatorStyle = .none
    }
    
    private func grouping(rides: [Ride]) -> [String : [Ride]] {
        let dictionary = Dictionary(grouping: rides, by: { (element: Ride) in
            return element.appointmentDate
        })
        return dictionary
    }
    
    @IBAction func settingsPressed(_ sender: Any) {
        
    }
    
    @IBAction func messagePressed(_ sender: Any) {
        print("Mesage PRessed")
    }

}
extension DriverProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let group = grouping(rides: upcomingEvents)
        let rides = group.map {$0.value}
        return rides[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingCell", for: indexPath) as? UpcomingCell else {return
            UITableViewCell()
            
        }
        let upcomingRides = upcomingEvents[indexPath.row]
        cell.upcomingDate.text = upcomingRides.appointmentDate
        cell.riderName.text = upcomingRides.passanger
        cell.ridePickupAddress.text = "Pick-up: \(upcomingRides.pickupAddress)"
        cell.rideDropoffAddress.text = "Drop-off \(upcomingRides.dropoffAddress)"
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 230
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let group = grouping(rides: upcomingEvents)
        let rides = group.map {$0.value}
        return rides.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let group = grouping(rides: upcomingEvents)
        let ride = group.map { "\($0.key)" }
        return ride[section]
    }
}
