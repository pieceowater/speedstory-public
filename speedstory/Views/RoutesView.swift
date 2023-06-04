//
//  RoutesView.swift
//  speedstory
//
//  Created by yury mid on 26.05.2023.
//

import SwiftUI

struct RoutesView: View {
    let tool: Tools = Tools()
    @EnvironmentObject var userSettings: UserSettingsManager
    @EnvironmentObject var routeLogger: RouteLogger
    @State private var routes: [Route] = []
    
    @State private var searchText = ""
    @State private var isAscending = false
    
    var filteredRoutes: [Route] {
        if searchText.isEmpty {
            return routes
        } else {
            return routes.filter { $0.name!.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var sortedRoutes: [Route] {
        return filteredRoutes.sorted { route1, route2 in
            if isAscending {
                return route1.createdDate! < route2.createdDate!
            } else {
                return route1.createdDate! > route2.createdDate!
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sortedRoutes, id: \.id) { currentRoute in
                    NavigationLink {
                        RouteView(route: currentRoute)
                            .environmentObject(userSettings)
                            .environmentObject(routeLogger)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(String(format: NSLocalizedString("txt_route", comment: ""))) \(currentRoute.number)")
                                .font(.headline)
                                .foregroundColor(.accentColor)
                            
                            Text(currentRoute.name ?? "--")
                                .font(.subheadline)
                            
                            Text("\(tool.formattedDate(currentRoute.createdDate ?? Date()))")
                                .font(.caption)
                            
                            Text("\(tool.formattedDuration(currentRoute.duration))")
                                .font(.caption)
                        }
                    }
                }
                .onDelete(perform: removeRoute)
            }
            .onAppear {
                routes = routeLogger.routeManager.fetchAllRoutes()
            }
            .refreshable {
                routes = routeLogger.routeManager.fetchAllRoutes()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isAscending.toggle()
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }) {
                        Image(systemName: "arrow.\(isAscending ? "up" : "down")")
                            .resizable()
                            .frame(width: 10, height: 10)
                        Text("txt_sort")
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationBarTitle("title_routes_screen")
        }
    }
    
    private func removeRoute(at offsets: IndexSet) {
        let routesToRemove = offsets.map { sortedRoutes[$0] }
        
        for route in routesToRemove {
            routeLogger.routeManager.deleteRoute(route: route)
            if let index = routes.firstIndex(of: route) {
                routes.remove(at: index)
            }
        }
    }
}




struct RoutesView_Previews: PreviewProvider {
    static var previews: some View {
        RoutesView()
    }
}

