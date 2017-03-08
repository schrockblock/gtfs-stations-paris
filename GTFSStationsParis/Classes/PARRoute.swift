//
//  PARRoute.swift
//  GTFSStationsParis
//
//  Created by Elliot Schrock on 7/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import SubwayStations

open class PARRoute: Route {
    open var color: UIColor!
    open var objectId: String!
    open var routeIds: Array<String> = Array<String>()
    
    public init(objectId: String!) {
        self.objectId = objectId
    }
}

public func ==(lhs: PARRoute, rhs: PARRoute) -> Bool {
    return lhs.objectId == rhs.objectId
}
