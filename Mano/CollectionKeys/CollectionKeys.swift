//
//  CollectionKeys.swift
//  Mano
//
//  Created by Leandro Wauters on 7/17/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import Foundation

struct ManoUserCollectionKeys {
    static let collectionKey = "ManoUser"
    static let firstNameKey = "firstName"
    static let lastNameKey = "lastName"
    static let fullNameKey = "fullName"
    static let homeAddressKey = "homeAddress"
    static let homeLatKey = "homeLat"
    static let homeLonKey = "homeLon"
    static let profileImageKey = "profileImage"
    static let carMakerModelKey = "carMakerModel"
    static let bioKey = "bio"
    static let typeOfUserKey = "typeOfUser"
    static let patientsKey = "patients"
    static let joinedDateKey = "joinedDate"
    static let userIdKey = "userId"
    static let myRidesKey = "myRides"
    static let myPickUpsKey = "myPickUps"
}

struct RideCollectionKeys {
    static let collectionKey = "Ride"
    static let rideIdKey = "rideId"
    static let passangerName = "passangerName"
    static let passangerId = "passangerId"
    static let pickupAddressKey = "pickupAddress"
    static let dropoffAddressKey = "dropoffAddress"
    static let appoinmentDateKey = "appointmentDate"
    static let pickupLatKey = "pickupLat"
    static let pickupLonKey = "pickupLon"
    static let dropoffLatKey = "dropoffLat"
    static let dropoffLonKey = "dropoffLon"
    static let acceptedKey = "accepted"
    static let accptedByKey = "accptedBy"
    static let acceptenceWasSeenKey = "acceptenceWasSeen"
}

struct MyLocationsCollectionKeys {
    static let collectionKey = "UserSavedLocations"
    static let userIdKey = "userId"
    static let locationNameKey = "locationName"
    static let locationAddress = "locationAddress"
    static let locationIdKey = "locationId"
}

