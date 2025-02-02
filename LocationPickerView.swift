import SwiftUI
import MapKit

struct LocationPickerView: View {
    /// The coordinate chosen by the user, bound to a parent view's state.
    @Binding var chosenCoordinate: CLLocationCoordinate2D
    
    /// A local region state for controlling the map’s center & span
    @State private var region: MKCoordinateRegion
    
    /// Initialize with a default center (could be user’s location or any default)
    init(chosenCoordinate: Binding<CLLocationCoordinate2D>) {
        _chosenCoordinate = chosenCoordinate
        _region = State(initialValue: MKCoordinateRegion(
            center: chosenCoordinate.wrappedValue,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main Map
                Map(coordinateRegion: $region,
                    showsUserLocation: true)
                    .ignoresSafeArea()

                // A pin image that stays fixed in the center
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundColor(.red)
                    // Slight offset to appear like a real pin
                    .offset(y: -16)
            }
            .navigationTitle("Choose a Location")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Confirm") {
                // When confirmed, update the chosenCoordinate to map center
                chosenCoordinate = region.center
            })
        }
    }
}
