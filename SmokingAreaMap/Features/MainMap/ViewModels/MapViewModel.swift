//
//  MapViewModel.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/27/24.
//

import CoreLocation
import Foundation
import KakaoMapsSDK

final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentLocation = GeoCoordinate()
    @Published var cameraLocation = GeoCoordinate()
    @Published var oldDistrictValue: DistrictInfo?
    @Published var newDistrictValue: DistrictInfo?
    @Published var locationServiceAuthorized: CLAuthorizationStatus?

    private var locationManager: CLLocationManager
    var currentPositionPoi: Poi?

    override init() {
        locationManager = CLLocationManager()
        super.init()
        setupLocationManager()
    }

    func setupLocationManager() {
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation.longitude = locations[0].coordinate.longitude
        currentLocation.latitude = locations[0].coordinate.latitude
        currentPositionPoi?.moveAt(MapPoint(longitude: currentLocation.longitude, latitude: currentLocation.latitude), duration: 300)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationServiceAuthorized = status
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingHeading()
            locationManager.startUpdatingLocation()
            currentPositionPoi?.show()
        case .restricted, .denied:
            currentPositionPoi?.hide()
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function, error)
    }
}
