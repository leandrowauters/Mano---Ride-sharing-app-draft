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
    var regulars: [String]?
    var joinedDate: String
    var userId: String
    var numberOfRides: Int?
    var numberOfMiles: Double?
    var licencePlate: String?
    var carPicture: String?
    var cellPhone: String?
    var rides: [String]?
    
    init(firstName: String, lastName: String, fullName: String, homeAdress: String?,homeLat: Double?,homeLon: Double?, profileImage: String?, carMakerModel: String?, bio: String?, typeOfUser: String, regulars: [String]?, joinedDate: String, userId: String, numberOfRides: Int?, numberOfMiles: Double?, licencePlate: String?, carPicture: String?,cellPhone: String?, rides: [String]?) {
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
        self.regulars = regulars
        self.joinedDate = joinedDate
        self.userId = userId
        self.numberOfRides = numberOfRides
        self.numberOfMiles = numberOfMiles
        self.licencePlate = licencePlate
        self.carPicture = carPicture
        self.cellPhone = cellPhone
        self.rides = rides
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
        self.regulars = dict[ManoUserCollectionKeys.regularsKey] as? [String]
        self.joinedDate = dict[ManoUserCollectionKeys.joinedDateKey] as? String ?? ""
        self.userId = dict[ManoUserCollectionKeys.userIdKey] as? String ?? ""
        self.numberOfRides = dict[ManoUserCollectionKeys.numberOfRides] as? Int ?? 0
        self.numberOfMiles = dict[ManoUserCollectionKeys.numberOfMiles] as? Double ?? 0.0
        self.licencePlate = dict[ManoUserCollectionKeys.licencePlateKey] as? String ?? ""
        self.carPicture = dict[ManoUserCollectionKeys.carPictureKey] as? String ?? ""
        self.cellPhone = dict[ManoUserCollectionKeys.cellPhoneKey] as? String ?? ""
        self.rides = dict[ManoUserCollectionKeys.ridesKey] as? [String]
    }
    
}
