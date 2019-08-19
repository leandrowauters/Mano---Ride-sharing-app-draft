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
    static let regularsKey = "regulars"
    static let joinedDateKey = "joinedDate"
    static let userIdKey = "userId"
    static let numberOfRides = "numberOfRides"
    static let numberOfMiles = "numberOfMiles"
    static let licencePlateKey = "licencePlate"
    static let carPictureKey = "carPicture"
    static let cellPhoneKey = "cellPhone"
    static let ridesKey = "rides"
}

struct RideCollectionKeys {
    static let collectionKey = "Ride"
    static let rideIdKey = "rideId"
    static let passangerName = "passangerName"
    static let passangerId = "passangerId"
    static let pickupAddressKey = "pickupAddress"
    static let dropoffAddressKey = "dropoffAddress"
    static let dropoffNameKey = "dropoffName"
    static let appoinmentDateKey = "appointmentDate"
    static let pickupLatKey = "pickupLat"
    static let pickupLonKey = "pickupLon"
    static let dropoffLatKey = "dropoffLat"
    static let dropoffLonKey = "dropoffLon"
    static let acceptenceWasSeenKey = "acceptenceWasSeen"
    static let inProgressKey = "inProgress"
    static let durationKey = "duration"
    static let distanceKey = "distance"
    static let dateRequestedKey = "dateRequested"
    static let driverNameKey = "driverName"
    static let driverIdKey = "driverId"
    static let driverProfileImageKey = "driveProfileImage"
    static let driverMakerModelKey = "driverMakerModel"
    static let originLatKey = "originLat"
    static let originLonKey = "originLon"
    static let licencePlateKey = "licencePlate"
    static let carPictureKey = "carPicture"
    static let passangerKnowsDriverOnItsWayKey = "passangerKnowsDriverOnItsWay"
    static let passangerCellKey = "passangerCell"
    static let driverCellKey = "driverCell"
    static let waitingForRequestKey = "waitingForRequest"
    static let rideStatusKey = "rideStatus"
    static let totalMilesKey = "totalMiles"
}

struct MyLocationsCollectionKeys {
    static let collectionKey = "UserSavedLocations"
    static let userIdKey = "userId"
    static let locationNameKey = "locationName"
    static let locationAddress = "locationAddress"
    static let locationIdKey = "locationId"
}

struct MessageCollectionKeys {
    static let collectionKey = "Messages"
    static let senderKey = "sender"
    static let recipientKey = "recipient"
    static let senderIdKey = "senderId"
    static let recipientIdKey = "recipientId"
    static let messageKey = "message"
    static let messageIdKey = "messageId"
    static let messageDateKey = "messageDate"
    static let readKey = "read"
}



