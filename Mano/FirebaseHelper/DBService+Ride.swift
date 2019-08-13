//
//  DBService+Ride.swift
//  Mano
//
//  Created by Leandro Wauters on 7/22/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import Foundation
import FirebaseFirestore
extension DBService {
    
    static public func createARide(date: String, passangerId: String, passangerName: String, pickupAddress: String, dropoffAddress: String, dropoffName: String?, pickupLat: Double, pickupLon: Double, dropoffLat: Double, dropoffLon: Double, dateRequested: String, passangerCell: String, completion: @escaping(Error?)-> Void) {
       let ref =  DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).document()
        firestoreDB.collection(RideCollectionKeys.collectionKey).document(ref.documentID).setData([RideCollectionKeys.appoinmentDateKey : date,
                                                                                                   RideCollectionKeys.passangerId : passangerId,
                                                                                                   RideCollectionKeys.rideIdKey : ref.documentID,
                                                                                                   RideCollectionKeys.passangerName : passangerName,
                                                                                                   RideCollectionKeys.pickupAddressKey : pickupAddress, RideCollectionKeys.dropoffAddressKey : dropoffAddress, RideCollectionKeys.pickupLatKey : pickupLat, RideCollectionKeys.pickupLonKey : pickupLon, RideCollectionKeys.dropoffLonKey :dropoffLon, RideCollectionKeys.dropoffLatKey : dropoffLat, RideCollectionKeys.dateRequestedKey : dateRequested, RideCollectionKeys.passangerCellKey : passangerCell,
            RideCollectionKeys.dropoffNameKey : dropoffName ?? "Drop-off name unavailable"
                                                                
        ]) { (error) in
            if let error = error {
                completion(error)
            }
        }
    }
    
    static public func fetchAllRides(completion: @escaping(Error?, [Ride]?) -> Void) {
        let query = firestoreDB.collection(RideCollectionKeys.collectionKey)
        query.addSnapshotListener { (snapshot, error) in
            if let error = error {
                completion(error, nil)
            }
            if let snapshot = snapshot {
                var rides = [Ride]()
                for document in snapshot.documents {
                    let ride = Ride.init(dict: document.data())
                    if ride.appointmentDate.stringToDate().dateExpired() {
                        deleteRide(ride: ride, completion: { (error) in
                            if let error = error {
                                completion(error, nil)
                            }
                        })
                    } else {
                      rides.append(ride)
                    }
                }
                completion(nil, rides)
            }
        }
    }
    
    static public func fetchPassangerRides(passangerId: String, completion: @escaping(Error?, [Ride]?) -> Void) {
        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).whereField(RideCollectionKeys.passangerId, isEqualTo: passangerId).addSnapshotListener { (snapshot, error) in
            if let error = error {
                completion(error,nil)
            }
            if let snapshot = snapshot {
                var passengerRides = [Ride]()
                for document in snapshot.documents {
                    let passangerRide = Ride.init(dict: document.data())
                    if passangerRide.appointmentDate.stringToDate().dateExpired() {
                        deleteRide(ride: passangerRide, completion: { (error) in
                            if let error = error {
                                completion(error, nil)
                            }
                        })
                    } else {
                        passengerRides.append(passangerRide)
                    }
                }
                completion(nil, passengerRides)
            }
        }
    }
    
    static public func deleteRide(ride: Ride, completion: @escaping(Error?) -> Void) {
        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).document(ride.rideId).delete { (error) in
            if let error = error {
                completion(error)
            }
        }
    }
    
    static public func updateRideToAccepted(ride: Ride, completion: @escaping (Error?) -> Void) {
       let currentUser = DBService.currentManoUser!
        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).document(ride.rideId).updateData([RideCollectionKeys.acceptedKey : true , RideCollectionKeys.accptedByKey : DBService.currentManoUser.userId,
                                                                                                             RideCollectionKeys.acceptenceWasSeenKey : false,
                                                                                                             RideCollectionKeys.driverNameKey : currentUser.fullName, RideCollectionKeys.driverProfileImageKey : currentUser.profileImage!,RideCollectionKeys.driverMakerModelKey : currentUser.carMakerModel!, RideCollectionKeys.licencePlateKey : currentUser.licencePlate!, RideCollectionKeys.carPictureKey : currentUser.carPicture!, RideCollectionKeys.driverCellKey : currentUser.cellPhone!,
                                                                                                             RideCollectionKeys.driverIdKey: currentUser.userId]) { (error) in
            if let error = error {
                completion(error)
            }
        }
    }
    static public func updateRideToSeen(ride: Ride, completion: @escaping(Error?) -> Void) {
        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).document(ride.rideId).updateData([RideCollectionKeys.acceptenceWasSeenKey : true]) { (error) in
            if let error = error {
                completion(error)
            }
        }
    }
    
    static func fetchDriverAcceptedRides(driverId: String, completion: @escaping(Error?, [Ride]?) -> Void) { DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).whereField(RideCollectionKeys.accptedByKey, isEqualTo: driverId).addSnapshotListener { (snapshot, error) in
            if let error = error {
                completion(error,nil)
            }
            if let snapshot = snapshot {
                let ridesAccepted = snapshot.documents.map{Ride.init(dict: $0.data())}
                completion(nil, ridesAccepted)
            }
        }
    }
    
    static func listenForRideAcceptence(passangerId: String, completion: @escaping(Error?, Ride?) -> Void) {
        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).whereField(RideCollectionKeys.acceptedKey, isEqualTo: true).whereField(RideCollectionKeys.passangerId, isEqualTo: passangerId).whereField(RideCollectionKeys.acceptenceWasSeenKey, isEqualTo: false).addSnapshotListener { (snapshot, error) in
            if let error = error {
                completion(error,nil)
            }
            if let snapshot = snapshot {
                let rideAccepted = snapshot.documents.map{Ride.init(dict: $0.data())}
                completion(nil, rideAccepted.first)
            }
        }
    }
    
    static public func updateDriverOntItsWay(ride: Ride, originLat: Double, originLon: Double, pickup: Bool, completion: @escaping(Error?) -> Void) {
        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).document(ride.rideId).updateData([RideCollectionKeys.driverOnItsWayKey : true, RideCollectionKeys.originLatKey : originLat, RideCollectionKeys.originLonKey : originLon, RideCollectionKeys.passangerKnowsDriverOnItsWayKey : false,
                                                                                                             RideCollectionKeys.pickupKey : pickup]) { (error) in
            if let error = error {
                completion(error)
            }
        }
    }
    
