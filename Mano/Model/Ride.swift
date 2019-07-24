//
//  Ride.swift
//  Mano
//
//  Created by Leandro Wauters on 7/19/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import Foundation

class Ride: Codable {
    var passanger: String
    var passangerId: String
    var rideId: String
    var pickupAddress: String
    var dropoffAddress: String
    var appointmentDate: String
    var pickupLat: Double
    var pickupLon: Double
    var dropoffLat: Double
    var dropoffLon: Double
    var accepted: Bool
    var accptedBy: String
    var acceptenceWasSeen: Bool
    var driverOnItsWay: Bool
    var rideETA: String
    var dateRequested: String
    var driverName: String
    var driveProfileImage: String
    var driverMakerModel: String
    
    init(passanger: String, passangerId: String, rideId: String, pickupAddress: String,pickupLat: Double, pickupLon: Double, dropoffLat: Double, dropoffLon: Double ,dropoffAddress: String, appointmentDate: String,accepted: Bool,accptedBy: String,acceptenceWasSeen: Bool,driverOnItsWay: Bool,rideETA: String, dateRequested: String, driverName: String, driveProfileImage: String, driverMakerModel: String) {
        self.passanger = passanger
        self.passangerId = passangerId
        self.rideId = rideId
        self.pickupAddress = pickupAddress
        self.dropoffAddress = dropoffAddress
        self.appointmentDate = appointmentDate
        self.pickupLat = pickupLat
        self.pickupLon = pickupLon
        self.dropoffLat = dropoffLat
        self.dropoffLon = dropoffLon
        self.accepted = accepted
        self.accptedBy = accptedBy
        self.acceptenceWasSeen = acceptenceWasSeen
        self.driverOnItsWay = driverOnItsWay
        self.rideETA = rideETA
        self.dateRequested = dateRequested
        self.driverName = driverName
        self.driveProfileImage = driveProfileImage
        self.driverMakerModel = driverMakerModel
    }
    
    init(dict: [String: Any]) {
        self.passanger = dict[RideCollectionKeys.passangerName] as? String ?? ""
        self.passangerId = dict[RideCollectionKeys.passangerId] as? String ?? ""
        self.rideId = dict[RideCollectionKeys.rideIdKey] as? String ?? ""
        self.pickupAddress = dict[RideCollectionKeys.pickupAddressKey] as? String ?? ""
        self.dropoffAddress = dict[RideCollectionKeys.dropoffAddressKey] as? String ?? ""
        self.appointmentDate = dict[RideCollectionKeys.appoinmentDateKey] as? String ?? ""
        self.pickupLat = dict[RideCollectionKeys.pickupLatKey] as? Double ?? 0.0
        self.pickupLon = dict[RideCollectionKeys.pickupLonKey] as? Double ?? 0.0
        self.dropoffLat = dict[RideCollectionKeys.dropoffLatKey] as? Double ?? 0.0
        self.dropoffLon = dict[RideCollectionKeys.dropoffLonKey] as? Double ?? 0.0
        self.accepted = dict[RideCollectionKeys.acceptedKey] as? Bool ?? false
        self.accptedBy = dict[RideCollectionKeys.accptedByKey] as? String ?? ""
        self.acceptenceWasSeen = dict[RideCollectionKeys.acceptenceWasSeenKey] as? Bool ?? false
        self.driverOnItsWay = dict[RideCollectionKeys.driverOnItsWayKey] as? Bool ?? false
        self.rideETA = dict[RideCollectionKeys.rideETAKey] as? String ?? ""
        self.dateRequested = dict[RideCollectionKeys.dateRequestedKey] as? String ?? ""
        self.driverName = dict[RideCollectionKeys.driverNameKey] as? String ?? ""
        self.driveProfileImage = dict[RideCollectionKeys.driverProfileImageKey] as? String ?? ""
        self.driverMakerModel = dict[RideCollectionKeys.driverMakerModelKey] as? String ?? ""
    }
    
}
