//
//  BioViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/18/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit

class BioViewController: UIViewController {

    @IBOutlet weak var bioTextView: UITextView!
    
    private var userId = String()
    private var typeOfUser = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        bioTextView.delegate = self
        setupScreenTap()
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, userId: String, typeOfUser: String) {
        self.userId = userId
        self.typeOfUser = typeOfUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func setupScreenTap() {
        let screenTap = UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(screenTap)
    }
    
    func updateBio() {
        if bioTextView.text == "Please tell us about a little about yourself..." || bioTextView.text.isEmpty {
            showAlert(title: "Bio is empty", message: "Plase enter text")
        } else {
            DBService.updateBio( userId: userId, bioText: bioTextView.text) { (error) in
                if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func okayPressed(_ sender: Any) {
        updateBio()
    
        let tab = TabBarViewController.setTabBarVC(typeOfUser: typeOfUser, userId:userId)
            present(tab, animated: true)
        
        }
        
    
    

}

extension BioViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    
}
