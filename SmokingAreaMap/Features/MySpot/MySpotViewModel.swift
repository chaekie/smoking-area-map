//
//  MySpotViewModel.swift
//  SmokingAreaMap
//
//  Created by chaekie on 7/28/24.
//

import Combine
import Foundation
import PhotosUI
import SwiftUI

final class MySpotViewModel: ObservableObject {

    enum ContentMode {
        case creating
        case reading
        case updating
    }

    let dataService = PersistenceController.shared
    private var cancellables = Set<AnyCancellable>()

    @Published var spots: [MySpot] = []
    
    @Published var tempName = ""
    @Published var tempLongitude = ""
    @Published var tempLatitude = ""
    @Published var tempAddress = ""
    @Published var tempPhoto: Data?
    
    @Published var tempLongitudeInSheet = ""
    @Published var tempLatitudeInSheet = ""
    @Published var tempAddressInSheet = ""
    @Published var selectedPhoto: PhotosPickerItem?

    @Published var isSaveButtonEnabled = false
    @Published var isFullSheetDismissed = false
    @Published var isEditing = false
    @Published var isCreating = false {
        didSet {
            if isCreating {
                getAllSpot()
                isCreating = false
            }
        }
    }

    var isEditingCanceled = false
    @Published var contentMode: ContentMode? {
        didSet {
            if let spot, contentMode == .reading {
                isEditingCanceled = true
                tempAddress = spot.address
                tempName = spot.name
                tempLongitude = String(spot.longitude)
                tempLatitude = String(spot.latitude)
                tempPhoto = spot.photo
                selectedPhoto = nil
            }
        }
    }

    @Published var spot: MySpot? {
        didSet {
            if let spot { // update
                tempAddress = spot.address
                tempName = spot.name
                tempLongitude = String(spot.longitude)
                tempLatitude = String(spot.latitude)
                tempPhoto = spot.photo

                Publishers.CombineLatest4($tempName, $tempLongitude, $tempLatitude, $tempPhoto)
                    .debounce(for: 0.3, scheduler: DispatchQueue.main)
                    .map { name, longitude, latitude, photo in
                        guard let longitude = Double(longitude),
                              let latitude = Double(latitude) else { return false }

                        return (name != spot.name ||
                                longitude != spot.longitude ||
                                latitude != spot.latitude ||
                                photo != spot.photo)
                    }
                    .assign(to: \.isSaveButtonEnabled, on: self)
                    .store(in: &cancellables)

            } else { // create
                Publishers.CombineLatest4($tempAddress, $tempName, $tempLongitude, $tempLatitude)
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
    }

    init() {
        Publishers.CombineLatest4($tempName, $tempLongitude, $tempLatitude, $tempPhoto)
            .map { tempName, tempLongitude, tempLatitude, tempPhoto in
                if let spot = self.spot {
                    return (tempName != spot.name ||
                            tempLongitude != String(spot.longitude) ||
                            tempLatitude != String(spot.latitude) ||
                            tempPhoto != spot.photo)
                } else {
                    var isPhotoEmpty = true
                    if let tempPhoto { isPhotoEmpty = tempPhoto.isEmpty }
                    return (!tempName.isEmpty ||
                            !tempLongitude.isEmpty ||
                            !tempLatitude.isEmpty ||
                            !isPhotoEmpty)
                }
            }
            .assign(to: \.isEditing, on: self)
            .store(in: &cancellables)
    }

    func getAllSpot() {
        spots = dataService.read()
    }

    func createSpot() {
        guard let longitude = Double(tempLongitude),
              let latitude = Double(tempLatitude) else { return }

        dataService.create(name: tempName,
                           address: tempAddress,
                           longitude: longitude,
                           latitude: latitude,
                           photo: tempPhoto)
        isCreating = true
    }

    func updateSpot(_ spot: MySpot) {
        let newName = spot.name == tempName ? nil : tempName
        let newAddress = spot.address == tempAddress ? nil : tempAddress
        let newLongitude = spot.longitude == Double(tempLongitude) ? nil : Double(tempLongitude)
        let newLatitude = spot.latitude == Double(tempLatitude) ? nil : Double(tempLatitude)
        let newPhoto = spot.photo == tempPhoto ? Data() : tempPhoto == nil ? nil : tempPhoto

        dataService.update(entity: spot, 
                           name: newName,
                           address: newAddress,
                           longitude: newLongitude,
                           latitude: newLatitude,
                           photo: newPhoto)

        spot.name = tempName
        spot.address = tempAddress
        spot.photo = tempPhoto
        if let longitude = Double(tempLongitude),
           let latitude = Double(tempLatitude) {
            spot.longitude = longitude
            spot.latitude = latitude
        }
    }

    func deleteSpot(_ spot: MySpot) {
        dataService.delete(spot)
    }

    func setUpSpot(_ spot: MySpot?) {
        self.spot = spot
        if spot == nil {
            contentMode = .creating
        } else {
            contentMode = .reading
        }
    }

    func resetSpot() {
        spot = nil
        tempName = ""
        tempAddress = ""
        tempLongitude = ""
        tempLatitude = ""
        tempPhoto = nil
        selectedPhoto = nil
    }

    func setLocation() {
        tempLongitude = tempLongitudeInSheet
        tempLatitude = tempLatitudeInSheet
        tempAddress = tempAddressInSheet
        isFullSheetDismissed = true
    }
    
    @MainActor
    func setPhoto(from selectedPhoto: PhotosPickerItem) async {
        do {
            self.tempPhoto = try await selectedPhoto.loadTransferable(type: Data.self)
        } catch {
            print(error)
        }
    }

    func deletePhoto() {
        selectedPhoto = nil
        tempPhoto = nil
    }

}
