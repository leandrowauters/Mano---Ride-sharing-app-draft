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
    
    init(passanger: String, passangerId: String, rideId: String, pickupAddress: String,pickupLat: Double, pickupLon: Double, dropoffLat: Double, dropoffLon: Double ,dropoffAddress: String, appointmentDate: String) {
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
    }
}
