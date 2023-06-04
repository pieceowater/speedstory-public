//
//  RouteEditingView.swift
//  speedstory
//
//  Created by yury mid on 30.05.2023.
//

import SwiftUI

struct RouteEditingView: View {
    @State var route: Route
    @EnvironmentObject var routeLogger: RouteLogger
    @Environment(\.presentationMode) var presentationMode
    @State private var newRouteName: String = ""
    var body: some View {
        VStack(alignment: .leading){
            Text("\(String(format: NSLocalizedString("txt_edit", comment: ""))) \(String(format: NSLocalizedString("txt_route", comment: "")))")
                .font(.title)
                .padding(.vertical)
            
            TextField("\(route.name ?? "")", text: $newRouteName)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .padding(.bottom)
            
            Button {
                routeLogger.routeManager.updateRoute(route: route, name: newRouteName)
                presentationMode.wrappedValue.dismiss()
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } label: {
                HStack{
                    Spacer()
                    Text("\(String(format: NSLocalizedString("txt_rename", comment: "")))!")
                    Spacer()
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .padding()
                .background(Color.accentColor.opacity(0.9))
                .cornerRadius(15)
            }
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                presentationMode.wrappedValue.dismiss()
            } label: {
                HStack{
                    Spacer()
                    Text("txt_close")
                    Spacer()
                }
                .font(.subheadline)
                .padding()
            }
            

            Spacer()
        }
        .padding()
        .onAppear{
            newRouteName = route.name ?? ""
        }
    }
}

//struct RouteEditingViewView_Previews: PreviewProvider {
//    static var previews: some View {
//        return RouteEditingView()
//    }
//}
