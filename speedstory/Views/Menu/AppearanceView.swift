//
//  AppearanceView.swift
//  speedstory
//
//  Created by yury mid on 27.05.2023.
//

import SwiftUI

struct AppearanceView: View {
    @EnvironmentObject var userSettings: UserSettingsManager
    @State private var selectedColor: Colors = .default
    
    @State private var selectedAppIcon: String? = "AppIconDark"

    private let appIcons: [String: String] = [
        "Dark Icon": "AppIconDark",
        "Light Icon": "AppIconLight",
        "Colorful Icon": "AppIconColorful"
    ]

    private let appIconsPreviews: [String] = [
        "Dark Icon",
        "Light Icon",
        "Colorful Icon"
    ]
    
    var body: some View {
        ScrollView {
            HStack{
                Text("appearance_theme")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            HStack {
                Text("appearance_lightmode")
                    .foregroundColor(.primary)
                
                ZStack {
                    
                    HStack {
                        Spacer()
                        
                        Image(systemName: "sun.max.fill")
                            .padding(.trailing, 6)
                            .opacity(userSettings.theme == .light ? 1 : 0)
                        Toggle("", isOn: .init(get: { userSettings.theme == .dark }, set: { newValue in
                            userSettings.theme = newValue ? .dark : .light
                            userSettings.saveSettings()
                        }))
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                        .labelsHidden()

                            
                        
                        Image(systemName: "moon.fill")
                            .padding(.leading, 6)
                            .opacity(userSettings.theme == .dark ? 1 : 0)
                        
                        Spacer()
                    }
                }
                
                Text("appearance_darkmode")
                    .foregroundColor(.primary)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            .padding(.horizontal)

            HStack{
                Text("appearance_accentcolor")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Colors.allCases, id: \.self) { color in
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            selectedColor = color
                            UIApplication.shared.windows.first?.tintColor = UIColor(color.color)
                            userSettings.accentColor = color
                            userSettings.saveSettings()
                        }) {
                            Circle()
                                .fill(color.color)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == color ? Color("TextColor") : Color.clear, lineWidth: 2)
                                )
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
            }
        
            HStack{
                Text("appearance_appicon")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            VStack(spacing: 10) {
                ForEach(appIconsPreviews, id: \.self) { appIconPreview in
                    HStack{
                        Image(appIconPreview)
                            .resizable()
                            .frame(width: 60, height: 60)
                            .cornerRadius(15)
                        Text(appIconPreview)
                            .font(.headline)
                            .padding()
                        Spacer()
                    }
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .cornerRadius(25)
                    .onTapGesture {
                        selectedAppIcon = appIcons[appIconPreview] ?? nil
                        changeAppIcon()
                    }
                }
            }
            .padding(.horizontal)
            
            
         
        }
        .navigationBarTitle("menu_settings_appearance")
        .onAppear{
            selectedColor = userSettings.accentColor
        }
    }
    
    private func changeAppIcon() {
        guard UIApplication.shared.supportsAlternateIcons else {
            return
        }
        
        UIApplication.shared.setAlternateIconName(selectedAppIcon) { error in
            if let error = error {
                print("Error changing app icon: \(error.localizedDescription)")
                selectedAppIcon = nil
                changeAppIcon()
            }
        }
    }
}



struct AppearanceView_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceView()
            .environmentObject(UserSettingsManager.shared)
    }
}
