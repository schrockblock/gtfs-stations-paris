//
//  PARStop.swift
//  GTFSStationsParis
//
//  Created by Elliot Schrock on 7/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import SubwayStations

public class PARStop: NSObject, Stop {
    public var name: String!
    public var objectId: String!
    public var parentId: String!
    public var station: Station!
    
    init(name: String!, objectId: String!) {
        super.init()
        self.name = name
        self.objectId = objectId
    }
}
