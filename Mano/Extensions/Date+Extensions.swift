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
    func isInSameWeek(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .weekOfYear)
    }
}
