//
//  SmokingAreaManager.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/24/24.
//

import Foundation
import SwiftUI

class SmokingAreaManager: ObservableObject {
    private let baseURL = "https://api.odcloud.kr/api/"
    private let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPEN_DATA_PORTAL_KEY") as? String

    private var smokingAreas = [SmokingArea]()

    func parseJSON(_ result: Data) -> [SmokingArea]? {
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode(SmokingAreaDataResult.self, from: result) else {
            return nil
        }

        let smokingAreas = decodedData.data.map {
            SmokingArea(district: SmokingArea.district(rawValue: $0.district) ?? .서울,
                        address: $0.address,
                        longitude: $0.longitude,
                        latitude: $0.latitude,
                        type: SmokingArea.type(rawValue: $0.type) ?? .미정,
                        location: SmokingArea.location(rawValue: $0.location) ?? .미정)
        }
        dump(smokingAreas)
        return smokingAreas
    }

    func performRequest(with url: URL) async throws -> [SmokingArea] {
        let (data, response) = try await URLSession.shared.data (from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200 ..< 299) ~= httpResponse.statusCode else {
            throw SmokingAreaError.respondingError
        }

        if data.isEmpty {
            throw SmokingAreaError.emptyData
        }

        guard let smokingAreas = self.parseJSON(data) else {
            throw SmokingAreaError.parsingError
        }

        return smokingAreas
    }

    func fetchSmokingArea(page: Int) async {
        guard let apiKey = apiKey else {
            print("Error: cannot create URL")
            return
        }

        let urlString = 
        "\(baseURL)15069051/v1/uddi:2653cc01-60d7-4e8b-81f4-80b24a39d8f6?page=\(page)&perPage=10&serviceKey=\(apiKey)"

        guard let url = URL(string: urlString) else { return }
        Task {
            do {
                smokingAreas = try await performRequest(with: url)
            } catch {
                print(error)
            }
        }
    }
}

enum SmokingAreaError: Error {
    case networkingError
    case respondingError
    case emptyData
    case parsingError
}
