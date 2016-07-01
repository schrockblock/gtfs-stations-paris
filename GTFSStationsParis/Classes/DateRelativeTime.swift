//
//  DateRelativeTime.swift
//  GTFSStationsParis
//
//  Created by Elliot Schrock on 7/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

extension NSDate {
    public func isBefore(date: NSDate) -> Bool {
        return self.compare(date) == .OrderedAscending
    }
    
    public func isAfter(date: NSDate) -> Bool {
        return self.compare(date) == .OrderedDescending
    }
    
    public func increment(unit: NSCalendarUnit, amount: Int) -> NSDate? {
        let calendar = NSCalendar.autoupdatingCurrentCalendar()
        calendar.locale = NSLocale(localeIdentifier: "en-US")
        
        let components = NSDateComponents()
        
        switch unit {
        case NSCalendarUnit.Year:
            components.year = amount
            break
        case NSCalendarUnit.WeekOfYear:
            components.weekOfYear = amount
            break
        case NSCalendarUnit.Month:
            components.month = amount
            break
        case NSCalendarUnit.Day:
            components.day = amount
            break
        case NSCalendarUnit.Hour:
            components.hour = amount
            break
        case NSCalendarUnit.Minute:
            components.minute = amount
            break
        case NSCalendarUnit.Second:
            components.second = amount
            break
        case NSCalendarUnit.Era:
            components.era = amount
            break
        case NSCalendarUnit.Quarter:
            components.quarter = amount
            break
        case NSCalendarUnit.WeekdayOrdinal:
            components.weekdayOrdinal = amount
            break
        case NSCalendarUnit.YearForWeekOfYear:
            components.yearForWeekOfYear = amount
            break
        case NSCalendarUnit.Weekday:
            components.weekday = amount
            break
        case NSCalendarUnit.WeekOfMonth:
            components.weekOfMonth = amount
            break
        default:
            break
        }
        
        return calendar.dateByAddingComponents(components, toDate: self, options: NSCalendarOptions(rawValue: 0))
    }
}
