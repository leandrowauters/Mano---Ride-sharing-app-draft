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
    var message: Message?
    var seeMessage = Bool()
    @IBOutlet weak var messageToLabel: UILabel!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTabBar()
        setup()
        // Do any additional setup after loading the view.
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, recipientId: String, recipientName: String, message: Message?) {
        self.recipientId = recipientId
        self.recipientName = recipientName
        self.message = message
        super.init(nibName: nil, bundle: nil)
    }
    
    private func setup() {
        if let message = message {
            seeMessage = true
            sendButton.setTitle("Reply", for: .normal)
            messageToLabel.text = "From: \(message.sender)"
            textField.text = message.message
            textField.isUserInteractionEnabled = false
        } else {
            seeMessage = false
            textField.delegate = self
            messageToLabel.text = "To: \(recipientName ?? "No name")"
        }
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
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        if seeMessage {
            sendButton.setTitle("Send", for: .normal)
            seeMessage = false
            textField.becomeFirstResponder()
            textField.text = ""
            messageToLabel.text = "To: \(recipientName ?? "")"
        } else {
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
                        self.navigationController?.popViewController(animated: true)
                    })
                }
            }
        }

    }
}

extension MessageViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    
}
