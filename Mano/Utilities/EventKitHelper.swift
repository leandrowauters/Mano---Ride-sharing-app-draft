//
//  EventKitHelper.swift
//  Mano
//
//  Created by Leandro Wauters on 8/3/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import Foundation
import EventKit

class EventKitHelper {
    static let shared = EventKitHelper()
    public func addToCalendar(ride: Ride, completion: @escaping(AppError?, String?) -> Void) {
        let eventStore = EKEventStore()
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            insertEvent(store: eventStore, ride: ride) { (error, calendar) in
                completion(error,calendar)
            }
            
        case .denied:
            print("Access denied")
        case .notDetermined:
            // 3
            eventStore.requestAccess(to: .event, completion:
                {[weak self] (granted: Bool, error: Error?) -> Void in
                    if let error = error {
                      completion(.calendarError(error.localizedDescription), nil)
                    }
                    if granted {
                        self!.insertEvent(store: eventStore, ride: ride, completion: { (error, calendar) in
                            completion(nil, calendar)
                        })
                        
                    }
            })
        default:
            print("Case default")
        }
    }
    
    func insertEvent(store: EKEventStore, ride: Ride, completion: (AppError?, String?) -> Void) {
        // 1
        guard let calendar = store.defaultCalendarForNewEvents else {
            completion(.calendarError("No calendar found"), nil)
            return
        }
        let event = EKEvent(eventStore: store)
        let alarm30MinutesBefore = EKAlarm(relativeOffset: -1800)
        let alarm1DayBefore = EKAlarm(relativeOffset: -86400)
        
            // 2
                // 3
        let startDate = ride.appointmentDate.stringToDate()
        let endDate = Date(timeInterval: 7200, since: startDate)
        if DBService.currentManoUser.typeOfUser == TypeOfUser.Driver.rawValue {
            event.title = ride.passanger
            event.location = ride.pickupAddress
        } else {
            event.title = ride.dropoffName
            event.location = ride.dropoffAddress
            event.notes = "Driver: \(ride.driverName)"
        }
        let predicate = store.predicateForEvents(withStart: startDate, end: endDate, calendars: store.calendars(for: .event))
        for eventCreated in store.events(matching: predicate) {
            guard eventCreated.title != event.title else {
                completion(.calendarError("Event already in calendar"), nil)
                return}
        }
        event.addAlarm(alarm30MinutesBefore)
        event.addAlarm(alarm1DayBefore)
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = calendar


        do {
            try store.save(event, span: .thisEvent)
            completion(nil, calendar.title)
        }
        catch {
            completion(.calendarError("Error saving event in calendar"), nil)
            print("Error saving event in calendar")
            
        }       // 4



                // 5

            
        
    }
}
