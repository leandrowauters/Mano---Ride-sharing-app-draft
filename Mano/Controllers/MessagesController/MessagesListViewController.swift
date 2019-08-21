//
//  MessagesListViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 8/4/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit

class MessagesListViewController: UIViewController {

    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messagesTableView: UITableView!
    
    var messages = [Message]() {
        didSet {
            DispatchQueue.main.async {
                self.messagesTableView.reloadData()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupTextView()
        setupTableView()
        registerKeyboardNotifications()
    }
    
    private func setup() {
        let screenTap = UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(screenTap)
    }
    
    private func setupTableView() {
        messagesTableView.delegate = self
        messagesTableView.dataSource = self
        messagesTableView.register(UINib(nibName: "RecipientCell", bundle: nil), forCellReuseIdentifier: "RecipientCell")
        messagesTableView.register(UINib(nibName: "SenderCell", bundle: nil), forCellReuseIdentifier: "SenderCell")
    }
    
    private func setupTextView() {
        messageTextView.delegate = self
        messageTextView.isScrollEnabled = false
        textViewDidChange(messageTextView)
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        unregisterKeyboardNotifications()
    }
    
    private func registerKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyBaord), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyBaord), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unregisterKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func willShowKeyBaord(notification: Notification){
        guard let info = notification.userInfo, let keyBoardFrame = info["UIKeyboardFrameEndUserInfoKey"] as? CGRect else {
            print("UserInfo is nil")
            return
        }
        sendButton.transform = CGAffineTransform.init(translationX: 0, y: -keyBoardFrame.height)
        messageTextView.transform = CGAffineTransform.init(translationX: 0, y: -keyBoardFrame.height)
    }
    
    @objc private func willHideKeyBaord(notification: Notification){
        messageTextView.transform = CGAffineTransform.identity
        sendButton.transform = CGAffineTransform.identity
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
    }
    


    
}

extension MessagesListViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.bounds.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

extension MessagesListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let recipientCell = tableView.dequeueReusableCell(withIdentifier: "RecipientCell", for: indexPath) as? RecipientCell else { fatalError()}
        guard let senderCell = tableView.dequeueReusableCell(withIdentifier: "SenderCell", for: indexPath) as? SenderCell else {
            fatalError()
        }

        return recipientCell
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 80
        }
    }
    
   func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 80
        }
    }
}
