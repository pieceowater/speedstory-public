//
//  RouteView.swift
//  speedstory
//
//  Created by yury mid on 28.05.2023.
//

import SwiftUI
import MapKit

struct RouteView: View {
    let tool: Tools = Tools()
    @State var route: Route
    @EnvironmentObject var routeLogger: RouteLogger
    @EnvironmentObject var userSettings: UserSettingsManager
    @Environment(\.presentationMode) var presentationMode

    @State private var isEditRouteNameShowing: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                if let coordinatesRelationship = route.coordinates, let coordinates = coordinatesRelationship.allObjects as? [Coordinate], !coordinates.isEmpty {
                    let validCoordinates = coordinates.compactMap { coordinate -> MapCoord? in
                        let latitude = coordinate.latitude
                        let longitude = coordinate.longitude
                        let date = coordinate.date ?? Date()
                        return MapCoord(latitude: latitude, longitude: longitude, date: date)
                    }

                    if !validCoordinates.isEmpty {
                        MapView(coordinates: validCoordinates)
                            .edgesIgnoringSafeArea(.all)
                            .frame(height: 500)
                    }
                }


                VStack(alignment: .leading) {
                    HStack{
                        Text("\(String(format: NSLocalizedString("txt_route", comment: ""))) \(route.number)")
                            .font(.subheadline)
                            .foregroundColor(.accentColor)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.up")
                    }
                    
                    Text(route.name ?? "")
                        .font(.title)
                        .padding(.bottom, 5)
                    
                    Text("\(String(format: NSLocalizedString("txt_created", comment: ""))): \(tool.formattedDate(route.createdDate ?? Date()))")
                        .font(.caption)
                    
                    
                    Divider()
                        .padding(.vertical)
                    
                    VStack{
                        HStack{
                            VStack(alignment: .leading){
                                Text("card_max")
                                    .font(.title3)
                                HStack{
                                    Text("\(tool.convertedSpeed(units: userSettings.units, speedMS: route.maxSpeed))")
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
                                    Text("\(tool.convertedSpeed(units: userSettings.units, speedMS: route.avgSpeed))")
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
                                    Text("\(tool.convertedDistance(units: userSettings.units, distanceM: route.distance))")
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
                                    Text("\(tool.formattedDuration(route.duration))")
                                        .font(.title)
                                    Spacer()
                                }.foregroundColor(.accentColor)
                            }.padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(15)
                        }
                    }
                    
                    Divider()
                        .padding(.vertical)
                    
                    VStack{
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            isEditRouteNameShowing = true
                        } label: {
                            HStack{
                                Spacer()
                                Image(systemName: "pencil")
                                Text("txt_rename")
                                Spacer()
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.accentColor.opacity(0.9))
                            .cornerRadius(15)
                        }
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            routeLogger.routeManager.deleteRoute(route: route)
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            HStack{
                                Image(systemName: "trash.fill")
                                Text("txt_remove")
                            }
                            .font(.subheadline)
                            .foregroundColor(Color.red)
                            .padding()
                        }
                    }
                    
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
        }
        .navigationBarTitle("\(String(format: NSLocalizedString("txt_route", comment: ""))) \(route.number)")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isEditRouteNameShowing) {
            RouteEditingView(route: route)
                .environmentObject(routeLogger)
        }
    }
}


struct MapView: UIViewRepresentable {
    let coordinates: [MapCoord]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true

