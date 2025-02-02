import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    
    // The coordinate chosen by the user to monitor
    @State private var chosenCoordinate = CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090)
    // Controls the presentation of the location picker
    @State private var showPicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Region Monitoring")
                .font(.title)
                .padding(.top)
            
            // MARK: - Authorization Status
            Text("Authorization: \(authorizationStatusDescription(locationManager.authorizationStatus))")
                .foregroundColor(.gray)
            
            // MARK: - Monitoring Status
            Text("Monitoring: \(locationManager.isMonitoringRegion ? "ON" : "OFF")")
                .foregroundColor(locationManager.isMonitoringRegion ? .green : .red)
            
            // MARK: - Chosen Location
            Text("Chosen Location: \n\(chosenCoordinate.latitude), \(chosenCoordinate.longitude)")
                .multilineTextAlignment(.center)
                .foregroundColor(.blue)
            
            // MARK: - Buttons
            HStack {
                Button("Request Permission") {
                    locationManager.requestAuthorization()
                }
                .buttonStyle(BasicButtonStyle(color: .blue))
                
                Button("Choose Location") {
                    showPicker.toggle()
                }
                .buttonStyle(BasicButtonStyle(color: .orange))
                .sheet(isPresented: $showPicker) {
                    // Pass the chosenCoordinate binding to LocationPickerView
                    LocationPickerView(chosenCoordinate: $chosenCoordinate)
                }
            }
            
            HStack {
                Button("Start Monitoring") {
                    // Update the location manager’s regionCenter from chosenCoordinate
                    locationManager.regionCenter = chosenCoordinate
                    locationManager.startMonitoringRegion()
                }
                .buttonStyle(BasicButtonStyle(color: .green))
                
                Button("Stop Monitoring") {
                    locationManager.stopMonitoringRegion()
                }
                .buttonStyle(BasicButtonStyle(color: .red))
                .disabled(!locationManager.isMonitoringRegion)
            }
            
            Spacer()
        }
        .padding()
    }
    
    /// Helper function to display authorization state
    private func authorizationStatusDescription(_ status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined:     return "Not Determined"
        case .restricted:        return "Restricted"
        case .denied:            return "Denied"
        case .authorizedAlways:  return "Authorized Always"
        case .authorizedWhenInUse: return "Authorized When In Use"
        @unknown default:        return "Unknown"
        }
    }
}

// MARK: - A simple reusable button style
struct BasicButtonStyle: ButtonStyle {
    var color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .medium))
            .padding()
            .foregroundColor(.white)
            .background(color.opacity(configuration.isPressed ? 0.7 : 1.0))
            .cornerRadius(8)
    }
}
