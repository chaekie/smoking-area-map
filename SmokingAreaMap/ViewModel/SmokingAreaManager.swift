//
//  SmokingAreaManager.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/24/24.
//

import SwiftUI

class SmokingAreaManager: ObservableObject {
    private let baseURL = "https://api.odcloud.kr/api/"
    private let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPEN_DATA_PORTAL_KEY") as? String
    private let districts = District.allCases
                            .filter{ $0.code != "" }
                            .map{ DistrictInfo(name: $0.name, code: $0.code, uuid: $0.uuid) }

    @Published var smokingAreas = [SmokingArea]()

    func parseJSON(_ data: Data, district: DistrictInfo) throws -> [SmokingArea] {
        do {
            let decodedData = try JSONDecoder().decode(SmokingAreaDataResult.self, from: data)
            return decodedData.data.map { $0.toSmokingArea(district: district) }
        } catch {
            throw SAError(.jsonDecodingFailed)
        }
    }

    func performRequest(with url: URL, about district: DistrictInfo) async throws -> [SmokingArea] {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SAError(.invalidResponse, description: "No HTTP response")
        }

        switch httpResponse.statusCode {
        case 200..<300:
            return try parseJSON(data, district: district)
        case 401:
            throw SAError(.wrongApiKey)
        case 500:
            throw SAError(.serverError)
        default:
            throw SAError(.invalidResponse, description: "Status code: \(httpResponse.statusCode)")
        }
    }

    func fetchSmokingArea(district: DistrictInfo, page: Int) async {
        guard let apiKey = apiKey else { return }
        let urlString = "\(baseURL)\(district.code)/v1/uddi:\(district.uuid)?page=\(page)&perPage=60&serviceKey=\(apiKey)"

        guard let url = URL(string: urlString) else {
            dump(SAError(.invalidUrl))
            return
        }

        do {
            let areas = try await performRequest(with: url, about: district)
            DispatchQueue.main.async {
                dump(areas)
                self.smokingAreas = areas
            }
        } catch let error as SAError {
            dump(error)
        } catch {
            dump(SAError(.unknownError, description: error.localizedDescription))
        }
    }

    func fetchAllDistricts() async {
        Task {
//            await fetchSmokingArea(district: districts[0], page: 1 )
            await districts.asyncMap { await fetchSmokingArea(district: $0, page: 1) }
        }

    }

    func getGeoCoordinates(from address: String) -> (longitude: Double, latitude: Double){
        return (longitude: 0.0, latitude: 0.0)
    }
}

extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
}
