//
//  PARRouteColorManager.swift
//  GTFSStationsParis
//
//  Created by Elliot Schrock on 7/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import SubwayStations

open class PARRouteColorManager: NSObject, RouteColorManager {
    
    open func colorForRouteId(_ routeId: String!) -> UIColor {
        var color: UIColor = UIColor.darkGray
        
        if ["1"].contains(routeId) {color = UIColor(rgba: "#ffcd01")}
        if ["2"].contains(routeId) {color = UIColor(rgba: "#006cb8")}
        if ["3"].contains(routeId) {color = UIColor(rgba: "#9b993b")}
        if ["3bis"].contains(routeId) {color = UIColor(rgba: "#6dc5e0")}
        if ["4"].contains(routeId) {color = UIColor(rgba: "#bb4b9c")}
        if ["5"].contains(routeId) {color = UIColor(rgba: "#f68f4b")}
        if ["6"].contains(routeId) {color = UIColor(rgba: "#77c696")}
        if ["7"].contains(routeId) {color = UIColor(rgba: "#f59fb3")}
        if ["7bis"].contains(routeId) {color = UIColor(rgba: "#77c696")}
        if ["8"].contains(routeId) {color = UIColor(rgba: "#c5a3cd")}
        if ["9"].contains(routeId) {color = UIColor(rgba: "#cec92b")}
        if ["10"].contains(routeId) {color = UIColor(rgba: "#e0b03b")}
        if ["11"].contains(routeId) {color = UIColor(rgba: "#906030")}
        if ["12"].contains(routeId) {color = UIColor(rgba: "#008b5a")}
        if ["13"].contains(routeId) {color = UIColor(rgba: "#87d3df")}
        if ["14"].contains(routeId) {color = UIColor(rgba: "#652c90")}
        if ["15"].contains(routeId) {color = UIColor(rgba: "#a90f32")}
        if ["16"].contains(routeId) {color = UIColor(rgba: "#ec7cae")}
        if ["17"].contains(routeId) {color = UIColor(rgba: "#ec7cae")}
        if ["18"].contains(routeId) {color = UIColor(rgba: "#95bf32")}
        
        return color
    }
}

extension UIColor {
    public convenience init(rgba: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            let index   = rgba.characters.index(rgba.startIndex, offsetBy: 1)
            let hex     = rgba.substring(from: index)
            let scanner = Scanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexInt64(&hexValue) {
                switch (hex.characters.count) {
                case 3:
                    red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                    green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                    blue  = CGFloat(hexValue & 0x00F)              / 15.0
                case 4:
                    red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                    green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                    blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                    alpha = CGFloat(hexValue & 0x000F)             / 15.0
                case 6:
                    red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
                case 8:
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                default:
                    print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8", terminator: "")
                }
            } else {
                print("Scan hex error")
            }
        } else {
            print("Invalid RGB string, missing '#' as prefix", terminator: "")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}
