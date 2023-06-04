//
//  ContentView.swift
//  speedstory
//
//  Created by yury mid on 25.05.2023.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var routeLogger: RouteLogger
    @ObservedObject var userSettings: UserSettingsManager

    
    @State private var selectedTab: Tab = .speedometer

    enum Tab {
        case speedometer
        case routes
        case menu
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RoutesView()
                .environmentObject(routeLogger)
                .environmentObject(userSettings)
                .tabItem {
                    Label("routes_tab", systemImage: "map")
                }
                .tag(Tab.routes)
                
            SpeedometerView(speedometerManager: routeLogger.speedometerManager)
                .environmentObject(routeLogger)
                .environmentObject(userSettings)
                .tabItem {
                    Label("speedometer_tab", systemImage: "speedometer")
                }
                .tag(Tab.speedometer)
                
            MenuView()
                .environmentObject(routeLogger)
                .environmentObject(userSettings)
                .tabItem {
                    Label("menu_tab", systemImage: "list.dash")
                }
                .tag(Tab.menu)
            
        }
      
        
    }
   
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(userSettings: UserSettingsManager.shared)
    }
}







