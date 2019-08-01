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
import MessageUI
import Toucan

class OnItsWayViewController: UIViewController {

    

    private var duration: String!
    private var distance: String!
    private var ride: Ride!
    private var graphics =  GraphicsClient()
    var thirtySecondTimer = 0
    private var userLocation = CLLocation()
    private var locationManager = CLLocationManager()
    

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
    @IBOutlet weak var messageImage: UIImageView!
    @IBOutlet weak var phoneImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupCoreLocation()

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Driver.rawValue {
            thirtyMinTimer()
            calculateCurrentMilesToPickup()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    private func addTapGestures() {
        let phoneViewTap = UITapGestureRecognizer(target: self, action: #selector (phoneViewTapped))
        let messageViewTap = UITapGestureRecognizer(target: self, action: #selector(messageViewTapped))
        phoneView.addGestureRecognizer(phoneViewTap)
        messageView.addGestureRecognizer(messageViewTap)
    }
    

    @objc private func thirtyMinTimer() {
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            if self.thirtySecondTimer == 30 {
                self.calculateCurrentMilesToPickup()
                self.thirtySecondTimer = 0
            } else {
                self.thirtySecondTimer += 1
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
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
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
        GoogleHelper.calculateMilesAndTimeToDestination(pickup: true, ride: ride, userLocation: userLocation) { (miles, time) in
            self.distanceLabel.text = "Distance: \n \(miles) Mil"
            self.durationLabel.text = "Duration: \n \(time)"
            self.activityIndicator.stopAnimating()
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
            phoneImage.isHidden = true
            messageImage.isHidden = true
        } else {
            if let userCarPhotoURL = URL(string: ride.carPicture) {
                carImageView.kf.setImage(with: userCarPhotoURL)
                driverView.isHidden = true
                addTapGestures()
                durationLabel.text = "Duration:\n Approx. \(duration ?? "N/A")"
                distanceLabel.text = "Call / Message"
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
        let arriveVc = ArrivedViewController(nibName: nil, bundle: nil, number: ride.passangerCell, delegate: self, arriveDelegate: self)
        arriveVc.modalPresentationStyle = .overCurrentContext
        present(arriveVc, animated: true)
    }
    
    

    
    @IBAction func googleMapsPressed(_ sender: Any) {
        showConfimationAlert(title: "Open Google Maps", message: nil) { (okay) in
            self.searchGoogleForDirections()
        }
    }
    
    
    @IBAction func callPassanger(_ sender: Any) {
        guard let number = URL(string: "tel://" + ride.passangerCell) else { return }
        UIApplication.shared.open(number)
    }

    @IBAction func messagePassangerPressed(_ sender: Any) {
        let sendMessageVC = SendMessageViewController(nibName: nil, bundle: nil, number: ride.passangerCell, delegate: self)
        sendMessageVC.modalPresentationStyle = .overCurrentContext
        present(sendMessageVC, animated: true)
    }
    
    @objc func phoneViewTapped() {
        guard let number = URL(string: "tel://" + ride.driverCell) else { return }
        UIApplication.shared.open(number)
    }
    
    @objc func messageViewTapped() {
        let sendMessageVC = SendMessageViewController(nibName: nil, bundle: nil, number: ride.driverCell, delegate: self)
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
    func userPressBeginDropOff() {
        let onWayToDropOffVC = OnWayToDropoffViewController(nibName: nil, bundle: nil, ride: ride)
        navigationController?.pushViewController(onWayToDropOffVC, animated: true)
    }
}
