//
//  SendMessageViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/28/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import MessageUI

protocol MessageDelegate: AnyObject {
    func messageSent()
    func messageError(error: String)
}
class SendMessageViewController: UIViewController, MFMessageComposeViewControllerDelegate, UITextFieldDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            dismiss(animated: true)
        case .sent:
            delegate.messageSent()
        case .failed:
            delegate.messageError(error: "Failed")
        default:
            delegate.messageError(error: "Default")
        }
    }
    
    @IBOutlet weak var otherTextfield: RoundedBlueTextField!
    
    var number: String!
    
    weak var delegate: MessageDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        otherTextfield.delegate = self
        // Do any additional setup after loading the view.
    }

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, number: String, delegate: MessageDelegate) {
        self.number = number
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func registerKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    private func unregisterKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc public func willShowKeyboard(notification: Notification){
        guard let info = notification.userInfo,
            let keyboardFrame = info["UIKeyboardFrameEndUserInfoKey"] as? CGRect else {
                print("UserInfo is nil")
                return
        }
        view.transform = CGAffineTransform(translationX: 0, y: -keyboardFrame.height)
        
    }
    
    @objc public func willHideKeyboard(){
        view.transform = CGAffineTransform.identity
    }
    
    @objc public func dismissKeyboard() {
        view.endEditing(true)
    }
    private func sendMessage(message: String, number: String) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = message
            controller.recipients = [number]
            controller.messageComposeDelegate = self
            
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        sendMessage(message: sender.titleLabel!.text!, number: number)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        guard let message = textField.text else {
            showAlert(title: "Please have a message", message: nil)
            return true
        }
        sendMessage(message: message, number: number)
        return true
    }
}
