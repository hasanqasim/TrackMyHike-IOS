//
//  SensorReading.swift
//  Assignment2
//
//  Created by Hasan Qasim on 26/9/19.
//  Copyright © 2019 M Rahman. All rights reserved.
//

import UIKit

class SensorReading: NSObject {
    var id: String
    var altitude: Double
    var lux: Double
    var pressure: Double
    var temperature: Double
    var timestamp: Date
       
    override init() {
        self.id = ""
        self.altitude = 0
        self.lux = 0
        self.pressure = 0
        self.temperature = 0
        self.timestamp = Date()
    }
}
