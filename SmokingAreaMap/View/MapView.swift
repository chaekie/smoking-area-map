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
    @ObservedObject var viewModel: MapViewModel
    @ObservedObject var smokingAreaMananger: SmokingAreaManager
    
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
                    context.coordinator.setPois(smokingAreaMananger.smokingAreas)
                }
            } else {
                controller.pauseEngine()
                controller.resetEngine()
            }
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
