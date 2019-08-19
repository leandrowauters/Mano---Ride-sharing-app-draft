//
//  RequestRideViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/20/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import GooglePlaces
import UserNotifications
import FirebaseMessaging
import Firebase
class RequestRideViewController: UIViewController {
    
    private var pickupAddress: String?
    private var dropoffAdress: String?
    private var dropoffName: String?
    private var pickupLat: Double!
    private var pickupLon: Double!
    private var dropoffLat: Double!
    private var dropoffLon: Double!
    private var date: String?
    private var pickup: Bool!
    private var ride: Ride?
    private var listener: ListenerRegistration!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var dateView: RoundViewWithBorder!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var pickupView: RoundViewWithBorder!
    
    @IBOutlet weak var pickupLabel: UILabel!
    
    @IBOutlet weak var dropoffView: RoundViewWithBorder!
    
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var dropoffLabel: UILabel!
    
    @IBOutlet weak var datePicker: RoundDatePicker!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var rideStatusLabel: UILabel!
    @IBOutlet weak var addToCalendarButton: RoundedButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRideCreated()
        setupTapsViews()
        datePicker.minimumDate = Date()
        pickupAddress = DBService.currentManoUser.homeAdress
        pickupLat = DBService.currentManoUser.homeLat
        pickupLon = DBService.currentManoUser.homeLon
    }
    
    override func viewDidAppear(_ animated: Bool) {
       fetchRideCreated()
    }
    override func viewDidDisappear(_ animated: Bool) {
        listener.remove()
    }
    private func setupTapsViews() {
        let dateViewTap = UITapGestureRecognizer(target: self, action: #selector(dateViewPressed))
        dateView.addGestureRecognizer(dateViewTap)
        let datePickerViewTap = UITapGestureRecognizer(target: self, action: #selector(datePickerViewPressed))
        datePickerView.addGestureRecognizer(datePickerViewTap)
        let pickupViewTap = UITapGestureRecognizer(target: self, action: #selector(pickupViewPressed))
        pickupView.addGestureRecognizer(pickupViewTap)
        let dropoffViewTap = UITapGestureRecognizer(target: self, action: #selector(dropoffViewPressed))
        dropoffView.addGestureRecognizer(dropoffViewTap)
    }


  
    func fetchRideCreated() {
        activityIndicator.startAnimating()
        listener = DBService.fetchUserRides(typeOfUser: DBService.currentManoUser.userId) { [weak self] error, rides in
            if let error = error {
                self?.showAlert(title: "Error fetching rides", message: error.localizedDescription)
            }
            if let rides = rides {
                if rides.isEmpty {
                    self?.alertView.isHidden = true
                    return
                }
                if let ride = rides.last {
                    self?.ride = ride
                    switch ride.rideStatus {
                    case RideStatus.rideRequested.rawValue:
                        self?.setupAlertView(isHidden: false, labelText: "Finding Driver", labelColor: #colorLiteral(red: 0.995932281, green: 0.2765177786, blue: 0.3620784283, alpha: 1))
                        self?.addToCalendarButton.isHidden = true
                    case RideStatus.rideAccepted.rawValue:
                        self?.setupAlertView(isHidden: false, labelText: "Accepted", labelColor: #colorLiteral(red: 0, green: 0.7077997327, blue: 0, alpha: 1))
                        self?.addToCalendarButton.isHidden = false
                    default:
                        self?.alertView.isHidden = true
                    }
                }
            }
        }
        activityIndicator.stopAnimating()
    }
    
    private func setupAlertView(isHidden: Bool, labelText: String, labelColor: UIColor) {
        alertView.isHidden = isHidden
        rideStatusLabel.text = labelText
        rideStatusLabel.textColor = labelColor
    }
    @objc func dateViewPressed(){
        datePickerView.isHidden = false
    }
    @IBAction func donePressed(_ sender: UIButton) {
        date = datePicker.date.dateDescription
        dateLabel.text = date
        datePickerView.isHidden = true
    }
    
    @objc func datePickerViewPressed() {
        datePickerView.isHidden = true
    }
    @objc func pickupViewPressed() {
        pickup = true
        MapsHelper.setupAutoCompeteVC(Vc: self)
        
    }
    
    @objc func dropoffViewPressed() {
        pickup = false
        MapsHelper.setupAutoCompeteVC(Vc: self)
    }
    
    func createRide() {
        guard let date = date, let pickupAddress = pickupAddress, let dropoffAddress = dropoffAdress else {
            showAlert(title: "Please complete missing fields", message: nil)
            return
        }
        let timeStamp = Date().dateDescription
        DBService.createARide(date: date, passangerId: DBService.currentManoUser.userId  , passangerName: DBService.currentManoUser.fullName, pickupAddress: pickupAddress, dropoffAddress: dropoffAddress, dropoffName: dropoffName, pickupLat: pickupLat, pickupLon: pickupLon, dropoffLat: dropoffLat, dropoffLon: dropoffLon, dateRequested: timeStamp, passangerCell: DBService.currentManoUser.cellPhone!) { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Error creating ride", message: error.localizedDescription)
            }

        }

        
    }

    
    @IBAction func requestPressed(_ sender: Any) {
        createRide()
    }
    
    @IBAction func addToCalendarPressed(_ sender: Any) {
        guard let ride = ride else {showAlert(title: "No ride to add to calendar", message: nil)
            return}
        EventKitHelper.shared.addToCalendar(ride: ride, completion: { [weak self] error, calendar in
            if let error = error {
                self?.showAlert(title: "Error Adding to calendar", message: error.errorMessage())
            }
            if let calendar = calendar {
                self?.showAlert(title: "Added!", message: "Calendar: \(calendar)")
            }
        })
    }
    

}
extension RequestRideViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        guard let address = place.formattedAddress else {
            showAlert(title: "Error finding address", message: nil)
            return}
        let coordinate = place.coordinate
        if pickup {
            pickupAddress = address
            print(address)
            pickupLabel.text = address
            pickupLat = coordinate.latitude
            pickupLon = coordinate.longitude
        } else {
            if let name = place.name{
                dropoffName = name
            }
            dropoffAdress = address
            dropoffLabel.text = address
            dropoffLat = coordinate.latitude
            dropoffLon = coordinate.longitude
        }
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    
}
