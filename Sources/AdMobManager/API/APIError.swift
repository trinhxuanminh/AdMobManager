//
//  APIError.swift
//  Base_MVVM_Combine
//
//  Created by Trịnh Xuân Minh on 02/02/2024.
//

import Foundation

enum APIError: Error {
  case invalidRequest
  case invalidResponse
  case jsonEncodingError
  case jsonDecodingError
  case notInternet
  case anyError
}
