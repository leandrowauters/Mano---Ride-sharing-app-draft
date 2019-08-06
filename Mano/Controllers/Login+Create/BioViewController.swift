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
    
    private var manoUser: ManoUser!
    private var typeOfUser = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        bioTextView.delegate = self
        addTabBar()
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, manoUser: ManoUser, typeOfUser: String) {
        self.manoUser = manoUser
        self.typeOfUser = typeOfUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
    func addTabBar() {
        let bar = UIToolbar()
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
        bar.items = [done]
        bar.sizeToFit()
        bioTextView.inputAccessoryView = bar
    }
    
    @objc func doneTapped() {
        self.view.endEditing(true)
    }
    func updateBio() {
        if bioTextView.text == "Please tell us about a little about yourself..." || bioTextView.text.isEmpty {
            showAlert(title: "Bio is empty", message: "Plase enter text")
        } else {
            DBService.currentManoUser = self.manoUser
            DBService.updateBio( userId: manoUser.userId, bioText: bioTextView.text) { (error) in
                if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    
    
    @IBAction func okayPressed(_ sender: Any) {
        updateBio()
    
        let tab = TabBarViewController.setTabBarVC(typeOfUser: typeOfUser)
            present(tab, animated: true)
        
        }
        
    
    

}

extension BioViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    
}
