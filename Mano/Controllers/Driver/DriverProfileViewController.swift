//
//  DriverProfileViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/20/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import Kingfisher
import MessageUI
class DriverProfileViewController: UIViewController {

    @IBOutlet weak var driverImage: UIImageView!
    @IBOutlet weak var driverName: UILabel!
    @IBOutlet weak var upcomingTableView: UITableView!
    @IBOutlet weak var manoDriveLabel: UILabel!
    @IBOutlet weak var messageAlert: CircularView!
    @IBOutlet weak var optionView: BlueBorderedView!
    
    var upcomingEvents = [Ride]() {
        didSet {
            DispatchQueue.main.async {
                self.upcomingTableView.reloadData()

            }
        }
    }
    private var authservice = AppDelegate.authservice
    
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
        authservice.authserviceSignOutDelegate = self
        if currentUser.typeOfUser == TypeOfUser.Rider.rawValue {
            manoDriveLabel.isHidden = true
            driverImage.image = UIImage(named: "ManoLogo1")
            driverImage.contentMode = .scaleAspectFit
            DBService.fetchPassangerRides(passangerId: currentUser.userId) { (error, rides) in
                if let error = error {
                    self.showAlert(title: "Error fetching rides", message: error.localizedDescription)
                }
                if let rides = rides {
                    let ridesSortedByDate = rides.sorted {$0.appointmentDate.stringToDate() < $1.appointmentDate.stringToDate()}
                    self.upcomingEvents = ridesSortedByDate
                }
            }
            
        } else {
            DBService.fetchDriverAcceptedRides(driverId: currentUser.userId) { (error, rides) in
                if let error = error {
                    self.showAlert(title: "Error fetching rides", message: error.localizedDescription)
                }
                if let rides = rides {
                    let ridesSortedByDate = rides.sorted {$0.appointmentDate.stringToDate() < $1.appointmentDate.stringToDate()}
                    self.upcomingEvents = ridesSortedByDate
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

    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["manonyc.contact@gmail.com"])
            mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            showAlert(title: "Cannot send email", message: "Please contact manonyc.contact@gmail.com")
        }
    }
    @IBAction func settingsPressed(_ sender: Any) {
       optionView.isHidden = !optionView.isHidden
    }
    
    @IBAction func messagePressed(_ sender: Any) {
        let messageListVc = MessagesListViewController()
        navigationController?.pushViewController(messageListVc, animated: true)
    }
    
    @IBAction func signoutPressed(_ sender: Any) {
         AppDelegate.authservice.signOutAccount()
    }
    
    @IBAction func contactPressed(_ sender: Any) {
        sendEmail()
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
                let messageVC = MessageViewController(nibName: nil, bundle: nil, recipientId: ride.passangerId, recipientName: ride.passanger, message: nil, sent: false)
                messageVC.modalPresentationStyle = .overCurrentContext
                self.present(messageVC, animated: true)
            case "Contact Driver":
                let messageVC = MessageViewController(nibName: nil, bundle: nil, recipientId: ride.driverId, recipientName: ride.driverName, message: nil, sent: false)
                messageVC.modalPresentationStyle = .overCurrentContext
                self.present(messageVC, animated: true)
            default:
                return
            }
            
        }
    }
}

extension DriverProfileViewController: AuthServiceSignOutDelegate {
    func didSignOutWithError(_ authservice: AuthService, error: Error) {
        
    }
    
    func didSignOut(_ authservice: AuthService) {
        let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
        let navigationController = UINavigationController(rootViewController: loginVC)
        navigationController.setNavigationBarHidden(true, animated: false)
        present(navigationController, animated: true)
        
    }
}

extension DriverProfileViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
