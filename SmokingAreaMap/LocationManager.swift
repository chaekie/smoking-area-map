//
//  LocationManager.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/11/24.
//

import CoreLocation
import Foundation
import KakaoMapsSDK

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {

    override init() {
        locationManager = CLLocationManager()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        currentLocation = GeoCoordinate()

        super.init()
        locationManager.delegate = self
    }

    func shouldMoveToCurrentLocation(view: KakaoMap) -> Bool {
        if locationServiceAuthorized == .authorizedWhenInUse || locationServiceAuthorized == .authorizedAlways {
            let cameraUpdate = CameraUpdate.make(
                target: MapPoint(longitude: currentLocation.longitude,
                                 latitude: currentLocation.latitude),
                zoomLevel: 17,
                rotation: 0.0,
                tilt: 0.0,
                mapView: view
            )

            view.animateCamera(
                cameraUpdate: cameraUpdate,
                options: CameraAnimationOptions(autoElevation: false, consecutive: true, durationInMillis: 300)
            )
            return true
        }
        return false
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation.longitude = locations[0].coordinate.longitude
        currentLocation.latitude = locations[0].coordinate.latitude

        currentPositionPoi?
            .moveAt(MapPoint(longitude: currentLocation.longitude, latitude: currentLocation.latitude), duration: 300)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationServiceAuthorized = status

        switch locationServiceAuthorized {
        case .authorizedAlways, .authorizedWhenInUse:
                locationManager.startUpdatingHeading()
                locationManager.startUpdatingLocation()
                currentPositionPoi?.show()
        case .restricted, .denied:
            currentPositionPoi?.hide()
            print("Access to location data is not allowed")
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function, error)
    }

    var currentLocation: GeoCoordinate
    var currentPositionPoi: Poi?
    var locationManager: CLLocationManager
    var locationServiceAuthorized: CLAuthorizationStatus?
}
