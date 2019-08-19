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
import Firebase
import Toucan

class OnItsWayViewController: UIViewController {

    

    private var duration: String?
    private var distance: String?
    private var ride: Ride!
    private var graphics =  GraphicsClient()
    var thirtySecondTimer = 0
    private var userLocation = CLLocation()
    private var locationManager = CLLocationManager()
    private var timer: Timer?
    private var firstTime = true
    private var listener: ListenerRegistration!

    @IBOutlet weak var driverImage: RoundedImageViewBlue!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var driverMakerModel: UILabel!

    @IBOutlet weak var driverLicense: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrivedButton: RoundedButton!
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var driverView: UIView!
    @IBOutlet weak var passangerName: UILabel!
    @IBOutlet weak var destinationAddress: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pulseView: CircularView!
    @IBOutlet weak var messageView: BorderedView!
    @IBOutlet weak var phoneView: BorderedView!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var mapOptionView: RoundViewWithBorder10!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupCoreLocation()
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Driver.rawValue {
            var rideStatus = String()
            if ride.rideStatus == RideStatus.changedToReturnPickup.rawValue{
               rideStatus = RideStatus.onPickupReturnRide.rawValue
            } else {
                rideStatus = RideStatus.onPickup.rawValue
            }
            changeRideStatus(rideStatus: rideStatus)
        }       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Driver.rawValue {
            thirtyMinTimer()
            calculateCurrentMilesToPickup()
            
        } else {
            if ride.rideStatus == RideStatus.changedToReturnPickup.rawValue{
                listenToDuration()
                listenRideStatusChanges(rideStatus: RideStatus.changedToReturnDropoff.rawValue)
            }
            if ride.rideStatus == RideStatus.changedToPickup.rawValue {
                listenRideStatusChanges(rideStatus: RideStatus.changedToDropoff.rawValue)
            }
            activityIndicator.stopAnimating()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Passenger.rawValue {
            listener.remove()
        }
    }

