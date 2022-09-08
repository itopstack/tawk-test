//
//  MyError.swift
//  TawkTest
//
//  Created by Kittisak Phetrungnapha on 8/9/2565 BE.
//

import Foundation

enum MyError: LocalizedError {
    case invalidURL
    case invalidStatusCode
    case missingResult
    case missingData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidStatusCode:
            return "Invalid status code"
        case .missingResult:
            return "Result is missing"
        case .missingData:
            return "Data is missing"
        }
    }
}
