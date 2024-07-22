//
//  SubMapRepresentableView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/22/24.
//

import CoreLocation
import KakaoMapsSDK
import SwiftUI

struct SubMapRepresentableView: UIViewRepresentable {
    @EnvironmentObject var mapVM: MapViewModel
    @EnvironmentObject var smokingAreaVM: SmokingAreaViewModel
    @EnvironmentObject var mySpotVM: MySpotViewModel
    
    @Binding var isAppear: Bool
    @Binding var shouldMove: Bool
    let mapMode: MapMode

    @Environment(\.scenePhase) var scenePhase

    func makeUIView(context: Self.Context) -> KMViewContainer {
        let view = KMViewContainer()
        view.sizeToFit()
        context.coordinator.createController(view)
        return view
    }

    func updateUIView(_ uiView: KMViewContainer, context: Self.Context) {
        print("@@@ isAppear:", isAppear)
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

                    }
                }
            } else {
                controller.pauseEngine()
                controller.resetEngine()
            }
        }
    }

    func makeCoordinator() -> SubMapCoordinator {
        SubMapCoordinator(parent: self)
    }

    static func dismantleUIView(_ uiView: KMViewContainer, coordinator: SubMapCoordinator) {
        print("@@@ dismantleUIView isAppear:")
        coordinator.controller?.pauseEngine()
        coordinator.controller?.resetEngine()
    }
}
