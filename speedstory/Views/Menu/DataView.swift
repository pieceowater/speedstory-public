//
//  DataView.swift
//  speedstory
//
//  Created by yury mid on 27.05.2023.
//

import SwiftUI

struct DataView: View {
    let tool: Tools = Tools()
    @EnvironmentObject var routeLogger: RouteLogger
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userSettings: UserSettingsManager

    @State private var showAlert = false

    var body: some View {
        ScrollView {
            VStack {
                HStack{
                    Text("data_stats")
                        .font(.title2)
                        .padding(.top)
                    Spacer()
                }
                HStack{
                    VStack(alignment: .leading){
                        Text("card_max")
                            .font(.title3)
                        HStack{
                            Text("\(tool.convertedSpeed(units: userSettings.units, speedMS: routeLogger.routeManager.getMaxSpeed()))")
                                .font(.title)
                            Text("\(userSettings.units == .kmh ? String(format: NSLocalizedString("speed_kmh", comment: "")) : String(format: NSLocalizedString("speed_mph", comment: "")))")
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
                            Text("\(tool.convertedSpeed(units: userSettings.units, speedMS: routeLogger.routeManager.getAverageSpeed()))")
                                .font(.title)
                            Text("\(userSettings.units == .kmh ? String(format: NSLocalizedString("speed_kmh", comment: "")) : String(format: NSLocalizedString("speed_mph", comment: "")))")
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
                            Text("\(tool.convertedDistance(units: userSettings.units, distanceM: routeLogger.routeManager.getDistanceSum()))")
                                .font(.title)
                            Text(userSettings.units == .kmh ? String(format: NSLocalizedString("unit_km", comment: "")) : String(format: NSLocalizedString("unit_miles", comment: "")))
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
                            Text("\(tool.formattedDuration(routeLogger.routeManager.getDurationSum()))")
                                .font(.title)
                            Spacer()
                        }.foregroundColor(.accentColor)
                    }.padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                }
                
                HStack{
                    Text("data_dangerzone")
                        .font(.title2)
                        .padding(.top)
                        .foregroundColor(.red)
                    Spacer()
                }
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    showAlert = true
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "trash.fill")
                        Text("data_rmall")
                        Spacer()
                    }
                    .font(.subheadline)
                    .foregroundColor(Color.red)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                }
            }
            .navigationTitle("menu_settings_data")
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("alert_confirm"),
                    message: Text("alert_sure_msg"),
                    primaryButton: .destructive(Text("alert_rm_btn"), action: {
                        routeLogger.routeManager.removeAllRoutes()
                        presentationMode.wrappedValue.dismiss()
                    }),
                    secondaryButton: .cancel()
                )
            }
        }
    }
}


struct DataView_Previews: PreviewProvider {
    static var previews: some View {
        DataView()
    }
}
