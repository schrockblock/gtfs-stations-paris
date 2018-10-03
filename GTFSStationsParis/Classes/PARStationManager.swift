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

open class PARStationManager: NSObject, StationManager {
    @objc open var sourceFilePath: String?
    @objc lazy var dbManager: DBManager = {
        let lazyManager = DBManager(sourcePath: self.sourceFilePath)
        return lazyManager
    }()
    open var allStations: Array<Station> = Array<Station>()
    open var routes: Array<Route> = Array<Route>()
    @objc open var timeLimitForPredictions: Int32 = 20
    
    @objc public init(sourceFilePath: String?) throws {
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
                    var stationName = station.name.replacingOccurrences(of: "d'", with: "", options: NSString.CompareOptions.caseInsensitive, range: nil)
                    stationName = stationName.replacingOccurrences(of: "l'", with: "", options: NSString.CompareOptions.caseInsensitive, range: nil)
                    let stationNameArray = stationName.components(separatedBy: NSCharacterSet.whitespaces)
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
                if let oldRouteIndex = routes.index(where: {route == ($0 as! PARRoute)}) {
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
    
    open func stationsForSearchString(_ stationName: String!) -> Array<Station>? {
        return allStations.filter({$0.name!.lowercased().range(of: stationName.lowercased()) != nil})
    }
    
    public func predictions(_ station: Station!, time: Date!) -> Array<Prediction> {
        var predictions = Array<Prediction>()
        
        do {
            let stops = station.stops
            let timesQuery = "SELECT trip_id, departure_time FROM stop_times WHERE stop_id IN (" + questionMarksForStopArray(stops)! + ") AND departure_time BETWEEN ? AND ?"
            var stopIds: [Binding?] = stops.map({ (stop: Stop) -> Binding? in
                stop.objectId as Binding
            })
            stopIds.append(dateToTime(time))
            stopIds.append(dateToTime((time as Date).increment(NSCalendar.Unit.minute, amount: Int(timeLimitForPredictions))))
            let stmt = try dbManager.database.prepare(timesQuery)
            for timeRow in stmt.bind(stopIds) {
                let tripId = timeRow[0] as! String
                let depTime = timeRow[1] as! String
                let prediction = Prediction(time: timeToDate(depTime, referenceDate: time))
                
                for tripRow in try dbManager.database.prepare("SELECT direction_id, route_id FROM trips WHERE trip_id = ?", [tripId]) {
                    let direction = tripRow[0] as! Int64
                    let routeId = tripRow[1] as! String
                    prediction.direction = direction == 0 ? Direction.uptown : Direction.downtown
                    let routeArray = routes.filter({($0 as! PARRoute).routeIds.contains(routeId)})
                    prediction.route = routeArray[0]
                }
                
                if !predictions.contains(where: {$0 == prediction}) {
                    predictions.append(prediction)
                }
            }
        }catch _ {
            
        }
        
        return predictions
    }
    
    open func routeIdsForStation(_ station: Station) -> Array<String> {
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
    
    public func stationsForRoute(_ route: Route) -> Array<Station>? {
        var stations = Array<Station>()
        do {
            let sqlString = "SELECT stops.parent_station,stop_times.stop_sequence FROM stops " +
                "INNER JOIN stop_times ON stop_times.stop_id = stops.stop_id " +
                "INNER JOIN trips ON stop_times.trip_id = trips.trip_id " +
                "WHERE trips.route_id = ? AND trips.direction_id = 0 AND stop_times.departure_time BETWEEN ? AND ? " +
                "GROUP BY stops.parent_station " +
            "ORDER BY stop_times.stop_sequence DESC "
            for stopRow in try dbManager.database.prepare(sqlString, [route.objectId, "10:00:00", "15:00:00"]) {
                let parentId = stopRow[0] as? String
                for station in allStations {
                    var foundOne = false
                    for stop in station.stops {
                        if stop.objectId == parentId {
                            stations.append(station)
                            foundOne = true
                            break
                        }
                    }
                    if foundOne {
                        break
                    }
                }
            }
        }catch _ {
            
        }
        return stations
    }
    
    @objc func dateToTime(_ time: Date!) -> String{
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: time)
    }
    
    @objc func timeToDate(_ time: String!, referenceDate: Date!) -> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD "
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-DD HH:mm:ss"
        let timeString = dateFormatter.string(from: referenceDate) + time
        return formatter.date(from: timeString)
    }
    
    func questionMarksForStopArray(_ array: Array<Stop>?) -> String?{
        var qMarks: String = "?"
        if let stops = array {
            if stops.count > 1 {
                for _ in stops {
                    qMarks = qMarks + ",?"
                }
                let index = qMarks.characters.index(qMarks.endIndex, offsetBy: -2)
                qMarks = qMarks.substring(to: index)
            }
        }else{
            return nil
        }
        return qMarks
    }
    
    @objc func queryForNameArray(_ array: Array<String>?) -> String? {
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
