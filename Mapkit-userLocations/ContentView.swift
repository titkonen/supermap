import MapKit
import SwiftUI

struct ContentView: View {
  @StateObject private var viewModel = ContentViewModel()
  
    var body: some View {
      Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
        .ignoresSafeArea()
        .accentColor(Color(.systemPink))
        .onAppear {
          viewModel.checkIfLocationManagerIsEnabled()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


//MARK: CLASS, Location manager codes
///NSObject needs to be first!
/// CLLocationManagerDelegate handles the changed status of locationManager
final class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
  
  @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 60.1699, longitude: 24.9384), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
  var locationManager: CLLocationManager?
  
  func checkIfLocationManagerIsEnabled() {
    if CLLocationManager.locationServicesEnabled() {
      locationManager = CLLocationManager()
      locationManager?.delegate = self
//      locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    } else {
      print("Show an alert letting them know this is off and to go turn it on")
    }
  }
  
  private func checkLocationAuthorization() {
    guard let locationManager = locationManager else {
      return
    }
    
    switch locationManager.authorizationStatus {
      
    case .notDetermined:
      locationManager.requestWhenInUseAuthorization()
    case .restricted:
      print("Your location is restricted likely due to parental controls.")
    case .denied:
      print("You have denied this app location permission. Go into settings to change it.")
    case .authorizedAlways, .authorizedWhenInUse:
      region = MKCoordinateRegion(center: locationManager.location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    @unknown default:
      break
    }
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    checkLocationAuthorization()
  }
  
}
