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
    var dropoffName: String
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
    var durtation: Int
    var distance: Double
    var dateRequested: String
    var driverName: String
    var driverId: String
    var driveProfileImage: String
    var driverMakerModel: String
    var originLat: Double
    var originLon: Double
    var licencePlate: String
    var carPicture: String
    var passangerKnowsDriverOnItsWay: Bool
    var passangerCell: String
    var driverCell: String
    var pickup: Bool
    var dropoff: Bool
    
    init(passanger: String, passangerId: String, rideId: String, pickupAddress: String,pickupLat: Double, pickupLon: Double, dropoffLat: Double, dropoffLon: Double ,dropoffAddress: String, dropoffName: String, appointmentDate: String,accepted: Bool,accptedBy: String,acceptenceWasSeen: Bool,driverOnItsWay: Bool, duration: Int, distance: Double, dateRequested: String, driverName: String, driverId: String, driveProfileImage: String, driverMakerModel: String, originLat: Double, originLon: Double, licencePlate: String, carPicture: String, passangerKnowsDriverOnItsWay: Bool, passangerCell: String, driverCell: String, pickup: Bool, dropoff: Bool) {
        self.passanger = passanger
        self.passangerId = passangerId
        self.rideId = rideId
        self.pickupAddress = pickupAddress
        self.dropoffAddress = dropoffAddress
        self.dropoffName = dropoffName
        self.appointmentDate = appointmentDate
        self.pickupLat = pickupLat
        self.pickupLon = pickupLon
        self.dropoffLat = dropoffLat
        self.dropoffLon = dropoffLon
        self.accepted = accepted
        self.accptedBy = accptedBy
        self.acceptenceWasSeen = acceptenceWasSeen
        self.driverOnItsWay = driverOnItsWay
        self.durtation = duration
        self.distance = distance
        self.dateRequested = dateRequested
        self.driverName = driverName
        self.driverId = driverId
        self.driveProfileImage = driveProfileImage
        self.driverMakerModel = driverMakerModel
        self.originLat = originLat
        self.originLon = originLon
        self.licencePlate = licencePlate
        self.carPicture = carPicture
        self.passangerKnowsDriverOnItsWay = passangerKnowsDriverOnItsWay
        self.passangerCell = passangerCell
        self.driverCell = driverCell
        self.pickup = pickup
        self.dropoff = dropoff
    }
    
    init(dict: [String: Any]) {
        self.passanger = dict[RideCollectionKeys.passangerName] as? String ?? ""
        self.passangerId = dict[RideCollectionKeys.passangerId] as? String ?? ""
        self.rideId = dict[RideCollectionKeys.rideIdKey] as? String ?? ""
        self.pickupAddress = dict[RideCollectionKeys.pickupAddressKey] as? String ?? ""
        self.dropoffAddress = dict[RideCollectionKeys.dropoffAddressKey] as? String ?? ""
        self.dropoffName = dict[RideCollectionKeys.dropoffNameKey] as? String ?? ""
        self.appointmentDate = dict[RideCollectionKeys.appoinmentDateKey] as? String ?? ""
        self.pickupLat = dict[RideCollectionKeys.pickupLatKey] as? Double ?? 0.0
        self.pickupLon = dict[RideCollectionKeys.pickupLonKey] as? Double ?? 0.0
        self.dropoffLat = dict[RideCollectionKeys.dropoffLatKey] as? Double ?? 0.0
        self.dropoffLon = dict[RideCollectionKeys.dropoffLonKey] as? Double ?? 0.0
        self.accepted = dict[RideCollectionKeys.acceptedKey] as? Bool ?? false
        self.accptedBy = dict[RideCollectionKeys.accptedByKey] as? String ?? ""
        self.acceptenceWasSeen = dict[RideCollectionKeys.acceptenceWasSeenKey] as? Bool ?? false
        self.driverOnItsWay = dict[RideCollectionKeys.driverOnItsWayKey] as? Bool ?? false
        self.durtation = dict[RideCollectionKeys.durationKey] as? Int ?? 0
        self.distance = dict[RideCollectionKeys.distanceKey] as? Double ?? 0.0
        self.dateRequested = dict[RideCollectionKeys.dateRequestedKey] as? String ?? ""
        self.driverName = dict[RideCollectionKeys.driverNameKey] as? String ?? ""
        self.driverId = dict[RideCollectionKeys.driverIdKey] as? String ?? ""
        self.driveProfileImage = dict[RideCollectionKeys.driverProfileImageKey] as? String ?? ""
        self.driverMakerModel = dict[RideCollectionKeys.driverMakerModelKey] as? String ?? ""
        self.originLat = dict[RideCollectionKeys.originLatKey] as? Double ?? 0.0
        self.originLon = dict[RideCollectionKeys.originLonKey] as? Double ?? 00
        self.licencePlate = dict[RideCollectionKeys.licencePlateKey] as? String ?? ""
        self.carPicture = dict[RideCollectionKeys.carPictureKey] as? String ?? ""
        self.passangerKnowsDriverOnItsWay = dict[RideCollectionKeys.passangerKnowsDriverOnItsWayKey] as? Bool ?? false
        self.passangerCell = dict[RideCollectionKeys.passangerCellKey] as? String ?? ""
        self.driverCell = dict[RideCollectionKeys.driverCellKey] as? String ?? ""
        self.pickup = dict[RideCollectionKeys.pickupKey] as? Bool ?? false
        self.dropoff = dict[RideCollectionKeys.dropoffKey] as? Bool ?? false
    }
    
}
