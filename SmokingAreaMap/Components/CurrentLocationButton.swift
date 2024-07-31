//
//  CurrentLocationButton.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/23/24.
//

import SwiftUI

struct CurrentLocationButton: View {
    @EnvironmentObject var mapVM: MapViewModel
    @Binding var shouldMove: Bool
    @Binding var isLocationAlertPresented: Bool

    var body: some View {
        Button {
            moveToCurrentLocation()
        } label: {
            Image(systemName: "scope")
                .font(.title2)
                .padding(15)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 5)
                .padding([.bottom, .trailing], 20)
        }
        .alert("위치 서비스 사용", isPresented: $isLocationAlertPresented) {
            Button("취소", role: .cancel) {}
            Button("설정으로 이동") {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return
                }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("위치 서비스를 사용할 수 없습니다.\n기기의 \"설정 > \(Bundle.main.appName) > 위치\"에서\n위치 서비스를 켜주세요.")
        }
    }
    
    private func moveToCurrentLocation() {
        let isAuthorized = (mapVM.locationServiceAuthorized == .authorizedWhenInUse
                            || mapVM.locationServiceAuthorized == .authorizedAlways)
        shouldMove = isAuthorized
        isLocationAlertPresented = !isAuthorized

        DispatchQueue.main.async {
            shouldMove = false
        }
    }

}
