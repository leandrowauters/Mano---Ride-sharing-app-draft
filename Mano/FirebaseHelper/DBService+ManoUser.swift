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
    static public func updateDriverMoreInfo(userID: String, profileImage: String?, homeAddress: String, homeLat: Double, homeLon: Double, carMakerModel: String, licencePlate: String, carPhoto: String,cellPhone: String, completion: @escaping(Error?) -> Void) {
        DBService.firestoreDB.collection(ManoUserCollectionKeys.collectionKey).document(userID).updateData([
            
            ManoUserCollectionKeys.homeAddressKey : homeAddress,
            ManoUserCollectionKeys.homeLatKey : homeLat,
            ManoUserCollectionKeys.homeLonKey : homeLon,
            ManoUserCollectionKeys.profileImageKey : profileImage!,
            ManoUserCollectionKeys.carMakerModelKey : carMakerModel,
            ManoUserCollectionKeys.licencePlateKey : licencePlate,
            ManoUserCollectionKeys.carPictureKey: carPhoto, ManoUserCollectionKeys.cellPhoneKey : cellPhone]) { (error) in
                completion(error)
        }
        
    }
    static public func updatePassangerMoreInfo(userID: String, homeAddress: String, homeLat: Double, homeLon: Double, cellPhone: String, completion: @escaping(Error?) -> Void) {
        DBService.firestoreDB.collection(ManoUserCollectionKeys.collectionKey).document(userID).updateData([
            
            ManoUserCollectionKeys.homeAddressKey : homeAddress,
            ManoUserCollectionKeys.homeLonKey : homeLon,
            ManoUserCollectionKeys.homeLatKey : homeLat, ManoUserCollectionKeys.cellPhoneKey : cellPhone]) { (error) in
                completion(error)
        }
        
    }
    
    static public func updateDriverStats(ride: Ride, completion: @escaping(Error?, ManoUser?) -> Void) {
        if let numberOfMiles = currentManoUser.numberOfMiles,
            let numberOfRides = currentManoUser.numberOfRides {
            firestoreDB.collection(ManoUserCollectionKeys.collectionKey).document(currentManoUser.userId).updateData([ManoUserCollectionKeys.numberOfMiles : numberOfMiles + ride.totalMiles, ManoUserCollectionKeys.numberOfRides : numberOfRides + 1]) {(error) in
                if let error = error {
                    completion(error,nil)
                }

            }
        } else {
            firestoreDB.collection(ManoUserCollectionKeys.collectionKey).document(currentManoUser.userId).updateData([ManoUserCollectionKeys.numberOfMiles : ride.totalMiles, ManoUserCollectionKeys.numberOfRides : 1]) { (error) in
                if let error = error {
                    completion(error, nil)
                }
                
            }
        }
        fetchManoUser(userId: currentManoUser.userId, completion: { (error, manoUser) in
            if let error = error {
                completion(error, nil)
            }
            if let manoUser = manoUser {
                completion(nil, manoUser)
            }
        })
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
                } else {
                    completion(nil, nil)
                }
        }
    }
    
    static public func fetchYourRegularUsers(regulars: [String], completion: @escaping(Error?, [ManoUser]?) -> Void) {
        let query = firestoreDB.collection(ManoUserCollectionKeys.collectionKey)
        query.getDocuments { (snapshot, error) in
            if let error = error {
                completion(error, nil)
            }
            if let snapshot = snapshot {
                var yourRegulars = [ManoUser]()
                for document in snapshot.documents {
                    let regular = ManoUser.init(dict: document.data())
                    if regulars.contains(regular.userId) {
                        yourRegulars.append(regular)
                    }
                }
                completion(nil, yourRegulars)
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
    
    static public func addUserToRegulars(regularId: String, completion: @escaping(Error?) -> Void) {
        fetchManoUser(userId: currentManoUser.userId) { (error, manoUser) in
            if let error = error {
                completion(error)
            }
            if let manoUser = manoUser {
                var newRegulars = [String]()
                if let regulars = manoUser.regulars {
                    newRegulars = regulars
                }
                    newRegulars.append(regularId)
                    firestoreDB.collection(ManoUserCollectionKeys.collectionKey).document(manoUser.userId).updateData([ManoUserCollectionKeys.regularsKey : newRegulars], completion: { (error) in
                        if let error = error {
                            completion(error)
                        } else {
                            completion(nil)
                        }
                    })
                
            
            }
        }
    }
    
    static public func listenToUserChanges(completion: @escaping(Error?) -> Void) -> ListenerRegistration {
        return firestoreDB.collection(ManoUserCollectionKeys.collectionKey).document(ManoUserCollectionKeys.userIdKey).addSnapshotListener { (snapshot, error) in
            if let error = error {
                completion(error)
            }
            fetchManoUser(userId: currentManoUser.userId, completion: { (error, manoUser) in
                if let error = error {
                    completion(error)
                }
                if let manoUser = manoUser {
                    DBService.currentManoUser = manoUser
                }
            })
        }
    }
    
    static public func addRideToRides(ride: Ride, completion: @escaping(Error?) -> Void) {
        fetchManoUser(userId: currentManoUser.userId) { (error, manoUser) in
            if let error = error {
                completion(error)
            }
            if let manoUser = manoUser {
                var newRides = [String]()
                if let rides = manoUser.rides {
                    newRides = rides
                }
                newRides.append(ride.rideId)
                firestoreDB.collection(ManoUserCollectionKeys.collectionKey).document(manoUser.userId).updateData([ManoUserCollectionKeys.ridesKey : newRides], completion: { (error) in
                    if let error = error {
                        completion(error)
                    } else {
                        completion(nil)
                    }
                })
            }
        }
    }
}

