//
//  UserSettingsManagerViewModel.swift
//  speedstory
//
//  Created by yury mid on 28.05.2023.
//

import Foundation
import SwiftUI

class UserSettingsManager: ObservableObject {
    static let shared = UserSettingsManager()
    
    @Published var units: Units = .kmh
    @Published var accentColor: Colors = .default
    @Published var theme: Theme = .dark
    @Published var selectedLanguage: Language?
    
    private let unitsKey = "units"
    private let accentColorKey = "accentColor"
    private let themeKey = "theme"
    
    private init() {
        loadSettings()
    }
    
    func saveSettings() {
        UserDefaults.standard.set(units.rawValue, forKey: unitsKey)
        UserDefaults.standard.set(accentColor.rawValue, forKey: accentColorKey)
        UserDefaults.standard.set(theme.rawValue, forKey: themeKey)
    }
    
    func setLanguage(_ language: Language) {
        selectedLanguage = language

        // Update the app's localization
        UserDefaults.standard.set([language.code], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    private func loadSettings() {
        if let unitsValue = UserDefaults.standard.string(forKey: unitsKey),
           let units = Units(rawValue: unitsValue) {
            self.units = units
        }
        
        if let accentColorValue = UserDefaults.standard.string(forKey: accentColorKey),
           let accentColor = Colors(rawValue: accentColorValue) {
            self.accentColor = accentColor
        }
        
        if let themeValue = UserDefaults.standard.string(forKey: themeKey),
           let theme = Theme(rawValue: themeValue) {
            self.theme = theme
        }
    }
    
    func resetSettings() {
        UserDefaults.standard.removeObject(forKey: unitsKey)
        UserDefaults.standard.removeObject(forKey: accentColorKey)
        UserDefaults.standard.removeObject(forKey: themeKey)
        loadSettings()
    }
}

enum Units: String {
    case kmh
    case mph
}

enum Theme: String {
    case light
    case dark
}

enum Colors: String, CaseIterable {
    case blue
    case red
    case orange
    case yellow
    case green
    case purple
    case pink
    case teal
    case indigo
    case gray
    case `default`
    
    var color: Color {
        switch self {
        case .blue:
            return .blue
        case .red:
            return .red
        case .orange:
            return .orange
        case .yellow:
            return .yellow
        case .green:
            return .green
        case .purple:
            return .purple
        case .pink:
            return .pink
        case .teal:
            return .teal
        case .indigo:
            return .indigo
        case .gray:
            return .gray
        case .default:
            return Color(hex: "68A9F1")
        }
    }
}



extension Color {
    init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        if hexString.count != 6 {
            self.init(.gray)
            return
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}
