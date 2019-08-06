//
//  CreateAccountViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/18/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: RoundedTextField!
    
    @IBOutlet weak var lastNameTextField: RoundedTextField!
    
    @IBOutlet weak var emailTextField: RoundedTextField!
    
    @IBOutlet weak var passwordTextField: RoundedTextField!
    
    @IBOutlet weak var confirmTextField: RoundedTextField!
    
    @IBOutlet weak var patientButton: RoundedButton!
    
    @IBOutlet weak var driverButton: RoundedButton!
    
    @IBOutlet weak var createButton: RoundedButton!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var typeOfUser: String?
    private var authservice = AppDelegate.authservice
    private var scrollUp = Bool()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFieldDelegatesAndType()
        setupScreenTap()
        authservice.authserviceCreateNewAccountDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        registerKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        unregisterKeyboardNotifications()
    }

    func setupScreenTap() {
        let screenTap = UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(screenTap)
    }
    func setupTextFieldDelegatesAndType() {
        
        emailTextField.textContentType = .oneTimeCode
        passwordTextField.textContentType = .oneTimeCode
        confirmTextField.textContentType = .oneTimeCode
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmTextField.delegate = self
    }
    
    private func registerKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func willShowKeyboard(notification: Notification){
        guard let info = notification.userInfo,
            let keyboardFrame = info["UIKeyboardFrameEndUserInfoKey"] as? CGRect else {
                print("UserInfo is nil")
                return
        }
        if scrollUp {
        contentView.transform = CGAffineTransform(translationX: 0, y: -keyboardFrame.height)
        }
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
    
    private func createNewUser(){
        activityIndicator.startAnimating()
        guard let email = emailTextField.text,
            let password = passwordTextField.text,
            let confirmPassword = confirmTextField.text,
            let firstName = firstNameTextField.text,
            let lastName = lastNameTextField.text,
            let typeOfUser = typeOfUser,
            !email.isEmpty,
            !confirmPassword.isEmpty,
            !password.isEmpty,
            !firstName.isEmpty,
            !lastName.isEmpty
            else {
                showAlert(title: "Missing Required Fields", message: nil)
                return
        }
        if password != confirmPassword {
            showAlert(title: "Passwords do not match", message: "Try again")
        } else {
            authservice.createAccount(firstName: firstName, lastName: lastName , password: password, email: email, typeOfUser: typeOfUser)
        }
        
    }
    @IBAction func patientButtonPressed(_ sender: Any) {
        typeOfUser = TypeOfUser.Rider.rawValue
        patientButton.setTitleColor(#colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1), for: .normal)
        patientButton.backgroundColor = #colorLiteral(red: 0.9882352941, green: 0.5137254902, blue: 0.2039215686, alpha: 1)
        driverButton.setTitleColor(#colorLiteral(red: 0.9882352941, green: 0.5137254902, blue: 0.2039215686, alpha: 1), for: .normal)
        driverButton.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
    }
    
    
    @IBAction func driverButtonPressed(_ sender: Any) {
        typeOfUser = TypeOfUser.Driver.rawValue
        driverButton.setTitleColor(#colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1), for: .normal)
        driverButton.backgroundColor = #colorLiteral(red: 0.9882352941, green: 0.5137254902, blue: 0.2039215686, alpha: 1)
        patientButton.setTitleColor(#colorLiteral(red: 0.9882352941, green: 0.5137254902, blue: 0.2039215686, alpha: 1), for: .normal)
        patientButton.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func createPressed(_ sender: Any) {
        createNewUser()
    }
    
}

extension CreateAccountViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 || textField.tag == 2 || textField.tag == 3 {
            scrollUp = true
        } else {
            scrollUp = false
        }
    }
}

extension CreateAccountViewController : AuthServiceCreateNewAccountDelegate {
    func didRecieveErrorCreatingAccount(_ authservice: AuthService, error: Error) {
        showAlert(title: "Account Creation Error", message: error.localizedDescription)
    }
    
    func didCreateNewAccount(_ authservice: AuthService, user: ManoUser) {

        unregisterKeyboardNotifications()
        if typeOfUser == TypeOfUser.Driver.rawValue {
            let moreDriver = DriverMoreInfoViewController(nibName: nil, bundle: nil, manoUser: user, typeOfUser: typeOfUser!)
            navigationController?.pushViewController(moreDriver, animated: true)
        } else {
            let moreInfoVC = MoreInfoViewController(nibName: nil, bundle: nil, manoUser: user, typeOfUser: typeOfUser!)
            navigationController?.pushViewController(moreInfoVC, animated: true)
        }
        
    }
    
}
