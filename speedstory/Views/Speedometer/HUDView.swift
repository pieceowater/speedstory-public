//
//  HUDView.swift
//  speedstory
//
//  Created by yury mid on 28.05.2023.
//

import SwiftUI

struct HUDView: View {
    @EnvironmentObject var userSettings: UserSettingsManager
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedMode: Int
    @ObservedObject var speedometerManager: SpeedometerManager
    
    var body: some View {
        ZenView(selectedMode: $selectedMode, speedometerManager: speedometerManager)
            .environmentObject(userSettings)
            .scaleEffect(x: -1, y: 1)
    }
}

struct HUDView_Previews: PreviewProvider {
    static var previews: some View {
        HUDView(selectedMode: .constant(0), speedometerManager: SpeedometerManager())
    }
}