//    static public func updateRideToDropoff(ride: Ride, completion: @escaping (Error?) -> Void) {
//        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).document(ride.rideId).updateData([RideCollectionKeys.dropoffKey : true, RideCollectionKeys.pickupKey : false]) { (error) in
//            if let error = error {
//                completion(error)
//            } else {
//                completion(nil)
//            }
//        }
//    }
    
//    static public func listenToDropoff(ride: Ride, completion: @escaping(Error?, Ride?) -> Void) {
//        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).whereField(RideCollectionKeys.rideIdKey, isEqualTo: ride.rideId).whereField(RideCollectionKeys.dropoffKey, isEqualTo: true).addSnapshotListener { (snapshot, error) in
//            if let error = error {
//                completion(error, nil)
//            }
//            if let snapshot = snapshot{
//                let rideAccepted = snapshot.documents.map{Ride.init(dict: $0.data())}
//                completion(nil, rideAccepted.first)
//            }
//            
//        }
//    }
    
//    static public func updateToWaitingForRequest(ride: Ride, completion: @escaping(Error?) -> Void) {
//        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).document(ride.rideId).updateData([RideCollectionKeys.waitingForRequestKey : true, RideCollectionKeys.dropoffKey : false]) { (error) in
//            if let error = error {
//                completion(error)
//            } else {
//                completion(nil)
//            }
//        }
//    }
//
//    static public func listenToWaitingForRequest(ride: Ride, completion: @escaping(Error?, Ride?) -> Void) {
//        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).whereField(RideCollectionKeys.rideIdKey, isEqualTo: ride.rideId).whereField(RideCollectionKeys.waitingForRequestKey, isEqualTo: true).addSnapshotListener { (snapshot, error) in
//            if let error = error {
//                completion(error, nil)
//            }
//            if let snapshot = snapshot{
//                let rideAccepted = snapshot.documents.map{Ride.init(dict: $0.data())}
//                completion(nil, rideAccepted.first)
//            }
//
//        }
//    }

    static public func updateRideStatus(ride: Ride, status: String, completion: @escaping(Error?) -> Void) {
        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).document(ride.rideId).updateData([RideCollectionKeys.rideStatusKey : status]) { (error) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    static public func listenForRideStatus(ride: Ride, status: String, completion: @escaping(Error?, Ride?) -> Void) {
        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).whereField(RideCollectionKeys.rideIdKey, isEqualTo: ride.rideId).whereField(RideCollectionKeys.rideStatusKey, isEqualTo: status).addSnapshotListener { (snapshot, error) in
            if let error = error {
                completion(error, nil)
            }
            if let snapshot = snapshot{
                let rideAccepted = snapshot.documents.map{Ride.init(dict: $0.data())}
                completion(nil, rideAccepted.first)
            }
            
        }
    }
    
