//
//  DriverProfileViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/20/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit

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
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Rider.rawValue {
            manoDriveLabel.isHidden = true
            driverImage.image = UIImage(named: "ManoLogo1")
            
        }
        upcomingTableView.register(UINib(nibName: "UpcomingCell", bundle: nil), forCellReuseIdentifier: "UpcomingCell")
        upcomingTableView.delegate = self
        upcomingTableView.dataSource = self
        upcomingTableView.separatorStyle = .none
    }
    
    @IBAction func settingsPressed(_ sender: Any) {
        
    }
    
    @IBAction func messagePressed(_ sender: Any) {
        print("Mesage PRessed")
    }

}
extension DriverProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return upcomingEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingCell", for: indexPath) as? UpcomingCell else {return
            UITableViewCell()
            
        }
        let upcomingRides = upcomingEvents[indexPath.row]
        cell.upcomingDate.text = upcomingRides.appointmentDate
        cell.riderName.text = upcomingRides.passanger
        cell.ridePickupAddress.text = upcomingRides.pickupAddress
        cell.rideDropoffAddress.text = upcomingRides.dropoffAddress
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 230
    }
    
}
