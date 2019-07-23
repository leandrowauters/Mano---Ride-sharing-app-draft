//
//  DBService+MyLocation.swift
//  Mano
//
//  Created by Leandro Wauters on 7/23/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import Foundation

extension DBService {
    
    static public func createMyLocation(myLocation: MyLocation , completion: @escaping(Error?) -> Void) {
        DBService.firestoreDB.collection(MyLocationsCollectionKeys.collectionKey).document(myLocation.locationId).setData([MyLocationsCollectionKeys.locationAddress : myLocation.address, MyLocationsCollectionKeys.userIdKey : myLocation.userId, MyLocationsCollectionKeys.locationIdKey: myLocation.locationId, MyLocationsCollectionKeys.locationNameKey : myLocation.locationName]) { (error) in
            if let error = error {
                completion(error)
            }
        }
    }
    
    static public func fetchUserMyLocations(userId: String, completion: @escaping (Error?, [MyLocation]?) -> Void) {
        DBService.firestoreDB
            .collection(MyLocationsCollectionKeys.collectionKey)
            .whereField(ManoUserCollectionKeys.userIdKey, isEqualTo: userId)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completion(error, nil)
                } else if let snapshot = snapshot {
                     let myLocations = snapshot.documents.map{MyLocation.init(dict: $0.data())}
                    completion(nil, myLocations)
                }
        }
    }
}
