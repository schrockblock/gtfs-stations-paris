//
//  DateRelativeTime.swift
//  GTFSStationsParis
//
//  Created by Elliot Schrock on 7/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

extension Date {
    public func isBefore(_ date: Date) -> Bool {
        return self.compare(date) == .orderedAscending
    }
    
    public func isAfter(_ date: Date) -> Bool {
        return self.compare(date) == .orderedDescending
    }
    
    public func increment(_ unit: NSCalendar.Unit, amount: Int) -> Date? {
        var calendar = Calendar.autoupdatingCurrent
        calendar.locale = Locale(identifier: "en-US")
        
        var components = DateComponents()
        
        switch unit {
        case NSCalendar.Unit.year:
            components.year = amount
            break
        case NSCalendar.Unit.weekOfYear:
            components.weekOfYear = amount
            break
        case NSCalendar.Unit.month:
            components.month = amount
            break
        case NSCalendar.Unit.day:
            components.day = amount
            break
        case NSCalendar.Unit.hour:
            components.hour = amount
            break
        case NSCalendar.Unit.minute:
            components.minute = amount
            break
        case NSCalendar.Unit.second:
            components.second = amount
            break
        case NSCalendar.Unit.era:
            components.era = amount
            break
        case NSCalendar.Unit.quarter:
            components.quarter = amount
            break
        case NSCalendar.Unit.weekdayOrdinal:
            components.weekdayOrdinal = amount
            break
        case NSCalendar.Unit.yearForWeekOfYear:
            components.yearForWeekOfYear = amount
            break
        case NSCalendar.Unit.weekday:
            components.weekday = amount
            break
        case NSCalendar.Unit.weekOfMonth:
            components.weekOfMonth = amount
            break
        default:
            break
        }
        
        return (calendar as NSCalendar).date(byAdding: components, to: self, options: NSCalendar.Options(rawValue: 0))
    }
}
