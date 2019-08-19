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

class ListenerHelper {
    
    static let shared = ListenerHelper()
    
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
    
    public func fetchMessages(vc: UITabBarController) -> ListenerRegistration {
       return DBService.fetchYourMessages { (error, messages) in
            if let messages = messages {
                DBService.messagesRecieved = messages
                let newMessage = messages.filter({$0.read == false})
                if !newMessage.isEmpty{
                    vc.tabBar.items!.last!.badgeValue = newMessage.count.description
                } else {
                    vc.tabBar.items!.last!.badgeValue = nil
                }
            }
        }
    }
    
    public func fetchAcceptedRides(vc: UITabBarController) -> ListenerRegistration {
        return DBService.fetchAcceptedRides() { (error, rides) in
            if let error = error {
                vc.showAlert(title: "Error fetching your rides", message: error.localizedDescription)
            }
            if let rides = rides {
                let ridesToday = rides.filter{ Calendar.current.isDateInToday($0.appointmentDate.stringToDate())}
                if DBService.currentManoUser.typeOfUser == TypeOfUser.Driver.rawValue{
                    if !ridesToday.isEmpty{
                        vc.tabBar.items![2].badgeValue = ridesToday.count.description
                    } else {
                        vc.tabBar.items![2].badgeValue = nil
                    }
                }
            }
        }
    }
}
