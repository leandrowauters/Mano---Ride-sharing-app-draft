//
//  ListenerHelper.swift
//  Mano
//
//  Created by Leandro Wauters on 8/16/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import CoreLocation
class RideStatusManager {
    
    static let shared = RideStatusManager()
    
    public func navigateToCurrentRideStatus(vc: UIViewController) {
        var key = String()
        switch DBService.currentManoUser.typeOfUser {
        case TypeOfUser.Driver.rawValue:
            key = RideCollectionKeys.driverIdKey
        case TypeOfUser.Passenger.rawValue:
            key = RideCollectionKeys.passangerId
        default:
            return
        }
        
        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).whereField(key, isEqualTo: DBService.currentManoUser.userId).whereField(RideCollectionKeys.inProgressKey, isEqualTo: true).getDocuments { (snapshot, error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
            if let snapshot = snapshot {
                let fetchedRide = snapshot.documents.map{Ride.init(dict: $0.data())}.first
                guard let ride = fetchedRide else {return}
                
                switch ride.rideStatus {
                case RideStatus.onPickup.rawValue:
                    let location = CLLocation(latitude: ride.originLat, longitude: ride.originLon)
                    MapsHelper.calculateMilesAndTimeToDestination(destinationLat: ride.pickupLat,destinationLon: ride.pickupLon, userLocation: location, completion: { (miles, time, milesInt, timeInt) in
                        
                        let onItsWayVc = OnItsWayViewController(nibName: nil, bundle: nil, duration: time, distance: nil, ride: ride)
                        vc.navigationController?.pushViewController(onItsWayVc, animated: true)
                        
                        
                    })
                case RideStatus.onDropoff.rawValue:
                    print("On dropoff")
                case RideStatus.onPickupReturnRide.rawValue:
                    print("On pickup return")
                case RideStatus.onDropoffReturnRide.rawValue:
                    print("On dropoff return")
                default:
                    return
                }
            }
        }
    }
}