        let stackView = UIStackView(arrangedSubviews: [MKUserTrackingButton(mapView: mapView)])
        stackView.axis = .vertical
        stackView.alignment = .trailing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -15),
            stackView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30)
        ])

        addPolyline(to: mapView)

        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        view.removeOverlays(view.overlays)
        addPolyline(to: view)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else {
                return MKOverlayRenderer()
            }

            let renderer = MKPolylineRenderer(overlay: polyline)
            renderer.strokeColor = .red
            renderer.lineWidth = 3
            return renderer
        }
    }

    private func addPolyline(to mapView: MKMapView) {
        guard !coordinates.isEmpty else {
            return
        }
        
        var polylineCoordinates: [CLLocationCoordinate2D] = []
        
        let sortedCoordinates = coordinates.sorted(by: { $0.date < $1.date })
        
        for (index, coordinate) in sortedCoordinates.enumerated() {
            if index % 5 == 0 {
                polylineCoordinates.append(CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))
                let polyline = MKPolyline(coordinates: polylineCoordinates, count: polylineCoordinates.count)
                mapView.addOverlay(polyline)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: true)
                }
            }
        }
    }

}


/*
struct MapView: UIViewRepresentable {
    let coordinates: [MapCoord]
    

    func makeUIView(context: Context) -> MKMapView {
        print(coordinates)
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true

        let stackView = UIStackView(arrangedSubviews: [MKUserTrackingButton(mapView: mapView)])
        stackView.axis = .vertical
        stackView.alignment = .trailing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -15),
            stackView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -30)
        ])

        addPolyline(to: mapView)
        setMapViewRegion(for: mapView, with: coordinates)

        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        view.removeOverlays(view.overlays)
        addPolyline(to: view)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else {
                return MKOverlayRenderer()
            }

            let renderer = MKPolylineRenderer(overlay: polyline)
            renderer.strokeColor = .red
            renderer.lineWidth = 3
            return renderer
        }
    }

    
    private func addPolyline(to mapView: MKMapView) {
        /*
        let coordinates12: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 37.45721393, longitude: -122.28861267),
            CLLocationCoordinate2D(latitude: 37.45696847, longitude: -122.28836834),
            CLLocationCoordinate2D(latitude: 37.45488322, longitude: -122.28547306),
            CLLocationCoordinate2D(latitude: 37.45607437, longitude: -122.28728422),
            CLLocationCoordinate2D(latitude: 37.45672979, longitude: -122.28811109),
            CLLocationCoordinate2D(latitude: 37.45567627, longitude: -122.28668651),
            CLLocationCoordinate2D(latitude: 37.45587534, longitude: -122.28698641),
            CLLocationCoordinate2D(latitude: 37.45527792, longitude: -122.28607664),
            CLLocationCoordinate2D(latitude: 37.45508011, longitude: -122.28577665),
            CLLocationCoordinate2D(latitude: 37.4546849, longitude: -122.28517332),
        ]
        let coordinates7: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 37.3307498, longitude: -122.03054302),
            CLLocationCoordinate2D(latitude: 37.33138305, longitude: -122.03075743),
            CLLocationCoordinate2D(latitude: 37.33128013, longitude: -122.03073774),
            CLLocationCoordinate2D(latitude: 37.3304353, longitude: -122.02993796),
            CLLocationCoordinate2D(latitude: 37.33170303, longitude: -122.03024001),
            CLLocationCoordinate2D(latitude: 37.33154242, longitude: -122.0307334),
            CLLocationCoordinate2D(latitude: 37.33069279, longitude: -122.02906734),
            CLLocationCoordinate2D(latitude: 37.33031658, longitude: -122.02908956),
            CLLocationCoordinate2D(latitude: 37.33178632, longitude: -122.0306262),
            CLLocationCoordinate2D(latitude: 37.33069543, longitude: -122.02933632),
            CLLocationCoordinate2D(latitude: 37.33138836, longitude: -122.03072798),
            CLLocationCoordinate2D(latitude: 37.33070167, longitude: -122.02952527),
            CLLocationCoordinate2D(latitude: 37.33084313, longitude: -122.03058427),
            CLLocationCoordinate2D(latitude: 37.33067784, longitude: -122.02998825),
            CLLocationCoordinate2D(latitude: 37.33045921, longitude: -122.03036811),
            CLLocationCoordinate2D(latitude: 37.33091383, longitude: -122.03061321),
            CLLocationCoordinate2D(latitude: 37.33047789, longitude: -122.02870208),
            CLLocationCoordinate2D(latitude: 37.33131185, longitude: -122.03075659),
            CLLocationCoordinate2D(latitude: 37.33047387, longitude: -122.03043177),
            CLLocationCoordinate2D(latitude: 37.33085898, longitude: -122.03075862),
            CLLocationCoordinate2D(latitude: 37.330648, longitude: -122.02900846),
            CLLocationCoordinate2D(latitude: 37.33176143, longitude: -122.03066394),
            CLLocationCoordinate2D(latitude: 37.33039971, longitude: -122.02856703),
            CLLocationCoordinate2D(latitude: 37.33070456, longitude: -122.02910692),
            CLLocationCoordinate2D(latitude: 37.33059652, longitude: -122.02895228),
            CLLocationCoordinate2D(latitude: 37.33051217, longitude: -122.03054075),
            CLLocationCoordinate2D(latitude: 37.33068906, longitude: -122.02976028),
            CLLocationCoordinate2D(latitude: 37.3316045, longitude: -122.03041139),
            CLLocationCoordinate2D(latitude: 37.3304198, longitude: -122.02859976),
            CLLocationCoordinate2D(latitude: 37.33108059, longitude: -122.03068245),
            CLLocationCoordinate2D(latitude: 37.3303672, longitude: -122.02923067),
            CLLocationCoordinate2D(latitude: 37.33067186, longitude: -122.03002927),
            CLLocationCoordinate2D(latitude: 37.33104629, longitude: -122.03067027),
            CLLocationCoordinate2D(latitude: 37.33144466, longitude: -122.03075535),
            CLLocationCoordinate2D(latitude: 37.33067203, longitude: -122.03018068),
            CLLocationCoordinate2D(latitude: 37.33131509, longitude: -122.03073779),
            CLLocationCoordinate2D(latitude: 37.33065643, longitude: -122.03064682),
            CLLocationCoordinate2D(latitude: 37.33092521, longitude: -122.03077056),
            CLLocationCoordinate2D(latitude: 37.33056973, longitude: -122.0288791),
            CLLocationCoordinate2D(latitude: 37.33043145, longitude: -122.03009112)
        ]
        */
        guard !coordinates.isEmpty else {
            return
        }
        
        var polylineCoordinates: [CLLocationCoordinate2D] = []
