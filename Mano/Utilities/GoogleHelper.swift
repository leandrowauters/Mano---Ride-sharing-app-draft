//
//  GoogleHelper.swift
//  Mano
//
//  Created by Leandro Wauters on 7/22/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import Foundation
import GooglePlaces


struct GoogleHelper {
    static public func setupAutoCompeteVC(Vc: UIViewController) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = Vc as? GMSAutocompleteViewControllerDelegate
        let fields = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) |
            UInt(GMSPlaceField.formattedAddress.rawValue) |
            UInt(GMSPlaceField.coordinate.rawValue))
        if let fields = fields {
            autocompleteController.placeFields = fields
            
        }
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0, green: 0.4980392157, blue: 0.737254902, alpha: 1)
        UINavigationBar.appearance().tintColor = UIColor.white
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        
        autocompleteController.primaryTextHighlightColor = #colorLiteral(red: 0, green: 0.4980392157, blue: 0.737254902, alpha: 1)
        autocompleteController.primaryTextColor = #colorLiteral(red: 0, green: 0.6754498482, blue: 0.9192627668, alpha: 1)
        autocompleteController.secondaryTextColor = #colorLiteral(red: 0, green: 0.6754498482, blue: 0.9192627668, alpha: 1)
        autocompleteController.tableCellSeparatorColor = #colorLiteral(red: 0, green: 0.4980392157, blue: 0.737254902, alpha: 1)
        Vc.present(autocompleteController, animated: true, completion: nil)
        
        
        
        
        
    }
}
