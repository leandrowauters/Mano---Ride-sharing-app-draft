//
//  DriverMoreInfoViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/25/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import Toucan
import GooglePlaces
import Kingfisher
class DriverMoreInfoViewController: UIViewController {
    
    private var manoUser: ManoUser!
    private var typeOfUser: String!
    var selectedYourImage: UIImage?
    var selectedYourCarImage: UIImage?
    
    var firstImageSelected: Bool!
    private lazy var imagePickerController: UIImagePickerController = {
        let ip = UIImagePickerController()
        ip.delegate = self
        return ip
    }()
    
    private var homeAddress: String?
    private var homeLat: Double!
    private var homeLon: Double!

    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var homeAddressButton: RoundedButton!
    
    @IBOutlet weak var carMakerModel: UITextField!
    
    @IBOutlet weak var licencePlateModel: UITextField!
    
    @IBOutlet weak var yourImageImageView: CircularImageWhite!
    
    @IBOutlet weak var yourCarImageImageView: RoundedImageViewWhite!
    @IBOutlet weak var cellPhoneTextField: RoundedTextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageViewTaps()
        setupDelegations()
        setupTap()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        unregisterKeyboardNotifications()

    }
    private func registerKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    

    func setupImageViewTaps() {
        let yourPhotoImageTap = UITapGestureRecognizer.init(target: self , action: #selector(yourImagePressed))
        let yourCarImageTap = UITapGestureRecognizer(target: self, action: #selector(yourCarImagePressed))
        yourCarImageImageView.addGestureRecognizer(yourCarImageTap)
        yourImageImageView.addGestureRecognizer(yourPhotoImageTap)
    }
    
    func setupDelegations() {
        carMakerModel.delegate = self
        licencePlateModel.delegate = self
        
    }
    func showImagesSourceOptions() {
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
    @objc func yourImagePressed() {
        firstImageSelected = true
        showImagesSourceOptions()
    }
    @objc func yourCarImagePressed() {
        firstImageSelected = false
        showImagesSourceOptions()
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
    
    @IBAction func homeAddressPressed(_ sender: Any) {
        MapsHelper.setupAutoCompeteVC(Vc: self)
    }
    
    private func setupTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        activityIndicator.startAnimating()
        guard let homeAddress = homeAddress,
            let carMakeModel = carMakerModel.text,
            let licencePlate = licencePlateModel.text,
            let cellPhone = cellPhoneTextField.text,
            !cellPhone.isEmpty,
        !homeAddress.isEmpty,
        !carMakeModel.isEmpty,
            !licencePlate.isEmpty,
            let selectedYourImage = selectedYourImage,
            let selectedYourCarImage = selectedYourCarImage else {
                showAlert(title: "Please Complete missing fields", message: nil)
                return
        }
        guard let userProfileImageData = selectedYourImage.jpegData(compressionQuality: 0.5),
        let userCarImageData = selectedYourCarImage.jpegData(compressionQuality: 0.5) else {return}
        
        StorageService.postImage(imageData: userProfileImageData, imageName: manoUser.userId) { [weak self] error, url in
            var urls = [URL]()
            if let error = error {
                self?.showAlert(title: "Error uploading photo", message: error.localizedDescription)
            }
            if let url = url {
                urls.append(url)
                StorageService.postImage(imageData: userCarImageData, imageName: (self?.manoUser.userId)! + "car", completion: { [weak self] error, url in
                    if let error = error {
                        self?.showAlert(title: "Error uploading photo", message: error.localizedDescription)
                    }
                    if let url = url {
                        urls.append(url)
                        let updatedManoUser = ManoUser(firstName: (self?.manoUser.firstName)!, lastName: (self?.manoUser.lastName)!, fullName: (self?.manoUser.fullName)!, homeAdress: homeAddress, homeLat: self?.homeLat, homeLon: self?.homeLon, profileImage: urls[0].absoluteString, carMakerModel: carMakeModel, bio: nil, typeOfUser: (self?.manoUser.typeOfUser)!, regulars: nil, joinedDate: (self?.manoUser.joinedDate)!, userId: (self?.manoUser.userId)!, numberOfRides:  nil, numberOfMiles:  nil, licencePlate: licencePlate, carPicture: urls[1].absoluteString,cellPhone: cellPhone, rides: nil)
                        DBService.updateDriverMoreInfo(userID: (self?.manoUser.userId)!, profileImage: urls[0].absoluteString, homeAddress: homeAddress, homeLat: self!.homeLat, homeLon: self!.homeLon, carMakerModel: carMakeModel, licencePlate: licencePlate, carPhoto: urls[1].absoluteString, cellPhone: cellPhone, completion: { [weak self] error in
                            if let error = error {
                                self?.showAlert(title: "Error uploading more info", message: error.localizedDescription)
                            } else {
                                let bioVC = BioViewController(nibName: nil, bundle: nil, manoUser: updatedManoUser, typeOfUser: self!.typeOfUser)
                                bioVC.modalPresentationStyle = .overCurrentContext
                                self?.present(bioVC, animated: true)
                            }
                        })
                    }
                    
                })
            }
        }

    }
}

extension DriverMoreInfoViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension DriverMoreInfoViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            print("original image is nil")
            return
        }
        let resizedImage = Toucan.init(image: originalImage).resize(CGSize(width: 414  , height: 250))
        if firstImageSelected{
            selectedYourImage = resizedImage.image
            yourImageImageView.image = selectedYourImage
        } else {
            selectedYourCarImage = resizedImage.image
            yourCarImageImageView.image = resizedImage.image
        }
        dismiss(animated: true)
    }
}

extension DriverMoreInfoViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        guard let homeAddress = place.formattedAddress else {
            showAlert(title: "Error finding address", message: nil)
            return}
        let coordinate = place.coordinate
        self.homeAddress = homeAddress
        let shortertAddress = MapsHelper.getShortertString(string: homeAddress)
        homeAddressButton.setTitle(shortertAddress, for: .normal)
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
