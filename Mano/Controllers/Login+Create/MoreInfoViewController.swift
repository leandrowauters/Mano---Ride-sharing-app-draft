//
//  MoreInfoViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/20/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import Toucan
import Kingfisher
import GooglePlaces
class MoreInfoViewController: UIViewController {

    private var manoUser: ManoUser!
    private var typeOfUser: String!

    


    @IBOutlet weak var homeAddressView: RoundViewWithBorder!
    @IBOutlet weak var homeAddressLabel: UILabel!
    @IBOutlet weak var cellPhoneTextField: RoundedTextField!
    

    
    private var homeAddress: String?
    private var homeLat: Double!
    private var homeLon: Double!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreenTap()
        setupTap()
        cellPhoneTextField.delegate = self
        
        
        // Do any additional setup after loading the view.
    }
    

    private func setupTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }

    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, manoUser: ManoUser, typeOfUser: String) {
        self.manoUser = manoUser
        self.typeOfUser = typeOfUser
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupScreenTap() {

        let homeAddressTap = UITapGestureRecognizer.init(target: self, action: #selector(presentAutocompleteVC))
        homeAddressView.addGestureRecognizer(homeAddressTap)
    }
    @objc func presentAutocompleteVC() {
        GoogleHelper.setupAutoCompeteVC(Vc: self)
        
    }

    
    @IBAction func donePressed(_ sender: Any) {
        updateMoreInfo()
    }
    
    func updateMoreInfo() {
        
        guard let homeAddress = self.homeAddress,
        let cellPhone = cellPhoneTextField.text,
        !cellPhone.isEmpty else {
                showAlert(title: "Please Complete missing fields", message: nil)
                return
        }
        let updatedManoUser = ManoUser(firstName: self.manoUser.firstName, lastName: self.manoUser.lastName, fullName: self.manoUser.fullName, homeAdress: homeAddress, homeLat: self.homeLat, homeLon: self.homeLon, profileImage: nil, carMakerModel: nil, bio: nil, typeOfUser: self.manoUser.typeOfUser, patients: nil, joinedDate: self.manoUser.joinedDate, userId: self.manoUser.userId, myRides: nil, myPickUps: nil, licencePlate: nil, carPicture: nil,cellPhone: cellPhone)
        DBService.updatePassangerMoreInfo(userID: manoUser.userId, homeAddress: homeAddress, homeLat: homeLat, homeLon: homeLon, cellPhone: cellPhone , completion: { (error) in
                if let error = error {
                      self.showAlert(title: "Error uploading more info", message: error.localizedDescription)
                } else {
                    let bioVC = BioViewController(nibName: nil, bundle: nil, manoUser: updatedManoUser, typeOfUser: self.typeOfUser)
                    bioVC.modalPresentationStyle = .overCurrentContext
                    self.present(bioVC, animated: true)
                }
            })
        
    }
}


extension MoreInfoViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}


extension MoreInfoViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        guard let homeAddress = place.formattedAddress else {
            showAlert(title: "Error finding address", message: nil)
            return}
        let coordinate = place.coordinate
        self.homeAddress = homeAddress
        homeAddressLabel.text = homeAddress
        homeLon = coordinate.longitude
        homeLat = coordinate.latitude
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
