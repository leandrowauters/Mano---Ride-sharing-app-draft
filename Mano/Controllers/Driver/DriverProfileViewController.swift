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
    
    override func viewDidAppear(_ animated: Bool) {
        checkForNewMessages()
    }
    func setup() {
        let currentUser = DBService.currentManoUser!
        driverName.text = currentUser.fullName
        if currentUser.typeOfUser == TypeOfUser.Rider.rawValue {
            manoDriveLabel.isHidden = true
            driverImage.image = UIImage(named: "ManoLogo1")
            driverImage.contentMode = .scaleAspectFit
            DBService.fetchPassangerRides(passangerId: currentUser.userId) { (error, rides) in
                if let error = error {
                    self.showAlert(title: "Error fetching rides", message: error.localizedDescription)
                }
                if let rides = rides {
                    self.upcomingEvents = rides
                }
            }
            
        } else {
            DBService.fetchDriverAcceptedRides(driverId: currentUser.userId) { (error, rides) in
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
    
    private func checkForNewMessages() {
        DBService.fetchYourMessages { (error, messages) in
            if let messages = messages {
                DBService.messagesRecieved = messages
                let newMessage = messages.filter({$0.read == false})
                if !newMessage.isEmpty{
                    self.tabBarItem.badgeValue = newMessage.count.description
                    self.messageAlert.isHidden = false
                } else {
                    self.tabBarItem.badgeValue = nil
                    self.messageAlert.isHidden = true
                }
            }
        }
    }

    
    @IBAction func settingsPressed(_ sender: Any) {
        AppDelegate.authservice.signOutAccount()
    }
    
    @IBAction func messagePressed(_ sender: Any) {
        let messageListVc = MessagesListViewController()
        navigationController?.pushViewController(messageListVc, animated: true)
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
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Rider.rawValue {
            cell.riderName.isHidden = true
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ride = upcomingEvents[indexPath.row]
        var contact = String()
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Driver.rawValue {
            contact = "Contact Passenger"
        } else {
            contact = "Contact Driver"
        }
        profileAlertSheet(title: "Choose Option", contact: contact) { (alert) in
            switch alert.title {
            case "Cancel Ride":
                self.showConfimationAlert(title: "Cancel Ride", message: "Are you sure?", handler: { (yes) in
                    DBService.deleteRide(ride: ride , completion: { (error) in
                        if let error = error {
                            self.showAlert(title: "Error deleting ride", message: error.localizedDescription)
                        }
                    })
                })
            case "Add To Calendar":
                EventKitHelper.shared.addToCalendar(ride: ride, completion: { (error, calendar) in
                    if let error = error {
                        self.showAlert(title: "Error Adding to calendar", message: error.errorMessage())
                    }
                    if let calendar = calendar {
                        self.showAlert(title: "Added!", message: "Calendar: \(calendar)")
                    }
                })
            case "Contact Passenger":
                let messageVC = MessageViewController(nibName: nil, bundle: nil, recipientId: ride.passangerId, recipientName: ride.passanger, message: nil)
                messageVC.modalPresentationStyle = .overCurrentContext
                self.present(messageVC, animated: true)
            case "Contact Driver":
                let messageVC = MessageViewController(nibName: nil, bundle: nil, recipientId: ride.driverId, recipientName: ride.driverName, message: nil)
                messageVC.modalPresentationStyle = .overCurrentContext
                self.present(messageVC, animated: true)
            default:
                return
            }
            
        }
    }
}
