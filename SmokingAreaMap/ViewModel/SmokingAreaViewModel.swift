//
//  SmokingAreaViewModel.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/24/24.
//

import SwiftUI

class SmokingAreaViewModel: ObservableObject {
    private let openDataBaseURL = "https://api.odcloud.kr/api/"
    private let kakaoLocalBaseURL = "https://dapi.kakao.com/v2/local/"

    @Published var smokingAreas = [SmokingArea]()
    @Published var totalCount: Int = 0
    @Published var page = 1
    @Published var size = 20

    func getDistrict(_ coordinates: Coordinate) async throws -> DistrictInfo? {
        let urlString = "\(kakaoLocalBaseURL)geo/coord2regioncode.json?x=\(coordinates.longitude)&y=\(coordinates.latitude)"
        guard let url = URL(string: urlString) else {
            dump(SAError(.invalidUrl))
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue("KakaoAK \(Bundle.main.kakaoRestApiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        try handleHTTPResponse(response)

        let decodedData = try JSONDecoder().decode(LocalRegionDataResult.self, from: data)
        let documents = decodedData.documents

        if documents.isEmpty { return nil }
        guard let region = District(rawValue: documents[0].gu) else { return nil }

        return DistrictInfo(name: region.name, code: region.code, uuid: region.uuid)
    }

    func fetchSmokingArea(district: DistrictInfo) async {
        if district.code == "" {
            print("no \(district.name) data yet")
            return
        }

        if district.name == "광진구" || district.name == "중랑구" {
            await MainActor.run { size = 40 }
        } else {
            await MainActor.run { size = 20 }
        }
        
        let urlString = "\(openDataBaseURL)\(district.code)/v1/uddi:\(district.uuid)?page=\(page)&perPage=\(size)&serviceKey=\(Bundle.main.openDataApiKey)"
        guard let url = URL(string: urlString) else {
            dump(SAError(.invalidUrl))
            return
        }

        do {
            let areas = try await performRequest(with: url, about: district)
            DispatchQueue.main.async {
                if self.page <= 1 {
                    self.smokingAreas = areas
                } else {
                    self.smokingAreas = self.smokingAreas + areas
                }
            }
        } catch {
            handleRequestError(error)
        }
    }

    func performRequest(with url: URL, about district: DistrictInfo) async throws -> [SmokingArea] {
        let (data, response) = try await URLSession.shared.data(from: url)
        try handleHTTPResponse(response)
        return try await parseJSON(data, district: district)
    }

    func parseJSON(_ data: Data, district: DistrictInfo) async throws -> [SmokingArea] {
        do {
            let decodedData = try JSONDecoder().decode(SmokingAreaDataResult.self, from: data)
            Task {
                await MainActor.run {
                    totalCount = decodedData.totalCount
                }
            }
            return await decodedData.data.asyncCompactMap { await toSmokingArea(from: $0, district: district) }
        } catch {
            throw SAError(.jsonDecodingFailed)
        }
    }

    func toSmokingArea(from data: SmokingAreaData, district: DistrictInfo) async -> SmokingArea? {
        let addressString = getWholeAddress(from: data, type: district.name)
        let roomTypeString = [data.roomType1, data.roomType2, data.roomType3].compactMap { $0 }.joined(separator: " ")
        guard isLocationFit(data, address: addressString, roomType: roomTypeString) else { return nil }

        guard let coordinates = await checkCoordinates(data, address: addressString, district: district),
            let longitude = Double(coordinates.longitude),
            let latitude = Double(coordinates.latitude) else {
            return nil
        }

        return SmokingArea(
            district: district,
            address: addressString,
            longitude: longitude,
            latitude: latitude,
            roomType: roomTypeString.isEmpty ? nil : roomTypeString
        )
    }

    func isLocationFit(_ data: SmokingAreaData, address: String, roomType: String) -> Bool {
        if let businessType = data.businessType {
            return businessType != "게임업소" && businessType != "체육시설업"
        }

        return !address.contains("옥상") && !address.contains("지하") && !roomType.contains("당구장업") && !roomType.contains("목욕장업") && !roomType.contains("골프연습장업") && !roomType.contains("체력단련장업")
    }

    func getWholeAddress(from data: SmokingAreaData, type districtName: String) -> String {
        var address = ["서울특별시", districtName]

        switch District(rawValue: districtName) {
        case .yeongdeungpoGu:
            address.append(data.address7 ?? "")
        case .dongdaemunGu,
             .gangseoGu,
             .gwanakGu,
             .seodaemunGu,
             .seochoGu,
             .seongbukGu,
             .seongdongGu,
             .yangcheonGu:
            address.append(contentsOf: [data.address8, data.address9, data.address10].compactMap { $0 })
        default:
            address = [data.address1, data.address2, data.address3, data.address4, data.address5, data.address6, data.address8, data.address9, data.address11, data.address12, data.address13].compactMap { $0 }
        }

        return address.joined(separator: " ")
    }


    func checkCoordinates(_ data: SmokingAreaData, address: String, district: DistrictInfo) async -> Coordinate? {
        if let longitude = data.longitude,
           let latitude = data.latitude {
            return Coordinate(longitude: longitude, latitude: latitude)
        } else {
            do {
                if let newGeoInfo = try await getGeoCoordinates(from: address, district: district) {
                    return Coordinate(longitude: newGeoInfo.longitude, latitude: newGeoInfo.latitude)
                }
            } catch {
                print(error)
            }
        }

        return nil
    }

    func getGeoCoordinates(from address: String, district: DistrictInfo) async throws -> Coordinate? {
        let filteredAddress = filterKeyword(from: address)
        var searchType: SearchType = .address

        switch District(rawValue: district.name) {
        case .seongdongGu, .seongbukGu, .gwanakGu, .yangcheonGu, .jungnangGu, .seochoGu:
            searchType = .keyword
        default:
            break
        }

        let urlString = "\(kakaoLocalBaseURL)search/\(searchType).json?query=\(filteredAddress)&size=1"
        guard let url = URL(string: urlString) else {
            dump(SAError(.invalidUrl))
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue("KakaoAK \(Bundle.main.kakaoRestApiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        try handleHTTPResponse(response)

        let decodedData = try JSONDecoder().decode(LocalCoordDataResult.self, from: data)
        let documents = decodedData.documents

        if documents.isEmpty { return nil }

        return Coordinate(longitude: documents[0].longitude, latitude: documents[0].latitude)
    }

    func filterKeyword(from str: String) -> String {
        var newAddresses: [String] = []
        let keywords = [Int](2...20).map { "\($0)층" } +
        [" 부지", " 후면", " 후문", " 주차", " 앞", " 옆", " 뒤", " 옥상", " 건물뒷편", " 뒷편", " 테라스", "(", "출입계단", "와", "남측", "건물"]

        keywords.forEach { word in
            if let range = str.range(of: word) {
                newAddresses.append(String(str[..<range.lowerBound]))
            }
        }

        if newAddresses.isEmpty { return str }
        if newAddresses.count > 1 { newAddresses.sort { $0.count < $1.count } }

        return newAddresses[0]
    }

    private func handleHTTPResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SAError(.invalidResponse, description: "No HTTP response")
        }

        switch httpResponse.statusCode {
        case 200..<300:
            return
        case 401:
            throw SAError(.wrongApiKey)
        case 500:
            throw SAError(.serverError)
        default:
            throw SAError(.invalidResponse, description: "Status code: \(httpResponse.statusCode)")
        }
    }

    private func handleRequestError(_ error: Error) {
        if let error = error as? SAError {
            dump(error)
        } else {
            dump(SAError(.unknownError, description: error.localizedDescription))
        }
    }
}
