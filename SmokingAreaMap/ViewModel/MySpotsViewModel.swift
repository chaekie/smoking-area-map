//
//  MySpotsViewModel.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/16/24.
//

import Foundation


final class MySpotsViewModel: ObservableObject {
    let dataService = PersistenceController.shared
    @Published var spots: [MySpot] = []

    func getAllSpot() {
        spots = dataService.read()
    }
}
