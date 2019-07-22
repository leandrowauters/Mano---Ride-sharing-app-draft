//
//  GoogleMapsHelper.swift
//  Mano
//
//  Created by Leandro Wauters on 7/21/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import Foundation
import GooglePlaces
import GoogleMaps
class GoogleMapsHelper {
    
    static public func setupGMSAutoComplete(autocompleteController: GMSAutocompleteViewController) {
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0, green: 0.4980392157, blue: 0.737254902, alpha: 1)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UITextField.appearance().attributedPlaceholder = NSAttributedString(string:
            "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        autocompleteController.primaryTextColor = #colorLiteral(red: 0, green: 0.6754498482, blue: 0.9192627668, alpha: 1)
        autocompleteController.primaryTextHighlightColor = #colorLiteral(red: 0, green: 0.4980392157, blue: 0.737254902, alpha: 1)
        autocompleteController.secondaryTextColor = #colorLiteral(red: 0, green: 0.6754498482, blue: 0.9192627668, alpha: 1)
        autocompleteController.tableCellSeparatorColor = #colorLiteral(red: 0, green: 0.4980392157, blue: 0.737254902, alpha: 1)
        autocompleteController.placeFields = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.formattedAddress.rawValue) |
            UInt(GMSPlaceField.addressComponents.rawValue) |
            UInt(GMSPlaceField.coordinate.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue))!
    }
}