//    static public func listenToChangeToPickUp(ride: Ride, completion: @escaping(Error?, Ride?) -> Void) {
//        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).whereField(RideCollectionKeys.rideIdKey, isEqualTo: ride.rideId).whereField(RideCollectionKeys.rideStatusKey, isEqualTo: RideStatus.changedToPickup.rawValue).addSnapshotListener { (snapshot, error) in
//            if let error = error {
//                completion(error, nil)
//            }
//            if let snapshot = snapshot{
//                let rideAccepted = snapshot.documents.map{Ride.init(dict: $0.data())}
//                completion(nil, rideAccepted.first)
//            }
//
//        }
//    }
    
//    static public func listenToChangeToDropoff(ride: Ride, completion: @escaping(Error?, Ride?) -> Void) {
//        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).whereField(RideCollectionKeys.rideIdKey, isEqualTo: ride.rideId).whereField(RideCollectionKeys.rideStatusKey, isEqualTo: RideStatus.changedToDropoff.rawValue).addSnapshotListener { (snapshot, error) in
//            if let error = error {
//                completion(error, nil)
//            }
//            if let snapshot = snapshot{
//                let rideAccepted = snapshot.documents.map{Ride.init(dict: $0.data())}
//                completion(nil, rideAccepted.first)
//            }
//
//        }
//    }
//
//    static public func listenToChangeToWaitingForRequest(ride: Ride, completion: @escaping(Error?, Ride?) -> Void) {
//        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).whereField(RideCollectionKeys.rideIdKey, isEqualTo: ride.rideId).whereField(RideCollectionKeys.rideStatusKey, isEqualTo: RideStatus.changeToWaitingRequest.rawValue).addSnapshotListener { (snapshot, error) in
//            if let error = error {
//                completion(error, nil)
//            }
//            if let snapshot = snapshot{
//                let rideAccepted = snapshot.documents.map{Ride.init(dict: $0.data())}
//                completion(nil, rideAccepted.first)
//            }
//
//        }
//    }
    

    static public func updatePassangerKnowsDriverOnItsWay(ride: Ride, completion: @escaping(Error?) -> Void) {
        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).document(ride.rideId).updateData([RideCollectionKeys.passangerKnowsDriverOnItsWayKey : true]) { (error) in
            if let error = error {
                completion(error)
            }
        }
    }
    static public func updateRideDurationDistance(ride: Ride, distance: Double, duration: Double, completion: @escaping(Error?) -> Void) {
        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).document(ride.rideId).updateData([RideCollectionKeys.durationKey : duration, RideCollectionKeys.distanceKey : distance]) { (error) in
            if let error = error {
                completion(error)
            }
        }
    }
    
    static public func listenForDriverOnItsWay(completion: @escaping(Error?, Ride?) -> Void) {
         DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).whereField(RideCollectionKeys.passangerId, isEqualTo: DBService.currentManoUser.userId).whereField(RideCollectionKeys.driverOnItsWayKey, isEqualTo: true).whereField(RideCollectionKeys.passangerKnowsDriverOnItsWayKey, isEqualTo: false).addSnapshotListener { (snapshot, error) in
            if let error = error {
                completion(error,nil)
            }
            if let snapshot = snapshot {
                let driverOnItsWay = snapshot.documents.map{Ride.init(dict: $0.data())}
                completion(nil, driverOnItsWay.first)
            }
        }
    }
    
    static public func getRideStatusInProgressDriver(completion: @escaping(Error?, Ride?) -> Void) {
        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).whereField(RideCollectionKeys.driverIdKey, isEqualTo: DBService.currentManoUser.userId).whereField(RideCollectionKeys.driverOnItsWayKey, isEqualTo: true).getDocuments { (snapshot, error) in
            if let error = error {
                completion(error,nil)
            }
            if let snapshot = snapshot {
                let ride = snapshot.documents.map{Ride.init(dict: $0.data())}.first
                completion(nil, ride)
            }
        }
    }
    
    static public func getRideStatusInProgressPassenger(completion: @escaping(Error?, Ride?) -> Void) {
        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).whereField(RideCollectionKeys.passangerId, isEqualTo: DBService.currentManoUser.userId).whereField(RideCollectionKeys.driverOnItsWayKey, isEqualTo: true).getDocuments { (snapshot, error) in
            if let error = error {
                completion(error,nil)
            }
            if let snapshot = snapshot {
                let ride = snapshot.documents.map{Ride.init(dict: $0.data())}.first
                completion(nil, ride)
            }
        }
    }
    
    static public func updateDistanceAndDuration(ride: Ride, duration: Int, distance: Double, completion: @escaping(Error?) -> Void) {
        firestoreDB.collection(RideCollectionKeys.collectionKey).document(ride.rideId).updateData([RideCollectionKeys.distanceKey : distance, RideCollectionKeys.durationKey : duration]) { (error) in
            if let error = error {
                completion(error)
            }
        }
    }
    
    static public func listenForDistanceDurationUpdates(ride: Ride, completion: @escaping(Error?, Ride?) -> Void) {
        DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).whereField(RideCollectionKeys.rideIdKey, isEqualTo: ride.rideId).addSnapshotListener({ (snapshot, error) in
            if let error = error {
                completion(error,nil)
            }
            if let snapshot = snapshot {
                let driverOnItsWay = snapshot.documents.map{Ride.init(dict: $0.data())}
                completion(nil, driverOnItsWay.first)
            }
        })
    }
    
    static public func updateToNewRide(pickupAddress: String, pickupLat: Double, pickupLon: Double, dropoffAddress: String, dropoffLat: Double, dropoffLon: Double, rideStatus: String, ride: Ride, completion: @escaping(Error?, Ride?) -> Void) {
        firestoreDB.collection(RideCollectionKeys.collectionKey).document(ride.rideId).updateData([RideCollectionKeys.pickupAddressKey : pickupAddress, RideCollectionKeys.pickupLatKey : pickupLat, RideCollectionKeys.pickupLonKey : pickupLon, RideCollectionKeys.dropoffAddressKey : dropoffAddress, RideCollectionKeys.dropoffLonKey : dropoffLon, RideCollectionKeys.dropoffLatKey : dropoffLat,
                                                                            RideCollectionKeys.rideStatusKey : rideStatus]) { (error) in
            if let error = error {
                completion(error, nil)
            } else {
                fetchForRide(ride: ride, completion: { (error, ride) in
                    if let error = error {
                        completion(error, nil)
                    }
                    if let ride = ride {
                        completion(nil, ride)
                    }
                })
                
            }
        }
    }
    
    static func fetchForRide(ride: Ride, completion: @escaping(Error? , Ride?) -> Void) {
        firestoreDB.collection(RideCollectionKeys.collectionKey).whereField(RideCollectionKeys.rideIdKey, isEqualTo: ride.rideId).getDocuments { (snapshot, error) in
            if let snapshot = snapshot?.documents.first {
                let ride = Ride.init(dict: snapshot.data())
                completion(nil, ride)
            }
            
            if let error = error {
                completion(error, nil)
            }
        }
        
    }
}

