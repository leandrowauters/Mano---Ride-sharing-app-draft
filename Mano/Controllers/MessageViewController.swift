//
//  MessageViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 8/3/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    
    var recipientId: String!
    var recipientName: String!
    
    @IBOutlet weak var messageToLabel: UILabel!
    @IBOutlet weak var textField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTabBar()
        textField.delegate = self
        messageToLabel.text = "To: \(recipientName ?? "No name")"
        // Do any additional setup after loading the view.
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, recipientId: String, recipientName: String) {
        self.recipientId = recipientId
        self.recipientName = recipientName
        super.init(nibName: nil, bundle: nil)
    }
    
    func addTabBar() {
        let bar = UIToolbar()
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
        bar.items = [done]
        bar.sizeToFit()
        textField.inputAccessoryView = bar
    }
    
    @objc func doneTapped() {
        self.view.endEditing(true)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        guard let message = textField.text,
            !message.isEmpty else {
                showAlert(title: "Please write message", message: nil)
                return
        }
        let sentDate = Date().dateDescription
        let messageToSend = Message(sender: DBService.currentManoUser.fullName, recipient: recipientName, senderId: DBService.currentManoUser.userId , recipientId: recipientId, message: message, messageId: "", messageDate: sentDate, read: false)
        DBService.sendMessage(message: messageToSend) { (error) in
            if let error = error {
                self.showAlert(title: "Error sending message", message: error.localizedDescription)
            } else {
                self.showAlert(title: "Message sent!", message: nil, handler: { (done) in
                    self.dismiss(animated: true)
                })
            }
        }
    }
}

extension MessageViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    
}
