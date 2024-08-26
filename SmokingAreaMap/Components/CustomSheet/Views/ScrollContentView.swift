//
//  ScrollContentView.swift
//  SmokingAreaMap
//
//  Created by chaekie on 8/22/24.
//

import SwiftUI

struct ScrollContentView: View {
    @EnvironmentObject var mapVM: MapViewModel
    var collapseSheet: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Spacer().frame(height: 20)

            VStack(alignment: .leading, spacing: 8) {
                if let spot = mapVM.selectedSpot {
                    Text("위도: \(spot.latitude), 경도: \(spot.longitude)")
                    Text("주소: \(spot.address)")

                    if let spot = spot as? SmokingArea {
                        if let roomType = spot.roomType {
                            Text("개방 형태: \(roomType)")
                        }
                    }

                    if let spot = spot as? MySpot {
                        Text("장소명: \(spot.name)")
                    }

                }
            }

            ForEach(0..<20) { num in
                HStack {
                    Spacer()
                    Button("Row \(num) 닫기") {
                        collapseSheet()
                    }
                    Spacer()
                }
                .frame(height: 50)
            }
        }
    }
}
