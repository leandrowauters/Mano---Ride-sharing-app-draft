//
//  DBService+Ride.swift
//  Mano
//
//  Created by Leandro Wauters on 7/22/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import Foundation

extension DBService {
    
    static public func createARide(date: String, passangerId: String, passangerName: String, pickupAddress: String, dropoffAddress: String, pickupLat: Double, pickupLon: Double, dropoffLat: Double, dropoffLon: Double, completion: @escaping(Error?)-> Void) {
       let ref =  DBService.firestoreDB.collection(RideCollectionKeys.collectionKey).document()
        firestoreDB.collection(RideCollectionKeys.collectionKey).document(ref.documentID).setData([RideCollectionKeys.appoinmentDateKey : date,
                                                                                                   RideCollectionKeys.passangerId : passangerId,
                                                                                                   RideCollectionKeys.rideIdKey : ref.documentID,
                                                                                                   RideCollectionKeys.passangerName : passangerName,
                                                                            RideCollectionKeys.pickupAddressKey : pickupAddress, RideCollectionKeys.dropoffAddressKey : dropoffAddress, RideCollectionKeys.pickupLatKey : pickupLat, RideCollectionKeys.pickupLonKey : pickupLon, RideCollectionKeys.dropoffLonKey :dropoffLon, RideCollectionKeys.dropoffLatKey : dropoffLat
        ]) { (error) in
            if let error = error {
                completion(error)
            }
        }
    }
    
    static public func fetchAllRides(completion: @escaping(Error?, [Ride]?) -> Void) {
        let query = firestoreDB.collection(RideCollectionKeys.collectionKey)
        query.getDocuments { (snapshot, error) in
            if let error = error {
                completion(error, nil)
            }
            if let snapshot = snapshot {
                var rides = [Ride]()
                for document in snapshot.documents {
                    let ride = Ride.init(dict: document.data())
                    rides.append(ride)
                }
                completion(nil, rides)
            }
        }
    }
}

