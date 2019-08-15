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
    var reply = false
//    var messageToSend: String?
    var sent: Bool
    @IBOutlet weak var messageToLabel: UILabel!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTabBar()
        setup()
        // Do any additional setup after loading the view.
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, recipientId: String, recipientName: String, message: Message?, sent: Bool) {
        self.recipientId = recipientId
        self.recipientName = recipientName
        self.message = message
        self.sent = sent
        super.init(nibName: nil, bundle: nil)
    }
    
    private func setup() {
        textField.delegate = self
        if sent {
            sendButton.isHidden = true
        }
        if let message = message {
            seeMessage = true
            sendButton.setTitle("Reply", for: .normal)
            messageToLabel.text = "From: \(message.sender)"
            textField.text = "\(message.messageDate)" + "\n" + message.message
            textField.isUserInteractionEnabled = false
        } else {
            seeMessage = false
            
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
    
    private func replyMessage(word: String) -> String {
        var wordToReturn = String()
        var newLineCount = 0
        for char in word {
            
            if char == "\n" {
                newLineCount += 1
            }
            if newLineCount == 4{
                wordToReturn.append(char)
            }
            
        }
        wordToReturn.removeFirst()
        return wordToReturn
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
            reply = true
            textField.becomeFirstResponder()
            textField.text = message!.message + "\n" + "\n" + "> Reply" + "\n" + "\n"
            messageToLabel.text = "To: \(recipientName ?? "")"
            textField.isUserInteractionEnabled = true
        } else {
            var messageToSend: Message!
            
            guard var message = textField.text else {
                    showAlert(title: "Please write message", message: nil)
                    return
            }
            let sentDate = Date().dateDescription
            if reply {
                message = replyMessage(word: message)
            }
            messageToSend = Message(sender: DBService.currentManoUser.fullName, recipient: recipientName, senderId: DBService.currentManoUser.userId , recipientId: recipientId, message: message, messageId: "", messageDate: sentDate, read: false)
            

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
        if !reply {
        textView.text = ""
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if reply {
//            messageToSend = replyMessage(word: textView.text)
        }
    }
}
