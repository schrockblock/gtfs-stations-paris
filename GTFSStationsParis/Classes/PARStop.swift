//
//  PARStop.swift
//  GTFSStationsParis
//
//  Created by Elliot Schrock on 7/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import SubwayStations

open class PARStop: NSObject, Stop {
    open var name: String!
    open var objectId: String!
    open var parentId: String!
    open var station: Station!
    
    init(name: String!, objectId: String!) {
        super.init()
        self.name = name
        self.objectId = objectId
    }
}
