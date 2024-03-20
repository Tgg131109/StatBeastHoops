//
//  LocationManager.swift
//  HoopIQ
//
//  Created by Toby Gamble on 5/13/23.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?
    @Published var location : String?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
//        locationManager.requestLocation()
    }

    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        
        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }

    func requestLocation() {
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
//        print(#function, statusString)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let geocoder = CLGeocoder()
        
        guard let locationData = locations.last else { return }
        lastLocation = locationData
//        print(#function, locationData)
        
        geocoder.reverseGeocodeLocation(locations[0]) { (placemarks, error) in
            if (error != nil) {
                return
            }
            
            let placemark = placemarks! as [CLPlacemark]
            
            if placemark.count > 0 {
                let placemark = placemarks![0]
                self.location = "\(placemark.locality!), \(placemark.administrativeArea!)"
                
                self.locationManager.stopUpdatingLocation() // Prevent uneccessay location calls
            }
        }
    }
}
