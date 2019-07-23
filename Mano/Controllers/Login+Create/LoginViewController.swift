//
//  LogingViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/17/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: RoundedTextField!
    
    @IBOutlet weak var passwordTextField: RoundedTextField!
    

    private var authservice = AppDelegate.authservice
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        registerKeyboardNotifications()
        setupTextFieldsDelegates()
        // Do any additional setup after loading the view.
    }
    private func registerKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyBaord), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyBaord), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func willShowKeyBaord(notification: Notification){
        guard let info = notification.userInfo, let keyBoardFrame = info["UIKeyboardFrameEndUserInfoKey"] as? CGRect else {
            print("UserInfo is nil")
            return
        }
        //print(" UserInfo is:  \(info)")
        view.transform = CGAffineTransform.init(translationX: 0, y: -keyBoardFrame.height + 200)
    }
    
    @objc private func willHideKeyBaord(notification: Notification){
        view.transform = CGAffineTransform.identity
    }
    
    private func setup() {
        let screenTap = UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyboard))
         view.addGestureRecognizer(screenTap)
        authservice.authserviceExistingAccountDelegate = self
    }
    
    private func setupTextFieldsDelegates() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    private func signInCurrentUser(){
        guard let email = emailTextField.text,
            !email.isEmpty,
            let password = passwordTextField.text,
            !password.isEmpty
            else {
                   showAlert(title: "Please enter information", message: "ex: yourmail@email.com")
                return
        }
        authservice.signInExistingAccount(email: email, password: password)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        unregisterKeyboardNotifications()
    }
    
    
    private func unregisterKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        signInCurrentUser()
    }
    
    @IBAction func createAccountPressed(_ sender: Any) {
        let createVC = CreateAccountViewController()
        navigationController?.pushViewController(createVC, animated: true)
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
extension LoginViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension LoginViewController : AuthServiceExistingAccountDelegate {
    func didSignInToExistingAccount(_ authservice: AuthService, user: User) {
        DBService.fetchManoUser(userId: user.uid) { (error, manoUser) in
            if let error = error {
                self.showAlert(title: "Error signign in", message: error.localizedDescription)
            }
            if let manoUser = manoUser {
                DBService.currentManoUser = manoUser
                let tab = TabBarViewController.setTabBarVC(typeOfUser: manoUser.typeOfUser, userId: nil)
                self.present(tab, animated: true)
            }
        }
        
    }
    
    func didRecieveErrorSigningToExistingAccount(_ authservice: AuthService, error: Error) {
        showAlert(title: "Signin Error", message: error.localizedDescription)
    }
    
}
