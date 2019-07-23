//
//  MyLocationsViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/20/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import GooglePlaces
class MyLocationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    

    @IBOutlet weak var myLocationsTableView: UITableView!
    
    var myLocations = [MyLocation]() {
        didSet {
            DispatchQueue.main.async {
                self.myLocationsTableView.reloadData()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
    }
    

    func setup() {
       myLocationsTableView.register(UINib(nibName: "ManosListCell", bundle: nil), forCellReuseIdentifier: "ManosListCell")
        myLocationsTableView.delegate = self
        myLocationsTableView.dataSource = self
    }

    @IBAction func addLocationPressed(_ sender: Any) {
        GoogleHelper.setupAutoCompeteVC(Vc: self)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return myLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ManosListCell", for: indexPath) as? ManosListCell else {return UITableViewCell()}
        let myLocation = myLocations[indexPath.row]
        cell.name.text =  myLocation.locationName
        cell.address.text = myLocation.address
        cell.appointmentDateLabel.isHidden = true
        cell.riderDistance.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
}

extension MyLocationsViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        guard let address = place.formattedAddress else {
            showAlert(title: "Error finding address", message: nil)
            return}
        let selectedMyLocation = MyLocation(userId: DBService.currentManoUser.userId, locationName: place.name ?? "Name unavailable", address: address, locationId: place.placeID ?? UUID().uuidString)
        myLocations.append(selectedMyLocation)
        DBService.createMyLocation(myLocation: selectedMyLocation) { (error) in
            if let error = error {
                self.showAlert(title: "Error creating my location", message: error.localizedDescription)
            }
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
