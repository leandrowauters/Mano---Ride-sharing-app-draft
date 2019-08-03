//
//  ViewController+Alert.swift
//  Mano
//
//  Created by Leandro Wauters on 7/17/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit

extension UIViewController {
    public func showAlert(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { alert in }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    public func showAlert(title: String?, message: String?, handler: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: handler)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    public func showConfimationAlert(title: String?, message: String?, handler: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: .default, handler: handler)
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    public func showSheetAlert(title: String, message: String?, handler: @escaping (UIAlertController) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        handler(alertController)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true)
        }
        alertController.addAction(cancel)
        present(alertController, animated: true)
    }

    
    public func profileAlertSheet(title: String, contact: String, handler: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Cancel Ride", style: .destructive, handler: handler)
        let addToCalendar = UIAlertAction(title: "Add To Calendar", style: .default, handler: handler)
        let contact = UIAlertAction(title: contact, style: .default, handler: handler)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true)
        }
        alertController.addAction(addToCalendar)
        alertController.addAction(contact)
        alertController.addAction(deleteAction)
        alertController.addAction(cancel)
        present(alertController, animated: true)
    }
}
