//
//  RequestRideViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/20/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import GooglePlaces
class RequestRideViewController: UIViewController {
    
    private var pickupAddress: String?
    private var dropoffAdress: String?
    private var pickupLat: Double!
    private var pickupLon: Double!
    private var dropoffLat: Double!
    private var dropoffLon: Double!
    private var date: String?
    private var pickup: Bool!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var dateView: RoundViewWithBorder!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var pickupView: RoundViewWithBorder!
    
    @IBOutlet weak var pickupLabel: UILabel!
    
    @IBOutlet weak var dropoffView: RoundViewWithBorder!
    
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var dropoffLabel: UILabel!
    
    @IBOutlet weak var datePicker: RoundDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapsViews()
        
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
//        pickupAddress = DBService.currentManoUser.homeAdress
//        pickupLat = DBService.currentManoUser.homeLat
//        pickupLon = DBService.currentManoUser.homeLon
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
        GoogleHelper.setupAutoCompeteVC(Vc: self)
    }
    
    @objc func dropoffViewPressed() {
        pickup = false
        GoogleHelper.setupAutoCompeteVC(Vc: self)
    }
    
    func createRide() {
        guard let date = date, let pickupAddress = pickupAddress, let dropoffAddress = dropoffAdress else {
            showAlert(title: "Please complete missing fields", message: nil)
            return
        }
        DBService.createARide(date: date, passangerId: DBService.currentManoUser.fullName  , passangerName: DBService.currentManoUser.fullName, pickupAddress: pickupAddress, dropoffAddress: dropoffAddress, pickupLat: pickupLat, pickupLon: pickupLon, dropoffLat: dropoffLat, dropoffLon: dropoffLon) { (error) in
            if let error = error {
                self.showAlert(title: "Error creating ride", message: error.localizedDescription)
            }
            
        }
        showAlert(title: "Ride request created!", message: "Please wait until a driver accepts request")
    }

    
    @IBAction func requestPressed(_ sender: Any) {
        createRide()
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
            print(pickupAddress)
            pickupLabel.text = address
            pickupLat = coordinate.latitude
            pickupLon = coordinate.longitude
        } else {
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
