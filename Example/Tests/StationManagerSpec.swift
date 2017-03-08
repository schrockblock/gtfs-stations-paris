//
//  StationManagerSpec.swift
//  GTFSStationsParis
//
//  Created by Elliot Schrock on 7/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import GTFSStationsParis
import Pods_GTFSStationsParis_Example
import Quick
import Nimble
import SubwayStations

class StationManagerSpec: QuickSpec {
    override func spec() {
        describe("StationManager", { () -> Void in
            do {
                let path = Bundle(for: self.classForCoder).path(forResource: "paris", ofType: "db")
                let stationManager: PARStationManager! = try PARStationManager(sourceFilePath: path)
                var allStations: Array<Station>?
                
                beforeSuite {
                    allStations = stationManager.allStations
                }
                
                it("can find stations based on name") {
                    let searchedStations: Array<Station>? = stationManager.stationsForSearchString("nati")
                    expect(searchedStations).toNot(beNil())
                    if let stations = searchedStations {
                        expect(stations.count).to(beTruthy())
                        var hasNation: Bool = false
                        for station in stations {
                            if let name = station.name {
                                if (name.hasPrefix("Nation")) {
                                    hasNation = true
                                }
                            }
                        }
                        expect(hasNation).to(beTruthy())
                    }
                }
                
                it("returns route ids for a station") {
                        let firstStation = allStations?.first
                        expect(firstStation).notTo(beNil())
                        if let station = firstStation {
                            let routeIds = stationManager.routeIdsForStation(station)
                            expect(routeIds.count).notTo(equal(0))
                        }
                }
                
                it("returns all stations") {
                    expect(allStations).toNot(beNil())
                    if let stations = allStations {
                        expect(stations.count > 350).to(beTruthy())
                    }
                }
                
                it("has stations which all have names") {
                    if let stations = allStations {
                        for station in stations {
                            expect(station.name).toNot(beNil())
                        }
                    }else{
                        expect(false).to(beTruthy());
                    }
                }
                
                it("has stations which all have predictions") {
                        if let stations = allStations {
                            for station in stations {
                                let date = NSDate(timeIntervalSince1970:1434217843)
                                let stationPredictions: Array<Prediction>? = stationManager.predictions(station, time: date as Date!)
                                expect(stationPredictions).toNot(beNil())
                                if let predictions = stationPredictions {
                                    expect(predictions.count > 0).to(beTruthy())
                                    if predictions.count != 0 {
                                        let prediction: Prediction = predictions[0]
                                        expect(prediction.timeOfArrival).toNot(beNil())
                                        expect(prediction.secondsToArrival).toNot(beNil())
                                        expect((prediction.timeOfArrival as NSDate?)?.timeIntervalSince(date as Date)).to(beLessThan(20 * 60))
                                        expect(prediction.direction).toNot(beNil())
                                        expect(prediction.route).toNot(beNil())
                                        if let route = prediction.route {
                                            expect(route.color).toNot(beNil())
                                            expect(route.objectId).toNot(beNil())
                                        }
                                    }
                                }
                            }
                        }else{
                            expect(false).to(beTruthy())
                        }
                }
            } catch {
                expect(true).to(beFalse())
            }
        })
    }
}
