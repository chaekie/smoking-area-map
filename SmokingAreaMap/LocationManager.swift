//
//  LocationManager.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/11/24.
//

import CoreLocation
import Foundation
import KakaoMapsSDK

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var lastLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        UserDefaults.standard.set(status.rawValue, forKey: "locationStatus")
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .restricted, .denied:
            print("Access to location data is not allowed")
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function, error)
    }

    func shouldMoveToCurrentLocation(controller: KMController, status: String) -> Bool {
        if status == "4" || status == "5" {
            guard let coordinate = lastLocation?.coordinate,
            let view = controller.getView(MapView.mapViewName) as? KakaoMap else {
                return false
            }

            let cameraUpdate = CameraUpdate.make(
                target: MapPoint(longitude: coordinate.longitude,
                                 latitude: coordinate.latitude),
                zoomLevel: 17,
                rotation: 0.0,
                tilt: 0.0,
                mapView: view
            )

            view.animateCamera(cameraUpdate: cameraUpdate,
                               options: CameraAnimationOptions(
                                autoElevation: false,
                                consecutive: true,
                                durationInMillis: 300
                               )
            )
            return true
            
        } else {
            return false
        }
    }
}
