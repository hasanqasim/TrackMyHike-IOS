//
//  InterfaceController.swift
//  WatchOS Extension
//
//  Created by Hasan Qasim on 4/10/19.
//  Copyright © 2019 M Rahman. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var altitudeLabel: WKInterfaceLabel!
    @IBOutlet weak var pressureLabel: WKInterfaceLabel!
    @IBOutlet weak var temperatureLabel: WKInterfaceLabel!
    let session = WCSession.default
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        processApplicationContext()
        
        session.delegate = self//**3
        session.activate()//**4
        print("watch os Session has been activated")
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}

extension InterfaceController: WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("1 activation state: \(activationState)")
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async() {
            self.processApplicationContext()
        }
    }

    func processApplicationContext() {
        let context = session.receivedApplicationContext
        print("received data: \(context)")
        if let altitude = context["altitude"] as? Double {
            self.altitudeLabel.setText("\(altitude) m")
        }
               
        if let pressure = context["pressure"] as? Double {
            self.pressureLabel.setText("\(pressure) KPa")
        }
        
        if let temperature = context["temperature"] as? Double {
            self.temperatureLabel.setText("\(temperature) °C")
        }
    }
}
            

