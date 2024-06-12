//
//  ContentView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/10/24.
//

import SwiftUI
import KakaoMapsSDK

struct ContentView: View {
    @State var draw: Bool = false
    @State var coordinator = MapView.KakaoMapCoordinator()
    @StateObject var locationManager = LocationManager()

    var body: some View {
        MapView(draw: $draw, coordinator: $coordinator)
            .onAppear(perform: {
                self.draw = true
            })
            .onDisappear(perform: {
                self.draw = false
            })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .overlay(alignment: .bottomTrailing) {
                buildCurrentLocationButton()
            }
    }

    private func buildCurrentLocationButton() -> some View {
        Button {
            moveToCurrentLocation()
        } label: {
            Image(systemName: "dot.scope")
                .font(.title)
                .padding(10)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(radius: 5)
                .padding([.bottom, .trailing], 20)
        }
    }

    private func moveToCurrentLocation() {
        guard let userLongitude = locationManager.lastLocation?.coordinate.longitude,
              let userLatitude = locationManager.lastLocation?.coordinate.latitude,
              let controller = coordinator.controller else {
            return
        }

        let view = controller.getView(MapView.mapViewName) as! KakaoMap
        let cameraUpdate = CameraUpdate.make(
            target: MapPoint(longitude: userLongitude, latitude: userLatitude),
            zoomLevel: 17,
            rotation: 0.0,
            tilt: 0.0,
            mapView: view
        )

        view.animateCamera(cameraUpdate: cameraUpdate, options: CameraAnimationOptions(autoElevation: false, consecutive: true, durationInMillis: 500))
    }
}

#Preview {
    ContentView()
}
