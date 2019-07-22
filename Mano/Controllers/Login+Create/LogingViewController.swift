//
//  LogingViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/17/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameTextField: RoundedTextField!
    @IBOutlet weak var passwordTextField: RoundedTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func setup() {
        let screenTap = UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyboard))
    }
    
    func setupTextFieldsDelegates() {
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        
    }
    @IBAction func createAccountPressed(_ sender: Any) {
        
    }
    


}

extension LoginViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
