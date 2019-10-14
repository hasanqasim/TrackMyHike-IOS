//
//  FirebaseController.swift
//  Assignment2
//
//  Created by Hasan Qasim on 26/9/19.
//  Copyright © 2019 M Rahman. All rights reserved.
//

import UIKit
import Firebase
// firebaseAuth allows us to use the authentication features of Firebase
import FirebaseAuth
// FirebaseFirestore allows us to use the firestore database functionality
import FirebaseFirestore


class FirebaseController: NSObject, DatabaseProtocol {
    
    let ID = "b8:27:eb:bb:84:9b"
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var authController: Auth
    var database: Firestore
    var sensorReadingsRef: CollectionReference?
    var sensorReadingList: [SensorReading]
    
    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        sensorReadingList = [SensorReading]()
       
        super.init()
        authController.signInAnonymously() { (authResult, error) in
            guard authResult != nil else {
                fatalError("Firebase authentication failed")
            }
            // if authenticated, attach listener to firebase store
            self.setUpListeners()
        }
        
    }
   
    func setUpListeners() {
        sensorReadingsRef = database.collection(ID)
        // snapshot listener returns a snapshot of the data for the given reference
        // In this case it is the entire collection of sensor readings
        //this query contains all readings and not just the updated ones, we need to filter them out
        //everytime an update is made to the sensor_readings, this method will be called which will call    parseSensorReadingsSnapshot
        
        sensorReadingsRef?.addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                print("error fetching documents: \(error!)")
                return
            }
            self.parseSensorReadingsSnapshot(snapshot: querySnapshot!)
        }
    }
   
    func parseSensorReadingsSnapshot(snapshot: QuerySnapshot) {
        // run a for loop to get each document that has had a change. This immediately filters out any readings that hasnt been changed at all this update
        snapshot.documentChanges.forEach { change in
            // get reading data for each document. data is stored as a Dictionary of Any with strings as Keys
            let documentRef = change.document.documentID
            guard (change.document.data()["altitude"] != nil) else {
                return
            }
            let altitude = change.document.data()["altitude"] as! Double
            let lux = change.document.data()["lux"] as! Double
            let pressure = change.document.data()["pressure"] as! Double
            let temperature = change.document.data()["temperature"] as! Double
            //convert timestamp string to type date in swift
            let timestampString = change.document.data()["timestamp"] as! String
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
            let timestamp = dateFormatter.date(from: timestampString)

            //print(documentRef)
           
            //for each document we check the type of change that has occured
            // for an add create a new reading and append it to the list of readings
            if change.type == .added || change.type == .modified {
                //print("new reading: \(change.document.data())")
                let newReading = SensorReading()
                newReading.altitude = altitude
                newReading.lux = lux
                newReading.pressure = pressure
                newReading.temperature = temperature
                newReading.timestamp = timestamp!
                newReading.id = documentRef
               
                sensorReadingList.append(newReading)
            }
           
            // for remove we find the reading in the array by ID then remove it
            if change.type == .removed {
                print("Removed Hero: \(change.document.data())")
                if let index = getReadingIndexByID(reference: documentRef) {
                    sensorReadingList.remove(at: index)
                }
            }
            if sensorReadingList.count > 0 {
                Data.currentReading = sensorReadingList.last!
            }
        }
        sensorReadingList = sensorReadingList.sorted(by: { $0.timestamp < $1.timestamp })
        // call db listeners and provide them with the most updated sensor reading list
        listeners.invoke { (listener) in
            listener.onSensorReadingListChange(change: .update, sensorReadings: sensorReadingList)
        }
    }
   
    func getReadingIndexByID(reference: String) -> Int? {
        for reading in sensorReadingList {
            if (reading.id == reference) {
                return sensorReadingList.firstIndex(of: reading)
            }
        }
        return nil
    }
   
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        listener.onSensorReadingListChange(change: .update, sensorReadings: sensorReadingList)
    }
      
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
}
