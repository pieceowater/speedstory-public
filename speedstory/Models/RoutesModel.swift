//
//  RoutesModel.swift
//  speedstory
//
//  Created by yury mid on 28.05.2023.
//

import Foundation
import CoreLocation

struct MapCoord {
    let latitude: Double
    let longitude: Double
    let date: Date
}

extension Double {
    func rounded(toDecimalPlaces decimalPlaces: Int) -> Double {
        let divisor = pow(10.0, Double(decimalPlaces))
        return (self * divisor).rounded() / divisor
    }
}
