//
//  ArrivedViewController.swift
//  Mano
//
//  Created by Leandro Wauters on 7/30/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import MessageUI

protocol ArriveViewDelegate: AnyObject {
    func userPressBeginDropOff()
}

class ArrivedViewController: UIViewController, MFMessageComposeViewControllerDelegate {

    let delegate: MessageDelegate!
    let arriveDelegate: ArriveViewDelegate
    private var number: String!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, number: String, delegate: MessageDelegate, arriveDelegate: ArriveViewDelegate) {
        self.number = number
        self.delegate = delegate
        self.arriveDelegate = arriveDelegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @IBAction func textImOutsidePressed(_ sender: Any) {
        sendMessage(message: "I'm outside", number: number)
    }
    @IBAction func callPressed(_ sender: Any) {
        guard let number = URL(string: "tel://" + number) else { return }
        UIApplication.shared.open(number)
    }
    @IBAction func beginDropOffPressed(_ sender: Any) {
        arriveDelegate.userPressBeginDropOff()
    }
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true)
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

}

