//
//  DBManager.swift
//  GTFSStationsParis
//
//  Created by Elliot Schrock on 7/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import SQLite

open class DBManager: NSObject {
    @objc var sourcePath: String!
    lazy var database: Connection = try! {
        let lazyDatabase = try Connection(self.sourcePath)
        return lazyDatabase
        }()
    
    @objc init(sourcePath: String!) {
        super.init()
        self.sourcePath = sourcePath
    }
}
