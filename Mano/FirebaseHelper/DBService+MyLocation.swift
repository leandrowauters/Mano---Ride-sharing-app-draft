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
}
