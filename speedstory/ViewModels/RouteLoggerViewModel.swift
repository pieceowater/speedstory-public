//
//  RouteLoggerViewModel.swift
//  speedstory
//
//  Created by yury mid on 29.05.2023.
//

import Foundation
import CoreLocation

struct RouteData {
    var userSpeed: Double
    var userCoordinates: CLLocationCoordinate2D
}

class RouteLogger: ObservableObject {
    let routeManager: RouteManager
    let speedometerManager: SpeedometerManager
    
    @Published var isLogging: Bool = false
    @Published var isPaused: Bool = true
    
    @Published var userCoordinates: [Coordinate] = []
    
    @Published var routeDuration: TimeInterval = 0
    @Published var currentMaxSpeed: Double = 0
    @Published var currentAvgSpeed: Double = 0
    @Published var currentDistance: Double = 0
    
    
    
    init(routeManager: RouteManager, speedometerManager: SpeedometerManager) {
        self.routeManager = routeManager
        self.speedometerManager = speedometerManager
    }
    
    func startRoute() {
        // Start the route logging
        isLogging = true
        isPaused = false
        routeDuration = 0
        currentDistance = 0
        currentAvgSpeed = 0
        currentMaxSpeed = 0
        userCoordinates.removeAll()
        
        // Start the timer to update the route duration
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if !self.isPaused {
                self.updateCoordinates()
                self.routeDuration += 1
                
                self.updateSpeedMetrics()
                self.updateDistance()
            }
            
            if !self.isLogging {
                timer.invalidate()
            }
        }
        
    }
    
    func pauseRoute() {
        // Pause the route logging
        isPaused.toggle()
    }
    
    func endRoute() {
        // End the route logging
        isLogging = false
        isPaused = true
        
        // Create a new route in Core Data
        let name = speedometerManager.streetName.isEmpty ? "New Rote!" : speedometerManager.streetName
        let createdDate = Date()
        let duration = routeDuration
        
//        let coordinates = userCoordinates.map { coordinate in
//            Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude, speed: coordinate.speed)
//        }
        
//        print(userCoordinates)
//        userCoordinates.removeAll()
        
        routeManager.createRoute(name: name, createdDate: createdDate, duration: duration, coordinates: userCoordinates)
        
    }
    
    
    func updateCoordinates() {
        // Update the user coordinates array with the latest location
        guard let userLocation = speedometerManager.userLocation else { return }
        let userSpeed = speedometerManager.speedMS
        
        let coordinate = Coordinate(context: routeManager.persistentContainer.viewContext)
        coordinate.latitude = userLocation.coordinate.latitude
        coordinate.longitude = userLocation.coordinate.longitude
        coordinate.speed = userSpeed
        coordinate.date = Date()
        userCoordinates.append(coordinate)
    }
    
    private func updateSpeedMetrics() {
        let speeds = userCoordinates.map { $0.speed }
        if let maxSpeed = speeds.max() {
            currentMaxSpeed = maxSpeed
        }
        
        let sumOfSpeeds = speeds.reduce(0, +)
        if !speeds.isEmpty {
            currentAvgSpeed = sumOfSpeeds / Double(speeds.count)
        }
    }
    
    private func updateDistance() {
        if userCoordinates.count >= 2 {
            let lastCoordinate = userCoordinates[userCoordinates.count - 1]
            let secondLastCoordinate = userCoordinates[userCoordinates.count - 2]
            
            let location1 = CLLocation(latitude: lastCoordinate.latitude, longitude: lastCoordinate.longitude)
            let location2 = CLLocation(latitude: secondLastCoordinate.latitude, longitude: secondLastCoordinate.longitude)
            
            currentDistance += location1.distance(from: location2)
        }
    }
}
