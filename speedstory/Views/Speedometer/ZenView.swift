//
//  ZenView.swift
//  speedstory
//
//  Created by yury mid on 28.05.2023.
//

import SwiftUI

struct ZenView: View {
    let tool: Tools = Tools()
    @EnvironmentObject var userSettings: UserSettingsManager
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedMode: Int
    @ObservedObject var speedometerManager: SpeedometerManager
    
    var body: some View {
        NavigationView {
            VStack{
                Spacer()
                
                HStack{
                    Text("\(Int(userSettings.units == .kmh ? speedometerManager.speedKMH : speedometerManager.speedMPH))")
                        .font(.system(size: 140, weight: .bold))
                        .foregroundColor(.accentColor)
                    Text(userSettings.units == .kmh ? "\(String(format: NSLocalizedString("speed_kmh", comment: "")))" : "\(String(format: NSLocalizedString("speed_mph", comment: "")))")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.accentColor)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.accentColor)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(speedometerManager.streetName == "" ? "--" : speedometerManager.streetName)
                            .font(.headline)
                        Text("Lat: \(tool.formattedCoordinate(speedometerManager.userLocation?.coordinate.latitude)), Lon: \(tool.formattedCoordinate(speedometerManager.userLocation?.coordinate.longitude))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }.padding()
            }
            .navigationBarItems(trailing: Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                presentationMode.wrappedValue.dismiss()
                selectedMode = 1
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.primary.opacity(0.5))
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
            })
        }
    }
}


struct ZenView_Previews: PreviewProvider {
    static var previews: some View {
        ZenView(selectedMode: .constant(2), speedometerManager: SpeedometerManager())
    }
}
