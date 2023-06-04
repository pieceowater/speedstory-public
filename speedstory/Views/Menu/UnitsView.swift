//
//  UnitsView.swift
//  speedstory
//
//  Created by yury mid on 27.05.2023.
//

import SwiftUI

struct UnitsView: View {
    @EnvironmentObject var userSettings: UserSettingsManager
    @State private var selectedUnit: Unit = .kilometersPerHour
    
    var body: some View {
        VStack {
            RadioCard(title: String(format: NSLocalizedString("speed_kmh", comment: "")), isSelected: selectedUnit == .kilometersPerHour) {
                selectedUnit = .kilometersPerHour
                userSettings.units = .kmh
                userSettings.saveSettings()
            }

            RadioCard(title: String(format: NSLocalizedString("speed_mph", comment: "")), isSelected: selectedUnit == .milesPerHour) {
                selectedUnit = .milesPerHour
                userSettings.units = .mph
                userSettings.saveSettings()
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("menu_settings_units")
        .onAppear{
            selectedUnit = userSettings.units == .kmh ? .kilometersPerHour : .milesPerHour
        }
    }
}

enum Unit {
    case kilometersPerHour
    case milesPerHour
}

struct RadioCard: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack{
                Spacer()
                VStack{
                    Spacer()
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                }
                Spacer()
            }
            .padding()
            .foregroundColor(isSelected ? Color.white : Color("TextColor"))
            .background(
                ZStack {
                    if isSelected {
                        Color.accentColor
                        .cornerRadius(20)
                    } else {
                        Color.secondary.opacity(0.2)
                        .cornerRadius(20)
                    }
                }
            )
            .cornerRadius(10)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


struct UnitsView_Previews: PreviewProvider {
    static var previews: some View {
        UnitsView()
    }
}
