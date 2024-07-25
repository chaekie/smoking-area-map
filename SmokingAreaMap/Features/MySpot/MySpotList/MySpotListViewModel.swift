//
//  MySpotListViewModel.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/16/24.
//

import Foundation


final class MySpotListViewModel: ObservableObject {
    let dataService = PersistenceController.shared
    @Published var spots: [MySpot] = []

    func getAllSpot() {
        spots = dataService.read()
    }
}
