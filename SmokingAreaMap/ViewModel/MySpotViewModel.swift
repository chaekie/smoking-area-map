//
//  MySpotViewModel.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/16/24.
//

import Combine
import Foundation

final class MySpotViewModel: ObservableObject {
    @Published var spot: MySpot?
    @Published var address: String
    @Published var name: String
    @Published var longitude: String
    @Published var latitude: String
    @Published var photo: Data?
    @Published var createdDate: String?

    @Published var tempLongitude = ""
    @Published var tempLatitude = ""
    @Published var tempAddress = ""

    @Published var isSaveButtonEnabled = false

    let dataService = PersistenceController.shared
    private var cancellables = Set<AnyCancellable>()

    init(_ spot: MySpot? = nil) {
        if let spot { // update
            self.address = spot.address
            self.name = spot.name
            self.longitude = String(spot.longitude)
            self.latitude = String(spot.latitude)
            self.photo = spot.photo
            self.createdDate = spot.dateString
            self.spot = spot

            Publishers.CombineLatest4($address, $name, $longitude, $latitude)
                .debounce(for: 0.3, scheduler: DispatchQueue.main)
                .map { address, name, longitude, latitude in
                    guard let longitude = Double(longitude),
                          let latitude = Double(latitude) else { return false }

                    return (address != spot.address ||
                            name != spot.name ||
                            longitude != spot.longitude ||
                            latitude != spot.latitude)
                }
                .assign(to: \.isSaveButtonEnabled, on: self)
                .store(in: &cancellables)

        } else { // create
            self.address = ""
            self.name = ""
            self.longitude = ""
            self.latitude = ""

            Publishers.CombineLatest4($address, $name, $longitude, $latitude)
                .debounce(for: 0.3, scheduler: DispatchQueue.main)
                .map { address, name, longitude, latitude in
                    guard let longitude = Double(longitude),
                          let latitude = Double(latitude) else { return false }

                    let isStringValidated = [address, name].allSatisfy { !$0.isEmpty }
                    let isDoubleValidated = [longitude, latitude].allSatisfy { Double($0) > 0.0 }

                    return isStringValidated && isDoubleValidated
                }
                .assign(to: \.isSaveButtonEnabled, on: self)
                .store(in: &cancellables)
        }
    }

    func createSpot() {
        guard let longitude = Double(longitude),
              let latitude = Double(latitude) else { return }

        dataService.create(name: self.name,
                           address: self.address,
                           longitude: Double(longitude),
                           latitude: Double(latitude),
                           photo: Data()
        )
    }

    func updateSpot(_ spot: MySpot) {
        let newName = spot.name == name ? nil : name
        let newAddress = spot.address == address ? nil : address
        let newLongitude = spot.longitude == Double(longitude) ? nil : Double(longitude)
        let newLatitude = spot.latitude == Double(latitude) ? nil : Double(latitude)
        let newPhoto = spot.photo == photo ? nil : photo

        dataService.update(entity: spot, name: newName, address: newAddress, longitude: newLongitude, latitude: newLatitude, photo: newPhoto)
    }

    func deleteSpot(_ spot: MySpot) {
        dataService.delete(spot)
    }
}
