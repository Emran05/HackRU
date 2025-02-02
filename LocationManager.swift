import CoreLocation
import UserNotifications
import Combine

class LocationManager: NSObject, ObservableObject {
    // Publish location authorization status
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    // Publish a flag indicating if region monitoring is active
    @Published var isMonitoringRegion: Bool = false
    
    // Keep a reference to the region center (chosen by the user)
    var regionCenter: CLLocationCoordinate2D?
    // You can also allow the user to pick a custom radius if desired
    let regionRadius: CLLocationDistance = 200
    let regionIdentifier = "DesignatedArea"
    
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    // MARK: - Authorization
    
    /// Request the appropriate location authorization
    func requestAuthorization() {
        // For background region monitoring, requestAlwaysAuthorization.
        locationManager.requestAlwaysAuthorization()
    }
    
    // MARK: - Region Monitoring
    
    /// Starts monitoring a region at the chosen coordinate.
    func startMonitoringRegion() {
        guard let center = regionCenter else {
            print("No region center chosen yet.")
            return
        }
        
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            print("Region monitoring is not available on this device.")
            return
        }
        
        let region = CLCircularRegion(center: center,
                                      radius: regionRadius,
                                      identifier: regionIdentifier)
        region.notifyOnEntry = true
        region.notifyOnExit = false  // Set this to true if you want exit notifications, too
        
        locationManager.startMonitoring(for: region)
        isMonitoringRegion = true
        
        print("Started monitoring region at: \(center.latitude), \(center.longitude)")
    }
    
    /// Stops monitoring the region (if any).
    func stopMonitoringRegion() {
        for monitoredRegion in locationManager.monitoredRegions {
            if monitoredRegion.identifier == regionIdentifier {
                locationManager.stopMonitoring(for: monitoredRegion)
                isMonitoringRegion = false
                print("Stopped monitoring region: \(monitoredRegion.identifier)")
            }
        }
    }
    
    // MARK: - Local Notification
    
    /// Schedule a local notification
    private func scheduleNotification(title: String, body: String) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
                return
            }
            
            guard granted else {
                print("User denied notification permission.")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            
            // Trigger after 1 second
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString,
                                                content: content,
                                                trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Unable to add notification request: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("Location authorization granted.")
        case .denied, .restricted:
            print("Location authorization denied or restricted.")
        default:
            print("Authorization status changed to: \(status)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region.identifier == regionIdentifier {
            // Here is where you customize your "This is your stop" message
            scheduleNotification(title: "This is your stop",
                                 body: "You’ve arrived at your destination.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        // Optional exit notification
        /*
        if region.identifier == regionIdentifier {
            scheduleNotification(title: "Exited Region",
                                 body: "You have left your destination.")
        }
        */
    }
    
    // Optional: If there's an error while monitoring
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region: \(region?.identifier ?? "Unknown") with error: \(error.localizedDescription)")
    }
}
