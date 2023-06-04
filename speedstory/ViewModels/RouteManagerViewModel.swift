//
//  RoutesViewModel.swift
//  speedstory
//
//  Created by yury mid on 28.05.2023.
//

import Foundation
import CoreData
import CoreLocation

class RouteManager: ObservableObject {
    let persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = NSPersistentContainer(name: "speedstory")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                print("Error loading persistent stores: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - CRUD Operations

    func createRoute(name: String, createdDate: Date, duration: TimeInterval, coordinates: [Coordinate]) {
        // Create a new Route entity and save it to Core Data
        let context = persistentContainer.viewContext
        let route = Route(context: context)
        route.id = UUID()
        route.name = name
        route.createdDate = createdDate
        route.duration = duration

        // Fetch the maximum number value currently in use
        let fetchRequest: NSFetchRequest<Route> = Route.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "number", ascending: false)]
        fetchRequest.fetchLimit = 1

        if let lastRoute = try? context.fetch(fetchRequest).first {
            route.number = lastRoute.number + 1
        } else {
            route.number = 1
        }

        route.addToCoordinates(NSSet(array: coordinates))

        // Calculate max speed, average speed, and distance
        let speeds = coordinates.map { $0.speed }
        let maxSpeed = speeds.max() ?? 0
        let avgSpeed = speeds.reduce(0, +) / Double(speeds.count)
        let distance = calculateDistance(coordinates: coordinates)

        route.maxSpeed = maxSpeed
        route.avgSpeed = avgSpeed
        route.distance = distance

