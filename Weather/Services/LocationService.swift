//
//  LocationService.swift
//  Weather
//
//  Created by Viacheslav Khakhulin on 12.02.2024.
//

import CoreLocation

enum LocationServiceError: Error {
    case unavailable
}

class LocationService: NSObject, CLLocationManagerDelegate {

    static let shared = LocationService()
    
    private var locationManager = CLLocationManager()
    
    private var didUpdate: ((Double, Double) -> Void)?
    private var didFail: ((Error) -> Void)?
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func isAvailable() -> Bool {
        locationManager.authorizationStatus == .authorizedAlways ||
        locationManager.authorizationStatus == .authorizedWhenInUse
    }
    
    func requestWhenInUseAuthorizationIfNotDetermined() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func request(didUpdate: ((Double, Double) -> Void)?, didFail: ((Error) -> Void)?) {
        self.didUpdate = didUpdate
        self.didFail = didFail
                
        locationManager.requestLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            didUpdate?(latitude, longitude)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            
        case .notDetermined:
            debugPrint("[LocationService] Status: Not determined")
        case .restricted, .denied:
            debugPrint("[LocationService] Status: Disabled")
        case .authorizedAlways, .authorizedWhenInUse:
            debugPrint("[LocationService] Status: Enabled")
        @unknown default:
            debugPrint("[LocationService] Status: Unknown")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        didFail?(error)
    }
}
