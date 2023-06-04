//
//  MenuView.swift
//  speedstory
//
//  Created by yury mid on 26.05.2023.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject var userSettings: UserSettingsManager
    @EnvironmentObject var routeLogger: RouteLogger
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("menu_heading_settings")) {
                    NavigationLink(destination: DataView().environmentObject(routeLogger).environmentObject(userSettings)) {
                        LinkCardView(icon: "chart.bar", title: String(format: NSLocalizedString("menu_settings_data", comment: "")))
                    }
                    NavigationLink(destination: UnitsView().environmentObject(userSettings)) {
                        LinkCardView(icon: "scalemass", title: String(format: NSLocalizedString("menu_settings_units", comment: "")))
                    }
                    NavigationLink(destination: LanguageView()) {
                        LinkCardView(icon: "globe", title: String(format: NSLocalizedString("menu_settings_language", comment: "")))
                    }
                    NavigationLink(destination: AppearanceView().environmentObject(userSettings)) {
                        LinkCardView(icon: "paintbrush", title: String(format: NSLocalizedString("menu_settings_appearance", comment: "")))
                    }
                }
                
                Section(header: Text("menu_heading_actions")) {
                    LinkButtonView(title: String(format: NSLocalizedString("menu_actions_pro_mode", comment: "")))
                    LinkButtonView(title: String(format: NSLocalizedString("menu_actions_rate", comment: "")))
                    NavigationLink(destination: AboutView()) {
                        LinkButtonView(title: String(format: NSLocalizedString("menu_actions_about", comment: "")))
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("title_menu_screen")
        }
    }
}

struct LinkCardView: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 40, height: 40)
            Text(title)
                .font(.headline)
        }
    }
}

struct LinkButtonView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.accentColor)
    }
}


struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
            .environmentObject(UserSettingsManager.shared)
    }
}
