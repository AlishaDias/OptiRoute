import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @State private var startLocation = ""
    @State private var endLocation = ""
    @State private var searchFields = [String]()
    @State private var results = [MKMapItem]()
    @State private var mapSelection: MKMapItem?
    @State private var showDetails = false
    @State private var getDirections = false
    @State private var routeDisplaying = false
    @State private var totalTravelTime: TimeInterval = 0
    @State private var totalDistance: CLLocationDistance = 0
    @State private var routes: [MKRoute] = []
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
    @State private var showRouteDetails = false
    @ObservedObject var viewModel: DeliveryViewModel
    @FocusState private var focusedField: Int?
    @StateObject private var locationManager = LocationManager()
    var onDone: () -> Void

    var body: some View {
        VStack {
            Map(position: $cameraPosition, selection: $mapSelection) {
                Marker("My location", coordinate: .userLocation).tint(.blue)
                
                if let startMapItem = results.first {
                    let placemark = startMapItem.placemark
                    Marker("Start: \(placemark.name ?? "")", coordinate: placemark.coordinate).tint(.blue)
                }
                
                ForEach(results.dropFirst().dropLast(), id: \.self) { item in
                    let placemark = item.placemark
                    Marker("Stop: \(placemark.name ?? "")", coordinate: placemark.coordinate).tint(.blue)
                }
                
                if let endMapItem = results.last {
                    let placemark = endMapItem.placemark
                    Marker("End: \(placemark.name ?? "")", coordinate: placemark.coordinate).tint(.red)
                }
                
                ForEach(routes, id: \.self) { route in
                    MapPolyline(route.polyline)
                        .stroke(.blue, lineWidth: 6)
                }
            }
            .overlay(alignment: .top) {
                VStack {
                    TextField("Start Location", text: $startLocation)
                        .font(.subheadline)
                        .padding(12)
                        .background(Color.white)
                        .shadow(radius: 10)
                        .padding(.bottom, 5)
                        .focused($focusedField, equals: 0)
                        .onChange(of: locationManager.currentLocation) { newLocation in
                            if let newLocation = newLocation {
                                updateStartLocation(newLocation)
                            }
                        }
                    
                    TextField("End Location", text: $endLocation)
                        .font(.subheadline)
                        .padding(12)
                        .background(Color.white)
                        .shadow(radius: 10)
                        .padding(.bottom, 5)
                        .focused($focusedField, equals: 1)
                    
                    ForEach($searchFields.indices, id: \.self) { index in
                        TextField("Search for location...", text: $searchFields[index])
                            .font(.subheadline)
                            .padding(12)
                            .background(Color.white)
                            .shadow(radius: 10)
                            .padding(.bottom, 5)
                            .focused($focusedField, equals: index + 2)
                    }
                    
                    HStack {
                        Button(action: {
                            searchFields.append("")
                            focusedField = searchFields.count + 1
                        }) {
                            Text("Add Stops")
                        }
                        .buttonStyle(CustomButtonStyle(backgroundColor: .orange, foregroundColor: .white, cornerRadius: 10))
                        .padding(.top, 10)
                        
                        Button(action: {
                            print("Get Directions button pressed")
                            Task {
                                await fetchRouteForMultipleDestinations()
                            }
                        }) {
                            Text("Get Directions")
                        }
                        .buttonStyle(CustomButtonStyle(backgroundColor: .orange, foregroundColor: .white, cornerRadius: 10))
                        .padding(.top, 10)
                    }
                }
                .padding()
            }
            .onChange(of: getDirections) { oldValue, newValue in
                if newValue {
                    fetchRoute()
                }
            }
            .onChange(of: mapSelection) { oldValue, newValue in
                showDetails = newValue != nil
            }
            .onChange(of: viewModel.acceptedAddresses) { _ in
                updateMapItems()
            }
            .sheet(isPresented: $showDetails) {
                LocationDetailsView(mapSelection: $mapSelection, getDirections: $getDirections, show: $showDetails)
                    .presentationDetents([.height(340)])
                    .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
                    .presentationCornerRadius(12)
            }
            .mapControls {
                MapCompass()
                MapPitchToggle()
                MapUserLocationButton()
            }

            if routeDisplaying {
                VStack {
                    Text("Total Travel Time: \(formattedTravelTime)")
                        .padding()
                        .foregroundColor(.black)
                        .cornerRadius(10)
                    
                    Text("Total Distance: \(formattedDistance)")
                        .foregroundColor(.black)
                        .cornerRadius(10)
                    
                    Button(action: {
                        showRouteDetails.toggle()
                    }) {
                        Text("View Route Details")
                    }
                    .buttonStyle(CustomButtonStyle(backgroundColor: .white, foregroundColor: .orange, cornerRadius: 10))
                    .padding(.top, 10)
                    .sheet(isPresented: $showRouteDetails) {
                        RouteDetailsView(routes: routes, totalTravelTime: totalTravelTime)
                    }
                }
            }

            Button(action: onDone) {
                Text("Done")
            }
            .buttonStyle(CustomButtonStyle(backgroundColor: .white, foregroundColor: .blue, cornerRadius: 10))
        }
        .onAppear {
            locationManager.requestLocation()
        }
    }
    
    private func updateStartLocation(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Error reverse geocoding location: \(error.localizedDescription)")
                return
            }
            if let placemark = placemarks?.first {
                startLocation = [placemark.name, placemark.locality, placemark.administrativeArea, placemark.country]
                    .compactMap { $0 }
                    .joined(separator: ", ")
            }
        }
    }
    
    private func updateMapItems() {
        viewModel.getCoordinates(addresses: viewModel.acceptedAddresses) { mapItems in
            self.results = mapItems
        }
    }
    
    private func fetchRouteForMultipleDestinations() async {
        print("Fetching routes for multiple destinations")
        var mapItems = [MKMapItem]()
        
        print("Number of search fields: \(searchFields.count)")
        
        if let startMapItem = await searchForAddress(startLocation) {
            mapItems.append(startMapItem)
        }
        
        for address in searchFields {
            if let mapItem = await searchForAddress(address) {
                mapItems.append(mapItem)
            }
        }
        
        if let endMapItem = await searchForAddress(endLocation) {
            mapItems.append(endMapItem)
        }
        
        guard mapItems.count > 1 else {
            print("Not enough locations found for routing")
            return
        }
        
        results = mapItems

        let directionsRequests = mapItems.indices.dropFirst().map { index in
            let request = MKDirections.Request()
            request.source = mapItems[index - 1]
            request.destination = mapItems[index]
            return request
        }
        
        var routes = [MKRoute]()
        totalTravelTime = 0
        totalDistance = 0
        
        for request in directionsRequests {
            do {
                let directions = MKDirections(request: request)
                let response = try await directions.calculate()
                if let route = response.routes.first {
                    routes.append(route)
                    totalTravelTime += route.expectedTravelTime
                    totalDistance += route.distance
                    print("Route calculated for request: \(request)")
                } else {
                    print("No routes found for request: \(request)")
                }
            } catch {
                print("Error calculating route: \(error.localizedDescription)")
            }
        }
        
        if !routes.isEmpty {
            var boundingMapRect = MKMapRect.null
            for route in routes {
                boundingMapRect = boundingMapRect.union(route.polyline.boundingMapRect)
            }
            
            withAnimation(.snappy) {
                routeDisplaying = true
                cameraPosition = .rect(boundingMapRect)
                self.routes = routes
            }
        } else {
            print("No routes found")
        }
    }

    private func searchForAddress(_ address: String) async -> MKMapItem? {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = address
        request.region = .userRegion
        do {
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            return response.mapItems.first
        } catch {
            print("Error searching for address \(address): \(error.localizedDescription)")
            return nil
        }
    }

    private var formattedTravelTime: String {
        let hours = Int(totalTravelTime) / 3600
        let minutes = (Int(totalTravelTime) % 3600) / 60
        return "\(hours) hours \(minutes) minutes"
    }

    private var formattedDistance: String {
        let miles = totalDistance / 1609.34 // Convert meters to miles
        return String(format: "%.2f miles", miles)
    }
}

extension ContentView {
    func fetchRoute() {
        if let mapSelection {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: .init(coordinate: .userLocation))
            request.destination = mapSelection
            
            Task {
                do {
                    let result = try await MKDirections(request: request).calculate()
                    if let route = result.routes.first {
                        withAnimation(.snappy) {
                            routeDisplaying = true
                            self.routes = [route]
                            totalTravelTime = route.expectedTravelTime
                            totalDistance = route.distance
                            let rect = route.polyline.boundingMapRect
                            cameraPosition = .rect(rect)
                        }
                    }
                    else {
                        print("No route found for selected destination")
                    }
                } catch {
                    print("Error fetching route: \(error.localizedDescription)")
                }
            }
        }
    }
}

extension CLLocationCoordinate2D {
    static var userLocation: CLLocationCoordinate2D {
        return .init(latitude: 41.87747, longitude: -87.62721)
    }
}

extension MKCoordinateRegion {
    static var userRegion: MKCoordinateRegion {
        return .init(center: .userLocation, latitudinalMeters: 500, longitudinalMeters: 500)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: DeliveryViewModel(), onDone: {})
    }
}

struct CustomButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var foregroundColor: Color
    var cornerRadius: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        currentLocation = location
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
}
