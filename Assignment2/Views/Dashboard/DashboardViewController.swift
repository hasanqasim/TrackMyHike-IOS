//
//  DashboardViewController.swift
//  Assignment2
//
//  Created by M Rahman on 24/9/19.
//  Copyright © 2019 M Rahman. All rights reserved.
//

import UIKit
import CoreLocation

class DashboardViewController: UIViewController/*, DatabaseListener*/ {

    @IBOutlet weak var weatherView: UIView!
    @IBOutlet weak var altitudeView: UIView!
    @IBOutlet weak var pressureView: UIView!
    
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    
    @IBOutlet weak var overlay: UIView!
    @IBOutlet weak var altitudeText: UILabel!
    @IBOutlet weak var pressureText: UILabel!
    var observer: NSObjectProtocol?
    
    let locationManager = CLLocationManager()
    
    //var allSensorReadings = [SensorReading]()
    //weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLocationServices()
        //view.backgroundColor = Theme.primary!.withAlphaComponent(0.4)
        
        
        setupAnimatedControls()
        
        
        
        /*let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController*/
    }
    
    func setFields(){
        self.temperatureLabel.text = "\(Data.currentReading.temperature) °C"
        self.pressureLabel.text = "\(Data.currentReading.pressure/1000) kPa"
        self.altitudeLabel.text = "\(Data.currentReading.altitude) m"
        
        cityLabel.setStyle()
        
        temperatureLabel.setStyle()
        altitudeLabel.setStyle()
        pressureLabel.setStyle()
        altitudeText.textColor = Theme.current.text
        pressureText.textColor = Theme.current.text
        overlay.backgroundColor = Theme.current.primary.withAlphaComponent(0.3)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 1.0, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [], animations: {
            self.weatherView.transform = .identity
            self.altitudeView.transform = .identity
            self.pressureView.transform = .identity
        }) { (success) in
            //for doing something after animation finished
            
            
        }
        
    }
    
    func setupAnimatedControls() {
        weatherView.transform = CGAffineTransform(translationX: 0, y: -weatherView.frame.height - 50)
        altitudeView.transform = CGAffineTransform(translationX: -altitudeView.frame.width, y: 0)
        pressureView.transform = CGAffineTransform(translationX: pressureView.frame.width, y: 0)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Theme.current.barStyle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // databaseController?.addListener(listener: self)
       observer = NotificationCenter.default.addObserver(forName: .currentReadingUpdate, object: nil, queue: OperationQueue.main) { (notification) in
            self.setFields()
        }
        locationManager.startUpdatingLocation()
        if Data.currentReading.id != "" {
            setFields()
        }
    }
          
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       // databaseController?.removeListener(listener: self)
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
        locationManager.stopUpdatingLocation()
    }
       
    
    
    /*func onSensorReadingListChange(change: DatabaseChange, sensorReadings: [SensorReading]) {
        //print("In Dashboard")
        if Data.currentReading.id != "" {
            self.temperatureLabel.text = "\(Int(Data.currentReading.temperature)) °C"
            self.pressureLabel.text = "\(Int(Data.currentReading.pressure/1000)) kPa"
            self.altitudeLabel.text = "\(Data.currentReading.altitude) m"
        }
    }*/
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension DashboardViewController: CLLocationManagerDelegate{
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorization()
        }else{
            // When location services is not enabled
        }
    }
    
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus(){
        case .authorizedWhenInUse:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedAlways:
            break
        default:
            cityLabel.text = "NA"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Update the coordinates
        guard let currentLocation = locations.last else {return}
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            if let _ = error {
                print("Location fetching error: \(error!)")
                self.cityLabel.text = "NA"
                return
            }
            guard let placemark = placemarks?.first else {
                return
            }
            DispatchQueue.main.async {
                self.cityLabel.text = placemark.locality
            }
            
            
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //change authorization
    }
}
