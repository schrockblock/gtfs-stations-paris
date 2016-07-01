//
//  PARStation.swift
//  GTFSStationsParis
//
//  Created by Elliot Schrock on 7/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import SubwayStations

public class PARStation: Station {
    public var name: String!
    public var stops: Array<Stop> = Array<Stop>()
    
    public init(name: String!) {
        self.name = name
    }
}
