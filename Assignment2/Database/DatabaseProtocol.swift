//
//  DatabaseProtocol.swift
//  Assignment2
//
//  Created by Hasan Qasim on 26/9/19.
//  Copyright © 2019 M Rahman. All rights reserved.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

protocol DatabaseListener: AnyObject {
    func onSensorReadingListChange(change: DatabaseChange, sensorReadings: [SensorReading])
}

protocol DatabaseProtocol: AnyObject {
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
