//
//  MySpotViewModel.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/16/24.
//

import Combine
import Foundation

final class MySpotViewModel: ObservableObject {
    @Published var spot: Spot?
    @Published var address: String
    @Published var name: String
    @Published var isSaveButtonEnabled = false

    let dataService = PersistenceController.shared
    private var cancellables = Set<AnyCancellable>()

    init(_ spot: Spot? = nil) {
        if let spot { // update
            self.address = spot.address ?? ""
            self.name = spot.name ?? ""
            self.spot = spot

            Publishers.CombineLatest($address, $name)
                .map { address, name in
                    return address != spot.address || name != spot.name
                }
                .assign(to: \.isSaveButtonEnabled, on: self)
                .store(in: &cancellables)

        } else { // create
            self.address = ""
            self.name = ""

            Publishers.CombineLatest($address, $name)
                .map { address, name in
                    return !address.isEmpty && !name.isEmpty
                }
                .assign(to: \.isSaveButtonEnabled, on: self)
                .store(in: &cancellables)
        }
    }

    func createSpot() {
        dataService.create(name: self.name, address: self.address)
    }

    func updateSpot(_ spot: Spot) {
        let newName = spot.name != name ? name : nil
        let newAddress = spot.address != address ? address : nil
        dataService.update(entity: spot, name: newName, address: newAddress)
    }

    func deleteSpot(_ spot: Spot) {
        dataService.delete(spot)
    }
}
