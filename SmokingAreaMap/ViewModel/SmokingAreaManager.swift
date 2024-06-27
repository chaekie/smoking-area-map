//
//  SmokingAreaManager.swift
//  SmokingAreaMap
//
//  Created by chaekie on 6/24/24.
//

import Combine
import Foundation
import SwiftUI

class SmokingAreaManager: ObservableObject {
    private let baseURL = "https://api.odcloud.kr/api/"
    private let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPEN_DATA_PORTAL_KEY") as? String

    @Published var smokingAreas = [SmokingArea]()

    func parseJSON(_ data: Data) throws -> [SmokingArea] {
          do {
              let decodedData = try JSONDecoder().decode(SmokingAreaDataResult.self, from: data)
              return decodedData.data.map { $0.toSmokingArea() }
          } catch {
              throw SAError(.jsonDecodingFailed)
          }
      }

    func performRequest(with url: URL) async throws -> [SmokingArea] {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SAError(.invalidResponse, description: "No HTTP response")
        }

        switch httpResponse.statusCode {
        case 200..<300:
            return try parseJSON(data)
        case 401:
            throw SAError(.wrongApiKey)
        case 500:
            throw SAError(.serverError)
        default:
            throw SAError(.invalidResponse, description: "Status code: \(httpResponse.statusCode)")
        }
    }

    func fetchSmokingArea(page: Int) async {
        guard let apiKey = apiKey else { return }

        let urlString =
        "\(baseURL)15069051/v1/uddi:2653cc01-60d7-4e8b-81f4-80b24a39d8f6?page=\(page)&perPage=60&serviceKey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            dump(SAError(.invalidUrl))
            return
        }

        do {
            let areas = try await performRequest(with: url)
            DispatchQueue.main.async {
                self.smokingAreas = areas
            }
        } catch let error as SAError {
            dump(error)
        } catch {
            dump(SAError(.unknownError, description: error.localizedDescription))
        }
    }
}
