//
//  PARRoute.swift
//  GTFSStationsParis
//
//  Created by Elliot Schrock on 7/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import SubwayStations

public class PARRoute: Route {
    public var color: UIColor!
    public var objectId: String!
    public var routeIds: Array<String> = Array<String>()
    
    public init(objectId: String!) {
        self.objectId = objectId
    }
}

public func ==(lhs: PARRoute, rhs: PARRoute) -> Bool {
    return lhs.objectId == rhs.objectId
}
