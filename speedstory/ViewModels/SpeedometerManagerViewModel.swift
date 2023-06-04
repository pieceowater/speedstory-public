//
//  SpeedometerManagerViewModel.swift
//  speedstory
//
//  Created by yury mid on 28.05.2023.
//

import Foundation
import CoreLocation
import CoreLocation

class SpeedometerManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var speedMS: Double = 0.0
    @Published var speedKMH: Double = 0.0
    @Published var speedMPH: Double = 0.0
    @Published var userLocation: CLLocation?
    @Published var streetName: String = ""
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        startUpdatingSpeed()
    }
    
    func startUpdatingSpeed() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingSpeed() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let speedInMetersPerSecond = location.speed
        
        DispatchQueue.main.async {
            self.speedMS = speedInMetersPerSecond.rounded() > 0 ? speedInMetersPerSecond.rounded() : 0
            self.speedKMH = (speedInMetersPerSecond.rounded() * 3.6) > 0 ? (speedInMetersPerSecond.rounded() * 3.6).rounded() : 0
            self.speedMPH = (speedInMetersPerSecond.rounded() * 2.237) > 0 ? (speedInMetersPerSecond.rounded() * 2.237).rounded() : 0
            self.userLocation = location
            self.geocodeLocation(location)
        }
    }
    
    private func geocodeLocation(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard let placemark = placemarks?.first, error == nil else {
//                print(error?.localizedDescription ?? "Reverse geocoding error")
                return
            }
            
            DispatchQueue.main.async {
                if let street = placemark.thoroughfare {
                    self.streetName = street
                } else {
                    self.streetName = ""
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
