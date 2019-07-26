//
//  DBService+ManoUser.swift
//  Mano
//
//  Created by Leandro Wauters on 7/17/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase

extension DBService {
    
    static public var currentManoUser: ManoUser!
    
    static public func createUser(manoUser: ManoUser, completion: @escaping (Error?) -> Void) {
        DBService.firestoreDB.collection(ManoUserCollectionKeys.collectionKey).document(manoUser.userId).setData(
            [ManoUserCollectionKeys.firstNameKey : manoUser.firstName,
             ManoUserCollectionKeys.lastNameKey : manoUser.lastName,
             ManoUserCollectionKeys.fullNameKey : manoUser.fullName,
             ManoUserCollectionKeys.typeOfUserKey : manoUser.typeOfUser,
             ManoUserCollectionKeys.userIdKey : manoUser.userId
            
             
        ]) { (error) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    static public func updateBio(userId: String, bioText: String, completion: @escaping (Error?) -> Void) {
        DBService.firestoreDB.collection(ManoUserCollectionKeys.collectionKey).document(userId).updateData([ManoUserCollectionKeys.bioKey : bioText]) { (error) in
            if let error = error {
                completion(error)
            } else {
                print("Bio updated")
            }
        }
    }
    static public func updateDriverMoreInfo(userID: String, profileImage: String?, homeAddress: String, homeLat: Double, homeLon: Double, carMakerModel: String, licencePlate: String, carPhoto: String, completion: @escaping(Error?) -> Void) {
        DBService.firestoreDB.collection(ManoUserCollectionKeys.collectionKey).document(userID).updateData([
            
            ManoUserCollectionKeys.homeAddressKey : homeAddress,
            ManoUserCollectionKeys.homeLatKey : homeLat,
            ManoUserCollectionKeys.homeLonKey : homeLon,
            ManoUserCollectionKeys.profileImageKey : profileImage!,
            ManoUserCollectionKeys.carMakerModelKey : carMakerModel,
            ManoUserCollectionKeys.licencePlateKey : licencePlate,
            ManoUserCollectionKeys.carPictureKey: carPhoto]) { (error) in
                completion(error)
        }
        
    }
    static public func updatePassangerMoreInfo(userID: String, homeAddress: String, homeLat: Double, homeLon: Double, completion: @escaping(Error?) -> Void) {
        DBService.firestoreDB.collection(ManoUserCollectionKeys.collectionKey).document(userID).updateData([
            
            ManoUserCollectionKeys.homeAddressKey : homeAddress,
            ManoUserCollectionKeys.homeLonKey : homeLon,
            ManoUserCollectionKeys.homeLatKey : homeLat]) { (error) in
                completion(error)
        }
        
    }
    static public func fetchManoUser(userId: String, completion: @escaping (Error?, ManoUser?) -> Void) {
        DBService.firestoreDB
            .collection(ManoUserCollectionKeys.collectionKey)
            .whereField(ManoUserCollectionKeys.userIdKey, isEqualTo: userId)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completion(error, nil)
                } else if let snapshot = snapshot?.documents.first {
                    let manoUser = ManoUser.init(dict: snapshot.data())
                    completion(nil, manoUser)
                }
        }
    }
    
    static public func deleteAccount(user: ManoUser, completion: @escaping (Error?) -> Void) {
        DBService.firestoreDB
            .collection(ManoUserCollectionKeys.collectionKey)
            .document(user.userId)
            .delete { (error) in
                if let error = error {
                    completion(error)
                } else {
                    completion(nil)
                }
        }
    }
}