        // Save the changes
        saveContext()
    }

    // Helper method to calculate the distance between coordinates
    private func calculateDistance(coordinates: [Coordinate]) -> Double {
        var distance: Double = 0
        
        for i in 0 ..< coordinates.count - 1 {
            let coordinate1 = coordinates[i]
            let coordinate2 = coordinates[i + 1]
            
            let location1 = CLLocation(latitude: coordinate1.latitude, longitude: coordinate1.longitude)
            let location2 = CLLocation(latitude: coordinate2.latitude, longitude: coordinate2.longitude)
            
            distance += location1.distance(from: location2)
        }
        
        return distance
    }



    func updateRoute(route: Route, name: String) {
        // Update the name of a Route entity
        route.name = name
        saveContext()
    }

    func deleteRoute(route: Route) {
        // Delete a Route entity from Core Data
        let context = persistentContainer.viewContext
        context.delete(route)
        saveContext()
    }
    
    func removeAllRoutes() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Route")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            saveContext()
        } catch {
            // Handle delete error
            print("Error deleting routes: \(error.localizedDescription)")
        }
    }

    func fetchAllRoutes() -> [Route] {
        // Fetch all Route entities from Core Data
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Route> = Route.fetchRequest()
        fetchRequest.relationshipKeyPathsForPrefetching = ["coordinates"]
        
        do {
            let routes = try context.fetch(fetchRequest)
            
            return routes
        } catch {
            // Handle fetch error
            print("Error fetching routes: \(error.localizedDescription)")
            return []
        }
    }



    // MARK: - Utility Methods
    
    func getDistanceSum() -> Double {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: "Route")
        fetchRequest.resultType = .dictionaryResultType
        
        let sumExpression = NSExpressionDescription()
        sumExpression.name = "distanceSum"
        sumExpression.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "distance")])
        sumExpression.expressionResultType = .doubleAttributeType
        
        fetchRequest.propertiesToFetch = [sumExpression]
        
        do {
            let results = try context.fetch(fetchRequest)
            if let sum = results.first?["distanceSum"] as? Double {
                return sum
            }
        } catch {
            // Handle fetch error
            print("Error fetching distance sum: \(error.localizedDescription)")
        }
        
        return 0
    }

    func getDurationSum() -> TimeInterval {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: "Route")
        fetchRequest.resultType = .dictionaryResultType
        
        let sumExpression = NSExpressionDescription()
        sumExpression.name = "durationSum"
        sumExpression.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "duration")])
        sumExpression.expressionResultType = .doubleAttributeType
        
        fetchRequest.propertiesToFetch = [sumExpression]
        
        do {
            let results = try context.fetch(fetchRequest)
            if let sum = results.first?["durationSum"] as? TimeInterval {
                return sum
            }
        } catch {
            // Handle fetch error
            print("Error fetching duration sum: \(error.localizedDescription)")
        }
        
        return 0
    }

    func getMaxSpeed() -> Double {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: "Route")
        fetchRequest.resultType = .dictionaryResultType
        
        let maxExpression = NSExpressionDescription()
        maxExpression.name = "maxSpeed"
        maxExpression.expression = NSExpression(forFunction: "max:", arguments: [NSExpression(forKeyPath: "maxSpeed")])
        maxExpression.expressionResultType = .doubleAttributeType
        
        fetchRequest.propertiesToFetch = [maxExpression]
        
        do {
            let results = try context.fetch(fetchRequest)
            if let maxSpeed = results.first?["maxSpeed"] as? Double {
                return maxSpeed
            }
        } catch {
            // Handle fetch error
            print("Error fetching max speed: \(error.localizedDescription)")
        }
        
        return 0
    }

    func getAverageSpeed() -> Double {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: "Route")
        fetchRequest.resultType = .dictionaryResultType
        
        let avgExpression = NSExpressionDescription()
        avgExpression.name = "avgSpeed"
        avgExpression.expression = NSExpression(forFunction: "average:", arguments: [NSExpression(forKeyPath: "avgSpeed")])
        avgExpression.expressionResultType = .doubleAttributeType
        
        fetchRequest.propertiesToFetch = [avgExpression]
        
        do {
            let results = try context.fetch(fetchRequest)
            if let avgSpeed = results.first?["avgSpeed"] as? Double {
                return avgSpeed
            }
        } catch {
            // Handle fetch error
            print("Error fetching average speed: \(error.localizedDescription)")
        }
        
        return 0
    }
    
    func getLastRouteMaxSpeed() -> Double? {
            let fetchRequest: NSFetchRequest<Route> = Route.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]
            fetchRequest.fetchLimit = 1
            
            do {
                let lastRoute = try persistentContainer.viewContext.fetch(fetchRequest).first
                return lastRoute?.maxSpeed
            } catch {
                print("Error fetching last route: \(error.localizedDescription)")
                return nil
            }
        }
        
        func getLastRouteAvgSpeed() -> Double? {
            let fetchRequest: NSFetchRequest<Route> = Route.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]
            fetchRequest.fetchLimit = 1
            
            do {
                let lastRoute = try persistentContainer.viewContext.fetch(fetchRequest).first
                return lastRoute?.avgSpeed
            } catch {
                print("Error fetching last route: \(error.localizedDescription)")
                return nil
            }
        }
        
        func getLastRouteDistance() -> Double? {
            let fetchRequest: NSFetchRequest<Route> = Route.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]
            fetchRequest.fetchLimit = 1
            
            do {
                let lastRoute = try persistentContainer.viewContext.fetch(fetchRequest).first
                return lastRoute?.distance
            } catch {
                print("Error fetching last route: \(error.localizedDescription)")
                return nil
            }
        }
        
        func getLastRouteDuration() -> TimeInterval? {
            let fetchRequest: NSFetchRequest<Route> = Route.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]
            fetchRequest.fetchLimit = 1
            
            do {
                let lastRoute = try persistentContainer.viewContext.fetch(fetchRequest).first
                return lastRoute?.duration
            } catch {
                print("Error fetching last route: \(error.localizedDescription)")
                return nil
            }
        }

    private func saveContext() {
        // Save changes to the persistent store
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Handle save error
                print("Error saving context: \(error.localizedDescription)")
            }
        }
    }
}
