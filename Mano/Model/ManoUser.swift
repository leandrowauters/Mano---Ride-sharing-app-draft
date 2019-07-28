//
//  ManoUser.swift
//  Mano
//
//  Created by Leandro Wauters on 7/17/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import Foundation

class ManoUser: Codable {
    var firstName: String
    var lastName: String
    var fullName: String
    var homeAdress: String?
    var homeLat: Double?
    var homeLon: Double?
    var profileImage: String?
    var carMakerModel: String?
    var bio: String?
    var typeOfUser: String //ENUM TYPE OF USER
    var patients: [String]?
    var joinedDate: String
    var userId: String
    var myRides: [String]?
    var myPickUps: [String]?
    var licencePlate: String?
    var carPicture: String?
    var cellPhone: String?
    
    init(firstName: String, lastName: String, fullName: String, homeAdress: String?,homeLat: Double?,homeLon: Double?, profileImage: String?, carMakerModel: String?, bio: String?, typeOfUser: String, patients: [String]?, joinedDate: String, userId: String, myRides: [String]?, myPickUps: [String]?, licencePlate: String?, carPicture: String?,cellPhone: String?) {
        self.firstName = firstName
        self.lastName = lastName
        self.fullName = fullName
        self.homeAdress = homeAdress
        self.profileImage = profileImage
        self.homeLat = homeLat
        self.homeLon = homeLon
        self.carMakerModel = carMakerModel
        self.bio = bio
        self.typeOfUser = typeOfUser
        self.patients = patients
        self.joinedDate = joinedDate
        self.userId = userId
        self.myRides = myRides
        self.myPickUps = myPickUps
        self.licencePlate = licencePlate
        self.carPicture = carPicture
        self.cellPhone = cellPhone
    }
    
    init(dict: [String: Any]) {
        self.firstName = dict[ManoUserCollectionKeys.firstNameKey] as? String ?? ""
        self.lastName = dict[ManoUserCollectionKeys.lastNameKey] as? String ?? ""
        self.fullName = dict[ManoUserCollectionKeys.fullNameKey] as? String ?? ""
        self.homeAdress = dict[ManoUserCollectionKeys.homeAddressKey] as? String ?? ""
        self.homeLon = dict[ManoUserCollectionKeys.homeLonKey] as? Double ?? 0.0
        self.homeLat = dict[ManoUserCollectionKeys.homeLatKey] as? Double ?? 0.0
        self.profileImage = dict[ManoUserCollectionKeys.profileImageKey] as? String ?? ""
        self.carMakerModel = dict[ManoUserCollectionKeys.carMakerModelKey] as? String
        self.bio = dict[ManoUserCollectionKeys.bioKey] as? String ?? ""
        self.typeOfUser = dict[ManoUserCollectionKeys.typeOfUserKey] as? String ?? ""
        self.patients = dict[ManoUserCollectionKeys.patientsKey] as? [String] ?? [""]
        self.joinedDate = dict[ManoUserCollectionKeys.joinedDateKey] as? String ?? ""
        self.userId = dict[ManoUserCollectionKeys.userIdKey] as? String ?? ""
        self.myRides = dict[ManoUserCollectionKeys.myRidesKey] as? [String] ?? [""]
        self.myPickUps = dict[ManoUserCollectionKeys.myPickUpsKey] as? [String] ?? [""]
        self.licencePlate = dict[ManoUserCollectionKeys.licencePlateKey] as? String ?? ""
        self.carPicture = dict[ManoUserCollectionKeys.carPictureKey] as? String ?? ""
        self.cellPhone = dict[ManoUserCollectionKeys.cellPhoneKey] as? String ?? ""
    }
    
}
