//
//  speedstoryApp.swift
//  speedstory
//
//  Created by yury mid on 25.05.2023.
//

import SwiftUI
import UIKit
//import GoogleMobileAds
//import UIKit

@main
struct speedstoryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject var userSettings = UserSettingsManager.shared
    @ObservedObject var routeLogger: RouteLogger = RouteLogger(routeManager: RouteManager(), speedometerManager: SpeedometerManager())
    @Environment(\.colorScheme) private var colorScheme

//    private var rewardedAd: GADRewardedAd?
    
    var body: some Scene {
        WindowGroup {
            ContentView(userSettings: userSettings)
                .environmentObject(routeLogger)
                .accentColor(userSettings.accentColor.color)
                .preferredColorScheme(userSettings.theme == .dark ? .dark : .light)
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true
                }
                .onDisappear {
                    UIApplication.shared.isIdleTimerDisabled = false
                }
        }
    }
    
//    func loadRewardedAd() {
//        let request = GADRequest()
//        GADRewardedAd.load(withAdUnitID:"ca-app-pub-3940256099942544/1712485313",
//                           request: request,
//                           completionHandler: { [self] ad, error in
//          if let error = error {
//            print("Failed to load rewarded ad with error: \(error.localizedDescription)")
//            return
//          }
//            self.rewardedAd = ad
//          print("Rewarded ad loaded.")
//        }
//        )
//      }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Disable idle timer when the app becomes active (in the foreground)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Enable idle timer when the app resigns active (goes to background)
        UIApplication.shared.isIdleTimerDisabled = false
    }
}