//
        for coordinate in coordinates {
//            print("\(coordinate.latitude), \(coordinate.longitude)")
            polylineCoordinates.append(coordinate)
        }
        
        let polyline = MKPolyline(coordinates: polylineCoordinates, count: polylineCoordinates.count)
        mapView.addOverlay(polyline)
    }
     

    
//    private func addPolyline(to mapView: MKMapView) {
//        guard let firstCoordinate = coordinates.first else {
//            return
//        }
//
//        var previousCoordinate = firstCoordinate
//
//        for i in 1..<coordinates.count {
//            let coordinate = coordinates[i]
//
//            let sourcePlacemark = MKPlacemark(coordinate: previousCoordinate)
//            let destinationPlacemark = MKPlacemark(coordinate: coordinate)
//
//            let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
//            let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
//
//            let directionRequest = MKDirections.Request()
//            directionRequest.source = sourceMapItem
//            directionRequest.destination = destinationMapItem
//            directionRequest.transportType = .automobile
//
//            let directions = MKDirections(request: directionRequest)
//            directions.calculate { (response, error) in
//                guard let response = response, let route = response.routes.first else {
//                    return
//                }
//
//                mapView.addOverlay(route.polyline)
//            }
//
//            previousCoordinate = coordinate
//        }
//    }



    private func setMapViewRegion(for mapView: MKMapView, with coordinates: [CLLocationCoordinate2D]) {
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        let polylineRegion = polyline.boundingMapRect
        mapView.setVisibleMapRect(polylineRegion, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: true)
    }
}
*/

