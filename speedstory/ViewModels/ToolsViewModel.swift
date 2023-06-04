//
//  HelperViewModel.swift
//  speedstory
//
//  Created by yury mid on 01.06.2023.
//

import Foundation

class Tools {
    
    func formattedCoordinate(_ coordinate: Double?) -> String {
        guard let coordinate = coordinate else { return "" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 3
        formatter.maximumFractionDigits = 3
        
        let formattedString = formatter.string(from: NSNumber(value: coordinate)) ?? "--"
        return "\(formattedString)°"
    }

    func formattedDuration(_ duration: TimeInterval) -> String {
       let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
       return formatter.string(from: duration) ?? ""
    }
    
    func formattedDate(_ date: Date) -> String {
       let formatter = DateFormatter()
       formatter.dateStyle = .medium
       formatter.timeStyle = .short
       return formatter.string(from: date)
    }
    
    func convertedSpeed(units: Units, speedMS: Double) -> Int {
        if units == .kmh {
            let speedKMH = speedMS * 3.6
            return Int(speedKMH)
        } else {
            let speedMPH = speedMS * 2.23694
            return Int(speedMPH)
        }
    }
    
    func convertedDistance(units: Units, distanceM: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        
        var convertedDistance: Double
        
        if units == .kmh {
            let distanceKMH = distanceM / 1000.0
            convertedDistance = distanceKMH.rounded(toDecimalPlaces: 2)
        } else {
            let distanceMiles = distanceM / 1609.34
            convertedDistance = distanceMiles.rounded(toDecimalPlaces: 2)
        }
        
        guard let formattedDistance = numberFormatter.string(from: NSNumber(value: convertedDistance)) else {
            return ""
        }
        
        return formattedDistance
    }
    
}
