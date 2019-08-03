//
//  Date+Extentions.swift
//  Mano
//
//  Created by Leandro Wauters on 7/17/19.
//  Copyright © 2019 Leandro Wauters. All rights reserved.
//

import Foundation

extension Date {
    static func getISOTimestamp() -> String {
        let isoDateFormatter = ISO8601DateFormatter()
        let timestamp = isoDateFormatter.string(from: Date())
        return timestamp
    }
    var dateDescription: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a yyyy"
        dateFormatter.locale = .current
        return dateFormatter.string(from: self)
    }
    func isInSameWeek() -> Bool {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: self).day
        if let days = days {
            if days < 7 && !isTodayOrTomorrow(){
                return true
            }
        }
        return false
    }
    func isTodayOrTomorrow()  -> Bool {
        return Calendar.current.isDateInToday(self) || Calendar.current.isDateInTomorrow(self)
    }
    
    func dayWasYesterday() -> Bool{
        return Calendar.current.isDateInYesterday(self)
    }
    func isNew() -> Bool {
        let minutes = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute
        if let minutes = minutes {
            if minutes < 60 {
                return true
            }
        }
        return false
    }
    
    func isOther() -> Bool {
        return !isTodayOrTomorrow() && !isInSameWeek()
    }
}


