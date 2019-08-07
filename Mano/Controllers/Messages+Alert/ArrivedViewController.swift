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
    func userPressBeginDropOff(ride: Ride)
}

class ArrivedViewController: UIViewController, MFMessageComposeViewControllerDelegate {

    let delegate: MessageDelegate!
    let arriveDelegate: ArriveViewDelegate
    let ride: Ride!
    private var number: String!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, number: String, delegate: MessageDelegate, arriveDelegate: ArriveViewDelegate, ride: Ride) {
        self.number = number
        self.delegate = delegate
        self.arriveDelegate = arriveDelegate
        self.ride = ride
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
        DBService.updateRideStatus(ride: ride, status: RideStatus.changedToDropoff.rawValue) { (error) in
            if let error = error {
               self.showAlert(title: "Error updating to dropoff", message: error.localizedDescription)
            }
        }
//        DBService.updateRideToDropoff(ride: ride) { (error) in
//            if let error = error {
//                self.showAlert(title: "Error updating to dropoff", message: error.localizedDescription)
//            }
//
//        }
        self.dismiss(animated: true)
        self.arriveDelegate.userPressBeginDropOff(ride: ride)
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

