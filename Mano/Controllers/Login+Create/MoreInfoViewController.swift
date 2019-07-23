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
    var selectedImage: UIImage?
    private lazy var imagePickerController: UIImagePickerController = {
        let ip = UIImagePickerController()
        ip.delegate = self
        return ip
    }()
    
    @IBOutlet weak var carMakerModelTextField: RoundedTextField!

    @IBOutlet weak var homeAddressView: RoundViewWithBorder!
    @IBOutlet weak var homeAddressLabel: UILabel!
    
    @IBOutlet weak var userImage: RoundedButton!
    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var driverView: UIView!
    
    @IBOutlet weak var passangerView: UIView!
    
    @IBOutlet weak var passangerFooter: UIView!
    
    @IBOutlet weak var driverFooter: UIView!
    
    private var homeAddress: String?
    private var homeLat: Double!
    private var homeLon: Double!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreenTap()
        if typeOfUser == TypeOfUser.Driver.rawValue {
            setupDriverUI()
        } else {
            setupPassagerUI()
        }
        setupTextDelegate()
        
        // Do any additional setup after loading the view.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        registerKeyboardNotification()
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        unregisterKeyboardNotifications()
    }
    private func registerKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    private func setupPassagerUI() {
        passangerView.isHidden = false
        passangerFooter.isHidden = false
    }
    
    private func setupDriverUI() {
        driverView.isHidden = false
        driverFooter.isHidden = false
    }
    
    private func setupTextDelegate() {
        carMakerModelTextField.delegate = self
    }
    @objc private func willShowKeyboard(notification: Notification){
        guard let info = notification.userInfo,
            let keyboardFrame = info["UIKeyboardFrameEndUserInfoKey"] as? CGRect else {
                print("UserInfo is nil")
                return
        }
            contentView.transform = CGAffineTransform(translationX: 0, y: -keyboardFrame.height)
        
    }
    
    @objc private func willHideKeyboard(){
        contentView.transform = CGAffineTransform.identity
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    private func unregisterKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
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
        let screenTap = UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyboard))
        let homeAddressTap = UITapGestureRecognizer.init(target: self, action: #selector(presentAutocompleteVC))
        homeAddressView.addGestureRecognizer(homeAddressTap)
        view.addGestureRecognizer(screenTap)
    }
    @objc func presentAutocompleteVC() {
        GoogleHelper.setupAutoCompeteVC(Vc: self)
        
    }
    @IBAction func uploadPhotoPressed(_ sender: Any) {
        showSheetAlert(title: "Please select option", message: nil) { (alertController) in
            let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { (action) in
                self.imagePickerController.sourceType = .camera
                self.present(self.imagePickerController, animated: true)
            })
            let photoLibaryAction = UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
                self.imagePickerController.sourceType = .photoLibrary
                self.present(self.imagePickerController, animated: true)
            })
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                alertController.addAction(cameraAction)
                alertController.addAction(photoLibaryAction)
            } else {
                alertController.addAction(photoLibaryAction)
            }
        }
    }
    
    @IBAction func donePressed(_ sender: Any) {
        updateMoreInfo()
    }
    
    func updateMoreInfo() {
        
        guard let homeAddress = self.homeAddress else {
                showAlert(title: "Please Complete missing fields", message: nil)
                return
        }
        if typeOfUser == TypeOfUser.Driver.rawValue {
            guard let carModelMakerText = carMakerModelTextField.text,
                !carModelMakerText.isEmpty else {return}
            guard let selectedImage = selectedImage else {
                showAlert(title: "Plase select image", message: nil)
                return
            }
            guard let userProfileImageData = selectedImage.jpegData(compressionQuality: 0.5) else {return}
            StorageService.postImage(imageData: userProfileImageData, imageName: manoUser.userId) { (error, url) in
                if let error = error {
                    self.showAlert(title: "Error updating profile image", message: error.localizedDescription)
                    
                }
                if let url = url {
                    
                    DBService.updateDriverMoreInfo(userID: self.manoUser.userId, profileImage: url.absoluteString, homeAddress: homeAddress, homeLat: self.homeLat, homeLon: self.homeLon, carMakerModel: carModelMakerText, completion: { (error) in
                        if let error = error {
                            self.showAlert(title: "Error uploading more info", message: error.localizedDescription)
                        } else {
                            let bioVC = BioViewController(nibName: nil, bundle: nil, manoUser: self.manoUser, typeOfUser: self.typeOfUser)
                            bioVC.modalPresentationStyle = .overCurrentContext
                            self.present(bioVC, animated: true)
                        }
                    })
                    }
            }

            } else {
                DBService.updatePassangerMoreInfo(userID: manoUser.userId, homeAddress: homeAddress, homeLat: homeLat, homeLon: homeLon , completion: { (error) in
                if let error = error {
                      self.showAlert(title: "Error uploading more info", message: error.localizedDescription)
                } else {
                    let bioVC = BioViewController(nibName: nil, bundle: nil, manoUser: self.manoUser, typeOfUser: self.typeOfUser)
                    bioVC.modalPresentationStyle = .overCurrentContext
                    self.present(bioVC, animated: true)
                }
            })
        }
    }
}


extension MoreInfoViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
extension MoreInfoViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            print("original image is nil")
            return
        }
        let resizedImage = Toucan.init(image: originalImage).resize(CGSize(width: 500, height: 500))
        selectedImage = resizedImage.image
        userImage.setImage(resizedImage.image, for: .normal)
        dismiss(animated: true)
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
