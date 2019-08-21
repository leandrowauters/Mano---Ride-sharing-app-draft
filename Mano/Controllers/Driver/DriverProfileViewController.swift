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
import Firebase
class DriverProfileViewController: UIViewController {

    private var rideFetchListener: ListenerRegistration!
    private var messageListener: ListenerRegistration!
    private var upcomingRidesPressed = true
    private var authservice = AppDelegate.authservice
    let currentUser = DBService.currentManoUser!
    
    @IBOutlet weak var driverImage: UIImageView!
    @IBOutlet weak var driverName: UILabel!
    @IBOutlet weak var upcomingTableView: UITableView!
    @IBOutlet weak var manoDriveLabel: UILabel!
    @IBOutlet weak var messageAlert: CircularView!
    @IBOutlet weak var optionView: BlueBorderedView!
    @IBOutlet weak var topButton: BlueBorderedButton!
    @IBOutlet weak var secondButton: BlueBorderedButton!
    
    var rides = [Ride]() {
        didSet {
            DispatchQueue.main.async {
                self.upcomingTableView.reloadData()

            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        fetchRides(upcoming: upcomingRidesPressed)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkForNewMessages()
        fetchRides(upcoming: upcomingRidesPressed)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        messageListener.remove()
        rideFetchListener.remove()
    }
    func setup() {
        driverName.text = currentUser.fullName
        authservice.authserviceSignOutDelegate = self
        if currentUser.typeOfUser == TypeOfUser.Passenger.rawValue {
            manoDriveLabel.isHidden = true
            driverImage.image = UIImage(named: "ManoLogo1")
            driverImage.contentMode = .scaleAspectFit
        } else {
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
    
    private func fetchRides(upcoming: Bool) {
        rideFetchListener = DBService.fetchUserRides(typeOfUser: currentUser.typeOfUser) { [weak self] error, rides in
            if let error = error {
                self?.showAlert(title: "Error fetching rides", message: error.localizedDescription)
            }
            if let rides = rides {
                if upcoming{
                    self?.rides = rides.filter{($0.rideStatus == RideStatus.rideAccepted.rawValue || $0.rideStatus == RideStatus.rideRequested.rawValue || $0.rideStatus == RideStatus.rideCancelled.rawValue) && !$0.appointmentDate.stringToDate().dateExpired()}
                    self?.rides = (self?.rides.sorted {$0.appointmentDate.stringToDate() > $1.appointmentDate.stringToDate()})!
                } else {
                    self?.rides = rides.filter{$0.rideStatus == RideStatus.rideIsOver.rawValue}
                }
            }
        }
    }

    
    private func checkForNewMessages() {
       messageListener = DBService.fetchYourMessages { [weak self] error, messages in
            if let messages = messages {
                DBService.messagesRecieved = messages
                let newMessage = messages.filter({$0.read == false})
                if !newMessage.isEmpty{
                    self?.tabBarItem.badgeValue = newMessage.count.description
                    self?.messageAlert.isHidden = false
                } else {
                    self?.tabBarItem.badgeValue = nil
                    self?.messageAlert.isHidden = true
                }
            }
        }
    }

    private func sendEmail() {
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
    
    private func animateTableView(upcoming: Bool, sender: UIButton) {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.secondButton.isHidden = !self.secondButton.isHidden
            self.upcomingTableView.frame.origin.x += self.view.bounds.width
        }) { [weak self] done in
            UIView.animate(withDuration: 0.3, animations: {
                self?.fetchRides(upcoming: upcoming)
                if upcoming {
                    self?.topButton.setTitle("Upcoming", for: .normal)
                    sender.setTitle("History", for: .normal)
                    
                } else {
                    self?.topButton.setTitle("History", for: .normal)
                    sender.setTitle("Upcoming", for: .normal)
                }
                
                self?.upcomingTableView.frame.origin.x -= self!.view.bounds.width
            })
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
    
    @IBAction func filterRidesButton(_ sender: UIButton) {
        self.secondButton.isHidden = !self.secondButton.isHidden
        self.view.layoutIfNeeded()
        
    }
    
    @IBAction func secondButtonPressed(_ sender: UIButton) {
        upcomingRidesPressed =  !upcomingRidesPressed
        if upcomingRidesPressed {
            animateTableView(upcoming: upcomingRidesPressed, sender: sender)
            
        } else {
            animateTableView(upcoming: upcomingRidesPressed, sender: sender)
        }
    }

    
    
    
    

}
extension DriverProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rides.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingCell", for: indexPath) as? UpcomingCell else {return
            UITableViewCell()
            
        }

        let upcomingRides = rides[indexPath.row]
        cell.configure(with: upcomingRides, upcoming: upcomingRidesPressed)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 230
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ride = rides[indexPath.row]
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
                    DBService.updateRideStatus(ride: ride, status: RideStatus.rideCancelled.rawValue, completion: { [weak self] error, ride in
                        if let error = error {
                            self?.showAlert(title: "Error changing status", message: error.localizedDescription)
                        }
                    })
                })
            case "Add To Calendar":
                EventKitHelper.shared.addToCalendar(ride: ride, completion: { [weak self] error, calendar in
                    if let error = error {
                        self?.showAlert(title: "Error Adding to calendar", message: error.errorMessage())
                    }
                    if let calendar = calendar {
                        self?.showAlert(title: "Added!", message: "Calendar: \(calendar)")
                    }
                })
            case "Contact Passenger":
                print("Contact passanger")
//                let messageVC = MessageViewController(nibName: nil, bundle: nil, recipientId: ride.passangerId, recipientName: ride.passanger, message: nil, sent: false)
//                messageVC.modalPresentationStyle = .overCurrentContext
//                self.present(messageVC, animated: true)
            case "Contact Driver":
                print("Contact driver")
//                let messageVC = MessageViewController(nibName: nil, bundle: nil, recipientId: ride.driverId, recipientName: ride.driverName, message: nil, sent: false)
//                messageVC.modalPresentationStyle = .overCurrentContext
//                self.present(messageVC, animated: true)
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
