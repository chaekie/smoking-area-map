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
        let coordinator = context.coordinator
        guard let controller = coordinator.controller else { return }

        if isAppear && shouldMove {
            coordinator.moveCamera(to: mapVM.currentLocation)
            return
        }

        DispatchQueue.main.async {
            if isAppear {
                if scenePhase == .background || scenePhase == .inactive {
                    controller.pauseEngine()
                } else {
                    if controller.isEnginePrepared == false { controller.prepareEngine() }
                    if controller.isEngineActive == false { controller.activateEngine() }

                    if controller.isEnginePrepared && controller.isEngineActive {
                        updateSmokingAreasPoi(coordinator)
                        updateMySpotsPoi(coordinator)

                        if mapVM.newDistrictValue.name == mapVM.oldDistrictValue.name {
                            coordinator.hideAllPolygons()
                        }
                    }
                }
            } else {
                controller.pauseEngine()
            }
        }
    }

    private func updateSmokingAreasPoi(_ coordinator: Coordinator) {
        if smokingAreaVM.isSmokingAreasUpdated {
            coordinator.setPois(smokingAreaVM.smokingAreas, poiInfo: coordinator.spotPoiInfo)
            smokingAreaVM.isSmokingAreasUpdated = false
        }
    }

    private func updateMySpotsPoi(_ coordinator: Coordinator) {
        if smokingAreaVM.isMySpotUpdated {
            coordinator.setPois(smokingAreaVM.mySpots, poiInfo: coordinator.mySpotPoiInfo)
            smokingAreaVM.isMySpotUpdated = false
        }
    }

    func makeCoordinator() -> MapCoordinator {
        MapCoordinator(parent: self)
    }

    static func dismantleUIView(_ uiView: KMViewContainer, coordinator: MapCoordinator) {
        coordinator.controller?.pauseEngine()
        coordinator.controller?.resetEngine()
    }
}
