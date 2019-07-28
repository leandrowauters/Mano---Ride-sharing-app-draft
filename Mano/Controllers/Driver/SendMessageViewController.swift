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
    func messageError()
}
class SendMessageViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        delegate.messageSent()
    }
    
    var number: String!
    
    weak var delegate: MessageDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
