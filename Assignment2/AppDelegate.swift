//
//  AppDelegate.swift
//  Assignment2
//
//  Created by M Rahman on 24/9/19.
//  Copyright © 2019 M Rahman. All rights reserved.
//

import UIKit
import UserNotifications
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, DatabaseListener {
    

    var time = Date()

    var window: UIWindow?
    var databaseController: DatabaseProtocol?
    
    var session: WCSession?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        databaseController = FirebaseController()
        databaseController?.addListener(listener: self)
        
        
        requestPermissionNotifications()
        
        configureWatchKitSession()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        //databaseController?.removeListener(listener: self)
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        //databaseController?.addListener(listener: self)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func onSensorReadingListChange(change: DatabaseChange, sensorReadings: [SensorReading]) {
        Data.sensorReadings = sensorReadings
        
        if Data.sensorReadings.count > 0 {
            Data.currentReading = sensorReadings.last!
            print("\(Data.currentReading.temperature), \(Data.currentReading.altitude), \(Data.currentReading.pressure)")
            if Data.currentReading.lux < 500 {Theme.current = DarkTheme()}
            else {Theme.current = LightTheme()}
            UITabBar.appearance().barTintColor = Theme.current.primary
            UITabBar.appearance().tintColor = Theme.current.text
            NotificationCenter.default.post(name: .currentReadingUpdate, object: nil)
            if let validSession = self.session {
                let altitude = Data.currentReading.altitude
                let pressure = round((Data.currentReading.pressure/1000)*1000)/1000
                let temperature = Data.currentReading.temperature
                let message = ["temperature": temperature, "pressure": pressure, "altitude": altitude]
                    do {
                        try validSession.updateApplicationContext(message)
                    } catch {
                        print("Something went wrong")
                    }
            }
            
        }
        
        if time.timeIntervalSinceNow < -1800 && Data.sensorReadings.count > 0 {
            time = Date()
            postLocalNotifications(eventTitle: "Current Reading")
        }
    }
    
    func postLocalNotifications(eventTitle:String){
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = eventTitle
        //content.subtitle = "The Temperature is normal"
        content.body = "Current Stats: Altitude: \(Data.currentReading.altitude), Pressure: \(Data.currentReading.pressure), Temperature: \(Data.currentReading.temperature)"
        
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let notificationRequest:UNNotificationRequest = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
        
        center.add(notificationRequest, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
                print(error)
            }
            else{
                print("added")
            }
        })
    }
    
    func requestPermissionNotifications(){
        let application =  UIApplication.shared
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (isAuthorized, error) in
                if( error != nil ){
                    print(error!)
                }
                else{
                    if( isAuthorized ){
                        //print("authorized")
                        NotificationCenter.default.post(Notification(name: Notification.Name("AUTHORIZED")))
                    }
                    else{
                        let pushPreference = UserDefaults.standard.bool(forKey: "PREF_PUSH_NOTIFICATIONS")
                        if pushPreference == false {
                            let alert = UIAlertController(title: "Turn on Notifications", message: "Push notifications are turned off.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Turn on notifications", style: .default, handler: { (alertAction) in
                                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                    return
                                }
                                
                                if UIApplication.shared.canOpenURL(settingsUrl) {
                                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                        // Checking for setting is opened or not
                                        print("Setting is opened: \(success)")
                                    })
                                }
                                UserDefaults.standard.set(true, forKey: "PREF_PUSH_NOTIFICATIONS")
                            }))
                            alert.addAction(UIAlertAction(title: "No thanks.", style: .default, handler: { (actionAlert) in
                                print("user denied")
                                UserDefaults.standard.set(true, forKey: "PREF_PUSH_NOTIFICATIONS")
                            }))
                            let viewController = UIApplication.shared.keyWindow!.rootViewController
                            DispatchQueue.main.async {
                                viewController?.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
        else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

}

extension AppDelegate: WCSessionDelegate {
    
    func configureWatchKitSession() {
        if WCSession.isSupported() {//4.1
            session = WCSession.default//4.2
            session?.delegate = self//4.3
            session?.activate()//4.4
            print("app delegate Session has been activated")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("1 sessionDidBecomeInactive")
    }
       
    func sessionDidDeactivate(_ session: WCSession) {
        print("2 sessionDidDeactivate")
    }
       
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("3 activation state: \(activationState)")
    }
    
}


