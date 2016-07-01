//
//  PARStationManager.swift
//  GTFSStationsParis
//
//  Created by Elliot Schrock on 7/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import SQLite
import SubwayStations

public class PARStationManager: NSObject, StationManager {
    public var sourceFilePath: String?
    lazy var dbManager: DBManager = {
        let lazyManager = DBManager(sourcePath: self.sourceFilePath)
        return lazyManager
    }()
    public var allStations: Array<Station> = Array<Station>()
    public var routes: Array<Route> = Array<Route>()
    public var timeLimitForPredictions: Int32 = 20
    
    public init(sourceFilePath: String?) throws {
        super.init()
        
        if let file = sourceFilePath {
            self.sourceFilePath = file
        }
        
        do {
            var stationIds = Array<String>()
            let stopRows = try dbManager.database.prepare("SELECT stop_name, stop_id FROM stops")
            for stopRow in stopRows {
                let stop = PARStop(name: stopRow[0] as! String, objectId: stopRow[1] as! String)
                if !stationIds.contains(stop.name) {
                    let station = PARStation(name: stop.name)
                    station.stops.append(stop)
                    stationIds.append(stop.name)
                    var stationName = station.name.stringByReplacingOccurrencesOfString("d'", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
                    stationName = stationName.stringByReplacingOccurrencesOfString("l'", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
                    let stationNameArray = stationName.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    if let queryForName = queryForNameArray(stationNameArray) {
                        for otherStopRow in try dbManager.database.prepare("SELECT stop_name, stop_id FROM stops WHERE location_type = 0" + queryForName) {
                            let parent = PARStop(name: otherStopRow[0] as! String, objectId: otherStopRow[1] as! String)
                            if station == PARStation(name: parent.name) {
                                station.stops.append(parent)
                                stationIds.append(parent.name)
                            }
                        }
                    }
                    
                    allStations.append(station)
                }
            }
            
            for routeRow in try dbManager.database.prepare("SELECT route_id, route_short_name FROM routes") {
                let route = PARRoute(objectId: routeRow[1] as! String)
                route.color = PARRouteColorManager().colorForRouteId(routeRow[1] as! String)
                if let oldRouteIndex = routes.indexOf({route == ($0 as! PARRoute)}) {
                    let oldRoute = routes[oldRouteIndex] as! PARRoute
                    if !oldRoute.routeIds.contains(routeRow[0] as! String) {
                        oldRoute.routeIds.append(routeRow[0] as! String)
                    }
                }else{
                    route.routeIds.append(routeRow[0] as! String)
                    routes.append(route)
                }
            }
        }catch let error as NSError {
            print(error.debugDescription)
        }
    }
    
    public func stationsForSearchString(stationName: String!) -> Array<Station>? {
        return allStations.filter({$0.name!.lowercaseString.rangeOfString(stationName.lowercaseString) != nil})
    }
    
    public func predictions(station: Station!, time: NSDate!) -> Array<Prediction>{
        var predictions = Array<Prediction>()
        
        do {
            let stops = station.stops
            let timesQuery = "SELECT trip_id, departure_time FROM stop_times WHERE stop_id IN (" + questionMarksForStopArray(stops)! + ") AND departure_time BETWEEN ? AND ?"
            var stopIds: [Binding?] = stops.map({ (stop: Stop) -> Binding? in
                stop.objectId as Binding
            })
            stopIds.append(dateToTime(time))
            stopIds.append(dateToTime(time.increment(NSCalendarUnit.Minute, amount: Int(timeLimitForPredictions))))
            let stmt = try dbManager.database.prepare(timesQuery)
            for timeRow in stmt.bind(stopIds) {
                let tripId = timeRow[0] as! String
                let depTime = timeRow[1] as! String
                let prediction = Prediction(time: timeToDate(depTime, referenceDate: time))
                
                for tripRow in try dbManager.database.prepare("SELECT direction_id, route_id FROM trips WHERE trip_id = ?", [tripId]) {
                    let direction = tripRow[0] as! Int64
                    let routeId = tripRow[1] as! String
                    prediction.direction = direction == 0 ? .Uptown : .Downtown
                    let routeArray = routes.filter({($0 as! PARRoute).routeIds.contains(routeId)})
                    prediction.route = routeArray[0]
                }
                
                if !predictions.contains({$0 == prediction}) {
                    predictions.append(prediction)
                }
            }
        }catch _ {
            
        }
        
        return predictions
    }
    
    public func routeIdsForStation(station: Station) -> Array<String> {
        var routeNames = Array<String>()
        do {
            let stops = station.stops
            let sqlStatementString = "SELECT trips.route_id FROM trips INNER JOIN stop_times ON stop_times.trip_id = trips.trip_id WHERE stop_times.stop_id IN (" + questionMarksForStopArray(stops)! + ") GROUP BY trips.route_id"
            let sqlStatement = try dbManager.database.prepare(sqlStatementString)
            let stopIds: [Binding?] = stops.map({ (stop: Stop) -> Binding? in
                stop.objectId as Binding
            })
            var routeIds = Array<String>()
            for routeRow in sqlStatement.bind(stopIds) {
                routeIds.append(routeRow[0] as! String)
            }
            for routeId in routeIds {
                for route in routes {
                    let parRoute = route as! PARRoute
                    if parRoute.routeIds.contains(routeId) && !routeNames.contains(parRoute.objectId) {
                        routeNames.append(parRoute.objectId)
                    }
                }
            }
        }catch _ {
            
        }
        return routeNames
    }
    
    func dateToTime(time: NSDate!) -> String{
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.stringFromDate(time)
    }
    
    func timeToDate(time: String!, referenceDate: NSDate!) -> NSDate?{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD "
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "YYYY-MM-DD HH:mm:ss"
        let timeString = dateFormatter.stringFromDate(referenceDate) + time
        return formatter.dateFromString(timeString)
    }
    
    func questionMarksForStopArray(array: Array<Stop>?) -> String?{
        var qMarks: String = "?"
        if let stops = array {
            if stops.count > 1 {
                for _ in stops {
                    qMarks = qMarks + ",?"
                }
                let index = qMarks.endIndex.advancedBy(-2)
                qMarks = qMarks.substringToIndex(index)
            }
        }else{
            return nil
        }
        return qMarks
    }
    
    func queryForNameArray(array: Array<String>?) -> String? {
        var query = ""
        if let nameArray = array {
            for nameComponent in nameArray {
                query += " AND stop_name LIKE '%\(nameComponent)%'"
            }
        }else{
            return nil
        }
        return query
    }
}
