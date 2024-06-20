//
//  APIService.swift
//  Base_MVVM_Combine
//
//  Created by Trịnh Xuân Minh on 02/02/2024.
//

import Foundation

final class APIService {
  func request<T: Codable>(from endPoint: EndPoint, body: Data? = nil) async throws -> T {
    guard let request = endPoint.request(body: body) else {
      throw APIError.invalidRequest
    }
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
      throw APIError.invalidResponse
    }
    
    switch httpResponse.statusCode {
    case 200...299:
      break
    default:
      throw APIError.invalidResponse
    }
    
    let decodeData = try JSONDecoder().decode(T.self, from: data)
    return decodeData
  }
}
