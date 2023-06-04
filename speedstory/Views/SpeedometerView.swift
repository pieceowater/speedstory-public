//
//  SpeedometerView.swift
//  speedstory
//
//  Created by yury mid on 26.05.2023.
//

import SwiftUI
import Foundation
import GoogleMobileAds

struct SpeedometerView: View {
    let tool = Tools()
    @EnvironmentObject var routeLogger: RouteLogger
    @EnvironmentObject var userSettings: UserSettingsManager
    @ObservedObject var speedometerManager: SpeedometerManager
    @Environment(\.presentationMode) var presentationMode
    @State private var currentValue: CGFloat = 0.0
    let pointCount = 1000
    let arrowLength: CGFloat = 100
    
    @State private var selectedMode = 1
    private let modes = [String(format: NSLocalizedString("hud_tab", comment: "")), String(format: NSLocalizedString("data_tab", comment: "")), String(format: NSLocalizedString("zen_tab", comment: ""))]
    
    @State private var isShowingZenView = false
    @State private var isShowingHUDView = false
    
    @State private var showAlert = false

    var body: some View {
        ScrollView{
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
                }
                .padding()
                
                Spacer(minLength: 90)
                HStack{
                    Text("\(Int(userSettings.units == .kmh ? speedometerManager.speedKMH : speedometerManager.speedMPH))")
                        .font(.system(size: 120, weight: .bold))
                        .foregroundColor(.accentColor)
                    Text(userSettings.units == .kmh ? "speed_kmh" : "speed_mph")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.accentColor)
                }
                
                Spacer(minLength: 90)

                VStack{
                    Picker(selection: $selectedMode, label: Text("tab_mode")) {
                        ForEach(0..<modes.count) { index in
                            Text(modes[index])
                                .tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedMode) { newValue in
                        if newValue == 2 {
                            isShowingZenView = true
                            isShowingHUDView = false
                        } else if newValue == 1 {
                            isShowingHUDView = false
                            isShowingZenView = false
                        } else if newValue == 0 {
                            isShowingHUDView = true
                            isShowingZenView = false
                        }
                    }
                    
                    HStack{
                        VStack(alignment: .leading){
                            Text("card_max")
                                .font(.title3)
                            HStack{
                                Text((!routeLogger.isLogging && routeLogger.isPaused) ? "\(tool.convertedSpeed(units: userSettings.units, speedMS: routeLogger.routeManager.getLastRouteMaxSpeed() ?? 0))" : "\(tool.convertedSpeed(units: userSettings.units, speedMS: routeLogger.currentMaxSpeed))")
                                    .font(.title)
                                Text(userSettings.units == .kmh ? "speed_kmh" : "speed_mph")
                                Spacer()
                            }.foregroundColor(.accentColor)
                        }.padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(15)
                        
                        Spacer()
                        
                        VStack(alignment: .leading){
                            Text("card_avg")
                                .font(.title3)
                            HStack{
                                Text((!routeLogger.isLogging && routeLogger.isPaused) ? "\(tool.convertedSpeed(units: userSettings.units, speedMS: routeLogger.routeManager.getLastRouteAvgSpeed() ?? 0))" : "\(tool.convertedSpeed(units: userSettings.units, speedMS: routeLogger.currentAvgSpeed))")
                                    .font(.title)
                                Text(userSettings.units == .kmh ? "speed_kmh" : "speed_mph")
                                Spacer()
                            }.foregroundColor(.accentColor)
                        }.padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(15)
                    }
                    
                    HStack{
                        VStack(alignment: .leading){
                            Text("card_distance")
                                .font(.title3)
                            HStack{
                                Text((!routeLogger.isLogging && routeLogger.isPaused) ? "\(tool.convertedDistance(units: userSettings.units, distanceM: routeLogger.routeManager.getLastRouteDistance() ?? 0))" : "\(tool.convertedDistance(units: userSettings.units, distanceM: routeLogger.currentDistance))")
                                    .font(.title)
                                Text(userSettings.units == .kmh ? "unit_km" : "unit_miles")
                                Spacer()
                            }.foregroundColor(.accentColor)
                        }.padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(15)
                        
                        Spacer()
                        
                        VStack(alignment: .leading){
                            Text("card_time")
                                .font(.title3)
                            HStack{
                                Text((!routeLogger.isLogging && routeLogger.isPaused) ? "\(tool.formattedDuration(routeLogger.routeManager.getLastRouteDuration() ?? TimeInterval()))" : "\(tool.formattedDuration(routeLogger.routeDuration))")
                                    .font(.title)
                                Spacer()
                            }.foregroundColor(.accentColor)
                        }.padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(15)
                    }
                    
                    
                }
                .padding()
                .padding(.bottom)
        }
        .overlay(alignment: .bottom, content: {
            if (!routeLogger.isLogging && routeLogger.isPaused) {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    routeLogger.startRoute()
                } label: {
                    HStack{
                        Spacer()
                        Text("btn_start_trip")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(15)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .padding(.horizontal)
                    .padding(.bottom, 3)
                }
            } else {
                HStack{
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        routeLogger.pauseRoute()
                    } label: {
                        HStack{
                            Spacer()
                            Image(systemName: routeLogger.isPaused ? "play.fill" : "pause.fill")
                            Text( routeLogger.isPaused ? "btn_resume_trip" : "btn_pause_trip")
                                .font(.headline)
                            Spacer()
                        }
                        .padding(15)
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                        .padding(.bottom, 3)
                    }
                    
                    Spacer()
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        showAlert = true
                    } label: {
                        HStack{
                            Spacer()
                            Text("btn_end_trip")
                                .font(.headline)
                            Spacer()
                        }
                        .padding(15)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .padding(.bottom, 3)
                    }
                }.padding(.horizontal)
            }
        })
        .fullScreenCover(isPresented: $isShowingZenView) {
            ZenView(selectedMode: $selectedMode, speedometerManager: routeLogger.speedometerManager)
                .environmentObject(userSettings)
                .edgesIgnoringSafeArea(.all)
                .accentColor(userSettings.accentColor.color)
        }
        .fullScreenCover(isPresented: $isShowingHUDView) {
            HUDView(selectedMode: $selectedMode, speedometerManager: routeLogger.speedometerManager)
                .environmentObject(userSettings)
                .edgesIgnoringSafeArea(.all)
                .accentColor(userSettings.accentColor.color)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("alert_confirm"),
                message: Text("alert_sure_msg"),
                primaryButton: .destructive(Text("alert_end_btn"), action: {
                    routeLogger.endRoute()
                    presentationMode.wrappedValue.dismiss()
                }),
                secondaryButton: .cancel()
            )
        }
    }
}



struct SpeedometerView_Previews: PreviewProvider {
    static var previews: some View {
        SpeedometerView(speedometerManager: SpeedometerManager())
            .environmentObject(RouteLogger(routeManager: RouteManager(), speedometerManager: SpeedometerManager()))
            .environmentObject(UserSettingsManager.shared)
    }
}

