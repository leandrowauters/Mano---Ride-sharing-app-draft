//
//  ListenerHelper.swift
//  Mano
//
//  Created by Leandro Wauters on 8/16/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

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
                    let onWayToDropoffVC = OnWayToDropoffViewController(nibName: nil, bundle: nil, ride: ride)
                    vc.navigationController?.pushViewController(onWayToDropoffVC, animated: true)
                case RideStatus.onWaitingToRequest.rawValue:
                    let waitingForRequestVC = WaitingForRequestViewController(nibName: nil, bundle: nil, ride: ride)
                    vc.navigationController?.pushViewController(waitingForRequestVC, animated: true)
                case RideStatus.onPickupReturnRide.rawValue:
                    let onItsWayVC = OnItsWayViewController(nibName: nil, bundle: nil, duration: nil, distance: nil, ride: ride)
                    vc.navigationController?.pushViewController(onItsWayVC, animated: true)
                case RideStatus.onDropoffReturnRide.rawValue:
                    let onWayToDropOffVC = OnWayToDropoffViewController(nibName: nil, bundle: nil, ride: ride)
                    vc.navigationController?.pushViewController(onWayToDropOffVC, animated: true)
                default:
                    return
                }
            }
        }
    }
    
    public func listenForRideAcceptence(vc: UIViewController) -> ListenerRegistration{
        return DBService.listenForRideAcceptence(passangerId: DBService.currentManoUser.userId) { (error, ride) in
            if let error = error {
                vc.showAlert(title: "Error fetching accepted ride", message: error.localizedDescription)
            }
            if let ride = ride {
                let rideAcceptedAlertView = RideAcceptedAlertViewController(nibName: nil, bundle: nil, ride: ride)
                rideAcceptedAlertView.modalPresentationStyle = .overCurrentContext
                vc.present(rideAcceptedAlertView, animated: true)
            }
        }
    }
    
    public func listenForDriverOnItsWay(vc: UIViewController) -> ListenerRegistration {
        return DBService.listenForDriverOnItsWay {  (error, ride) in
            
            if let error = error {
                vc.showAlert(title: "Error updating to onItsWay", message: error.localizedDescription)
            }
            if let ride = ride {
                let location = CLLocation(latitude: ride.originLat, longitude: ride.originLon)
                MapsHelper.calculateMilesAndTimeToDestination(destinationLat: ride.pickupLat,destinationLon: ride.pickupLon, userLocation: location, completion: { (miles, time, milesInt, timeInt) in
                    vc.showAlert(title: "Your Driver it's on his way", message: nil, handler: { (okay) in
                        
                        DBService.updatePassangerKnowsDriverOnItsWay(ride: ride, completion: {  (error) in
                            if let error = error {
                                print(error.localizedDescription)
                            } else {
                                let onItsWayVc = OnItsWayViewController(nibName: nil, bundle: nil, duration: time, distance: nil, ride: ride)
                                vc.navigationController?.pushViewController(onItsWayVc, animated: true)
                            }
                            
                        })
                    })
                })
            }
        }

    }
}
