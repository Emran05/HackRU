import SwiftUI
import MapKit
import CoreLocation

struct SetDestinationView: View {
    @State private var showAlert = false
    @State private var alarmRadius: String = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.4862, longitude: -74.4518),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var userLocation: CLLocationCoordinate2D?
    @State private var isAlarmSet = false
    private let locationManager = CLLocationManager()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .padding(.top, 20)

            // Interactive Map with Pin Drop Feature
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, annotationItems: [UserLocationAnnotation(coordinate: region.center)]) { place in
                MapPin(coordinate: place.coordinate, tint: .red)
            }
            .frame(height: 300)
            .cornerRadius(10)
            .padding(.horizontal, 20)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
            .onAppear {
                setupLocation()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Set Alarm Radius")
                    .font(.headline)
                    .foregroundColor(.orange)
                TextField("Enter radius (meters)...", text: $alarmRadius)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 10)
            }
            .padding(.horizontal, 20)

            // Set Alarm Button with Pop-up Alert
            Button(action: {
                isAlarmSet = true
                showAlert = true
            }) {
                Text("Set Alarm")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(10)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Alarm Set"), message: Text("Your alarm has been successfully set!"), dismissButton: .default(Text("OK")))
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)

            // Navigation Button to Alarm Screen
            if isAlarmSet {
                NavigationLink(destination: AlarmScreen().navigationBarBackButtonHidden(true)) {
                    Text("Go to Alarm Screen")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
            }
            Spacer()
        }
    }

    private func setupLocation() {
        locationManager.requestWhenInUseAuthorization()
        if let currentLocation = locationManager.location?.coordinate {
            self.userLocation = currentLocation
            self.region.center = currentLocation
        }
    }
}

struct UserLocationAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
