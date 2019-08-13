//
//  GoogleHelper.swift
//  Mano
//
//  Created by Leandro Wauters on 7/22/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import Foundation
import GooglePlaces
import MapKit


struct MapsHelper {
    static public func setupAutoCompeteVC(Vc: UIViewController) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = Vc as? GMSAutocompleteViewControllerDelegate
        let fields = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) |
            UInt(GMSPlaceField.formattedAddress.rawValue) |
            UInt(GMSPlaceField.coordinate.rawValue) |
            UInt(GMSPlaceField.addressComponents.rawValue))
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
    static public func openGoogleMapDirection(currentLat: Double, currentLon: Double, destinationLat: Double, destinationLon: Double,completion: @escaping(Error?) -> Void) {
        guard let url = URL(string: "comgooglemaps://?saddr=\(currentLat),\(currentLon)&daddr=\(destinationLat),\(destinationLon)") else {
            completion(AppError.badURL("Bad URL"))
            return
        }
        UIApplication.shared.open(url)
    }
    
    static public func openWazeDirection(destinationLat: Double, destinationLon: Double, completion: @escaping(Error?) -> Void) {
        if UIApplication.shared.canOpenURL(URL(string: "waze://")!) {
            guard let url = URL(string: "waze://?ll=\(destinationLat),\(destinationLon)&navigate=yes") else {
                completion(AppError.badURL("Bad URL"))
                return
            }
            UIApplication.shared.open(url)
        }
        else {
            UIApplication.shared.open(URL(string: "http://itunes.apple.com/us/app/id323229106")!)
        }
    }
    
    static public func openAppleMapsForDirection(currentLocation: CLLocationCoordinate2D, destinationLat: Double, destinationLon: Double) {
        let source = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation))
        source.name = "Source"
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destinationLat, longitude: destinationLon)))
        destination.name = "Destination"
        MKMapItem.openMaps(with: [source,destination], launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    static public func calculateEta(originLat: Double, originLon: Double, destinationLat: Double, destinationLon: Double, completionHandler: @escaping(AppError?, String? , Int?) -> Void) {
        let departureTime = Int(Date().timeIntervalSince1970)
        let endpointUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=\(originLat),\(originLon)&destination=\(destinationLat),\(destinationLon)&departure_time=\(departureTime)&key=\(GoogleMapsAPI.GoogleMapsAPIKey)"
        print(endpointUrl)
        NetworkHelper.shared.performDataTask(endpointURLString: endpointUrl) { (appError, data) in
            if appError != nil {
                completionHandler(AppError.badURL("Bad URL"), nil, nil)
            }
            if let data = data {
                do{
                    let result = try JSONDecoder().decode(GoogleHelperResults.self, from: data)
                        let etaText = result.routes.first?.legs.first?.duration.text
                    let etaInt = result.routes.first?.legs.first?.duration.value
                    completionHandler(nil, etaText, etaInt)
                } catch {
                    completionHandler(appError, nil, nil)
                }
            }
        }
    }
    
    static public func calculateDistanceToLocation(originLat: Double, originLon: Double, destinationLat: Double, destinationLon: Double, completionHandler: @escaping(AppError?, String? , Int?) -> Void) {

        let endpointUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=\(originLat),\(originLon)&destination=\(destinationLat),\(destinationLon)&key=\(GoogleMapsAPI.GoogleMapsAPIKey)"
        print(endpointUrl)
        NetworkHelper.shared.performDataTask(endpointURLString: endpointUrl) { (appError, data) in
            if appError != nil {
                completionHandler(AppError.badURL("Bad URL"), nil, nil)
            }
            if let data = data {
                do{
                    let result = try JSONDecoder().decode(GoogleHelperResults.self, from: data)
                   let estimatedDistanceInText = result.routes.first?.legs.first?.distance.text
                    let estimatedDistanceInInt = result.routes.first?.legs.first?.distance.value
                    completionHandler(nil, estimatedDistanceInText, estimatedDistanceInInt)
                    
                } catch {
                    completionHandler(appError, nil, nil)
                }
            }
        }
    }
    
    static public func getShortertString(string: String) -> String {
        var newWord = String()
        for character in string {
            if character == "," {
                return newWord
            }
            newWord.append(character)
        }
        return String()
    }
    
    static public func calculateMilesAndTimeToDestination(destinationLat: Double, destinationLon: Double, userLocation: CLLocation , completion: @escaping(String, String, Double, Double) -> Void) {
        
        let destinationCLLocation = CLLocation(latitude: destinationLat, longitude: destinationLon)
//        if pickup {
//            destinationCLLocation = CLLocation(latitude: ride.pickupLat, longitude: ride.pickupLon)
//        } else {
//            destinationCLLocation = CLLocation(latitude: ride.dropoffLat, longitude: ride.dropoffLon)
//        }
        let request = MKDirections.Request()
        let source = MKPlacemark(coordinate: userLocation.coordinate)
        let destination = MKPlacemark(coordinate: destinationCLLocation.coordinate)
        request.source = MKMapItem(placemark: source)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = MKDirectionsTransportType.automobile
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            if let response = response, let route = response.routes.last {
                let responseDistance = route.distance
                let miles = responseDistance * 0.000621371
                let milesRounded = Double(round(10*miles)/10)
                let time = route.expectedTravelTime
                let timeRoundedToSeconds = MainTimer.timeString(time: time)
                completion(milesRounded.description, timeRoundedToSeconds, milesRounded, time)
//                self.distanceLabel.text = "Distance: \n \(milesRounded.description) Mil"
//                self.durationLabel.text = "Duration: \n \(timeRoundedToSeconds.description)"
//                self.activityIndicator.stopAnimating()
            }
        }
        
    }

}

struct GoogleHelperResults: Codable {
    let routes: [Legs]
    enum CodingKeys : String, CodingKey {
        case routes = "routes"
    }
}
struct Legs: Codable {
    let legs: [Distance]
    enum CodingKeys : String, CodingKey {
        case legs = "legs"
    }
}


struct Distance: Codable {
    let distance: Result
    let duration: Result
}

struct Result: Codable {
    let text: String
    let value: Int
}
