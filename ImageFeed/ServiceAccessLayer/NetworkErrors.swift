//
//  NetworkErrors.swift
//  ImageFeed
//
//  Created by Leo Gabuev on 24.05.2026.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}

enum AuthServiceError: Error {
    case invalidRequest
}
