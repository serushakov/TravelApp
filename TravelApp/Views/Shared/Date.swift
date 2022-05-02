//
//  Date.swift
//  TravelApp
//
//  Created by Sergey Ushakov on 2.5.2022.
//

import Foundation

extension Date {
    func isSameDay(as date: Date) -> Bool {
        let diff = Calendar.current.dateComponents([.day], from: self.getDayStart(), to: date.getDayStart())

        return diff.day == 0
    }

    static func getDayStart(for date: Date) -> Date {
        return Calendar.current.startOfDay(for: date)
    }

    func getDayStart() -> Date {
        return Date.getDayStart(for: self)
    }

    static func getDayEnd(for date: Date) -> Date {
        let startOfDay: Date = date.getDayStart()
        let components = DateComponents(hour: 23, minute: 59, second: 59)

        return Calendar.current.date(byAdding: components, to: startOfDay) ?? date
    }

    func getDayEnd() -> Date {
        return Date.getDayEnd(for: self)
    }
}
