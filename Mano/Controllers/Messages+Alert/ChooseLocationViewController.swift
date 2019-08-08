//
//  ChooseLocationViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 8/8/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import GooglePlaces

class ChooseLocationViewController: UIViewController {

    var dropoffAddress: String!
    var dropoffLat: Double!
    var dropoffLon: Double!
    var currentLat: Double!
    var currentLon: Double!
    var ride: Ride!
    
    @IBOutlet weak var locationButton: RoundedButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dropoffAddress = DBService.currentManoUser.homeAdress
        dropoffLon = DBService.currentManoUser.homeLon
        dropoffLat = DBService.currentManoUser.homeLat
    }

    @IBAction func locationButtonPressed(_ sender: Any) {
        GoogleHelper.setupAutoCompeteVC(Vc: self)
    }
    
    @IBAction func donePressed(_ sender: Any) {
        DBService.updateToNewRide(pickupAddress: ride.dropoffAddress, pickupLat: currentLat, pickupLon: currentLon, dropoffAddress: dropoffAddress, dropoffLat: dropoffLat, dropoffLon: dropoffLon, rideStatus: RideStatus.changedToReturnDrive.rawValue, ride: ride) { (error) in
            if let error = error {
                self.showAlert(title: "Error updating to new ride", message: error.localizedDescription)
            } else {
                GoogleHelper.calculateMilesAndTimeToDestination(pickup: , ride: <#T##Ride#>, userLocation: <#T##CLLocation#>, completion: <#T##(String, String, Double, Double) -> Void#>)
            }
        }
    }

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, ride: Ride, currentLat: Double, currentLon: Double) {
        self.ride = ride
        self.currentLat = currentLat
        self.currentLon = currentLon
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ChooseLocationViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        guard let dropoffAddress = place.formattedAddress else {
            showAlert(title: "Error finding address", message: nil)
            return}
        let coordinate = place.coordinate
        self.dropoffAddress = dropoffAddress
        let shorterAddress = GoogleHelper.getShortertString(string: dropoffAddress)
        locationButton.setTitle(shorterAddress, for: .normal)
        dropoffLat = coordinate.latitude
        dropoffLon = coordinate.longitude
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
