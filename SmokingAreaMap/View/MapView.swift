//
//  MapView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/11/24.
//

import CoreLocation
import KakaoMapsSDK
import SwiftUI

struct MapView: UIViewRepresentable {
    @ObservedObject var mapVM: MapViewModel
    @ObservedObject var smokingAreaVM: SmokingAreaViewModel

    @Binding var isAppear: Bool
    @Binding var shouldMove: Bool
    var onPoiTapped: () -> Void

    static let mapViewName = "mainMap"
    @Environment(\.scenePhase) var scenePhase

    func makeUIView(context: Self.Context) -> KMViewContainer {
        let view = KMViewContainer()
        view.sizeToFit()
        context.coordinator.createController(view)
        return view
    }

    func updateUIView(_ uiView: KMViewContainer, context: Self.Context) {
        if isAppear && shouldMove {
            context.coordinator.moveToCurrentLocation()
            return
        }

        guard let controller = context.coordinator.controller else { return }
        DispatchQueue.main.async {
            if isAppear {
                if scenePhase == .background || scenePhase == .inactive {
                    controller.pauseEngine()
                } else {
                    if controller.isEnginePrepared == false { controller.prepareEngine() }
                    if controller.isEngineActive == false { controller.activateEngine() }

                    if controller.isEnginePrepared && controller.isEngineActive {
                        let isSame = context.coordinator.cachedSmokingAreas.elementsEqual(smokingAreaVM.smokingAreas)
                        if !isSame {
                            context.coordinator.setPois(smokingAreaVM.smokingAreas)
                            context.coordinator.cachedSmokingAreas = smokingAreaVM.smokingAreas
                        }
                    }
                }
            } else {
                controller.pauseEngine()
                controller.resetEngine()
                context.coordinator.cachedSmokingAreas = []
            }
        }
    }

    func makeCoordinator() -> MapCoordinator {
        MapCoordinator(parent: self)
    }

    func getSmokingAreasByLocation(_ location: Coordinate) {
        Task {
            guard let district = try await smokingAreaVM.getDistrict(
                Coordinate(longitude: location.longitude, latitude: location.latitude)
            ) else { return }

            await smokingAreaVM.fetchSmokingArea(district: district, page: 1)
        }
    }

    static func dismantleUIView(_ uiView: KMViewContainer, coordinator: MapCoordinator) {
        coordinator.controller?.pauseEngine()
        coordinator.controller?.resetEngine()
    }
}