    @objc private func thirtyMinTimer() {
        if timer != nil {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                if self?.thirtySecondTimer == 30 {
                    self?.calculateCurrentMilesToPickup()
                    self?.thirtySecondTimer = 0
                } else {
                    self?.thirtySecondTimer += 1
                }
            }
        }
    }
    
    


    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, duration: String?, distance: String?, ride: Ride) {
        self.duration = duration
        self.distance = distance
        self.ride = ride
        super.init(nibName: nil, bundle: nil)
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    private func searchGoogleForDirections() {
        let currentLocation = userLocation.coordinate
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Driver.rawValue{
            MapsHelper.openGoogleMapDirection(currentLat: currentLocation.latitude, currentLon: currentLocation.longitude, destinationLat: self.ride.pickupLat, destinationLon: self.ride.pickupLon, completion: { [weak self] error in
                if let error = error {
                    self?.showAlert(title: "Error opening google maps", message: error.localizedDescription)
                }
            })
        }
    }
    
    private func openWaze() {
        MapsHelper.openWazeDirection(destinationLat: ride.pickupLat, destinationLon: ride.pickupLon) { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Error opening Waze", message: error.localizedDescription)
            }
        }
    }
    private func changeRideStatus(rideStatus: String) {
        DBService.updateRideStatus(ride: ride, status: rideStatus) { [weak self] error , ride in
            if let error = error {
                self?.showAlert(title: "Error updating to on pickup", message: error.localizedDescription)
            }
            
            if let ride = ride {
                self?.ride = ride
            }
        }
    }

    func calculateCurrentMilesToPickup() {
        MapsHelper.calculateMilesAndTimeToDestination(destinationLat: ride.pickupLat, destinationLon: ride.pickupLon, userLocation: userLocation) { [weak self] miles, time, milesInt, timeInt  in
            self?.distanceLabel.text = "Distance: \n \(miles) Mil"
            self?.durationLabel.text = "Duration: \n \(time)"
            if self?.firstTime ?? true{
                self?.updateTotalMiles(miles: milesInt)
                self?.firstTime = false
            }
            DBService.updateRideDurationDistance(ride: self!.ride, distance: milesInt, duration: timeInt, completion: { [weak self] error in
                if let error = error {
                    self?.showAlert(title: "Error updating ride", message: error.localizedDescription)
                }
            })
            self?.activityIndicator.stopAnimating()
        }
    }
    
   private func updateTotalMiles(miles: Double) {
        DBService.updateTotalMiles(ride: ride, miles: miles) { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Error updaing total miles", message: error.localizedDescription)
            }
        }
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
            titleLabel.text = "On way to pick-up"
            passangerName.text = ride.passanger
            destinationAddress.text = ride.pickupAddress
            carImageView.isHidden = true
            phoneButton.isHidden = true
            messageButton.isHidden = true
        } else {
            if let userCarPhotoURL = URL(string: ride.carPicture) {
                carImageView.kf.setImage(with: userCarPhotoURL)
                driverView.isHidden = true
                if let duration = duration {
                  durationLabel.text = "Distance:\n Approx. \(duration) Away"
                } else {
                    durationLabel.text = "Waiting for driver response"
                }
                
                distanceLabel.isHidden = true
                
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
        let arriveVc = ArrivedViewController(nibName: nil, bundle: nil, number: ride.passangerCell, delegate: self, arriveDelegate: self, ride: ride)
        arriveVc.modalPresentationStyle = .overCurrentContext
        present(arriveVc, animated: true)
    }
    
    @IBAction func mapOptionPressed(_ sender: Any) {
        mapOptionView.isHidden = !mapOptionView.isHidden
        
    }
    
    
    
    @IBAction func googleMapsPressed(_ sender: Any) {
        showConfimationAlert(title: "Open Google Maps", message: nil) { (okay) in
            self.searchGoogleForDirections()
        }
    }
    
    @IBAction func wazePressed(_ sender: Any) {
        openWaze()
    }
    
    @IBAction func appleMapsPressed(_ sender: Any) {
        MapsHelper.openAppleMapsForDirection(currentLocation: userLocation.coordinate, destinationLat: ride.pickupLat, destinationLon: ride.pickupLon)
    }
    
    private func listenRideStatusChanges(rideStatus: String) {
        DBService.fetchForRide(ride: ride) { [weak self] error, ride in
            if let error = error {
                self?.showAlert(title: "Error fetching ride", message: error.localizedDescription)
            }
            if let ride = ride {
                self?.ride = ride
                self?.listener = DBService.listenForRideStatus(ride: ride, status: rideStatus) {[weak self] error, ride in
                    if let error = error {
                        self?.showAlert(title: "Error listening to dropoff", message: error.localizedDescription)
                    }
                    if let ride = ride {
                        self?.timer?.invalidate()
                        self?.timer = nil
                        let onWayToDropOffVC = OnWayToDropoffViewController(nibName: nil, bundle: nil, ride: ride)
                        self?.navigationController?.pushViewController(onWayToDropOffVC, animated: true)
                    }
                    
                }
            }
        }

    }
    
    private func listenToDropoffReturn() {
        listener = DBService.listenForRideStatus(ride: ride, status: RideStatus.changedToReturnDropoff.rawValue) {[weak self] error, ride in
            if let error = error {
                self?.showAlert(title: "Error listening to ride status", message: error.localizedDescription)
            }
            if let ride = ride {
                let onWayToDropoffVC = OnWayToDropoffViewController(nibName: nil, bundle: nil, ride: ride)
                self?.navigationController?.pushViewController(onWayToDropoffVC, animated: true)
            }
        }
    }
    
    private func listenToDuration() {
        DBService.listenForDistanceDurationUpdates(ride: ride) { [weak self] error, ride in
            if let error = error {
                self?.showAlert(title: "Error listening", message: error.localizedDescription)
            }
            if let ride = ride {
                self?.durationLabel.text = "Distance: \n \(MainTimer.timeString(time: TimeInterval(ride.duration))) away"
            }
        }
    }
    
    @IBAction func callPassanger(_ sender: Any) {
        guard let number = URL(string: "tel://" + ride.passangerCell) else {
            self.showAlert(title: "Wrong number", message: nil)
            return }
        UIApplication.shared.open(number)
    }

    @IBAction func messagePassangerPressed(_ sender: Any) {
        let sendMessageVC = SendMessageViewController(nibName: nil, bundle: nil, number: ride.passangerCell, delegate: self,passenger: false)
        sendMessageVC.modalPresentationStyle = .overCurrentContext
        present(sendMessageVC, animated: true)
    }
    
    @IBAction func callDriverPressed(_ sender: Any) {
        guard let number = URL(string: "tel://" + ride.driverCell) else {
            self.showAlert(title: "Wrong number", message: nil)
            return }
        UIApplication.shared.open(number)
    }
    @IBAction func messageDriverPressed(_ sender: Any) {
        let sendMessageVC = SendMessageViewController(nibName: nil, bundle: nil, number: ride.driverCell, delegate: self,passenger: true)
        sendMessageVC.modalPresentationStyle = .overCurrentContext
        present(sendMessageVC, animated: true)
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
    }
}

extension OnItsWayViewController: MessageDelegate {
    func messageError(error: String) {
        showAlert(title: "Error sending message", message: "Error: \(error)")
    }
    
    func messageSent() {
        dismiss(animated: true)
        showAlert(title: "Message sent!", message: nil)
    }
}

extension OnItsWayViewController: ArriveViewDelegate {
    func userPressBeginDropOff(ride: Ride) {

        let onWayToDropOffVC = OnWayToDropoffViewController(nibName: nil, bundle: nil, ride: ride)
        self.navigationController?.pushViewController(onWayToDropOffVC, animated: true)
    }
}
