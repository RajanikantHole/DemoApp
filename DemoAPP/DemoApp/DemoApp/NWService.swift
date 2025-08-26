//
//  NWService.swift
//  DemoApp
//
//  Created by rajnikanthole on 26/08/25.
//

import Foundation

enum APIError: Error {
    
    case URLWRong
    case DataNil
    case APIIssue
    
}

struct NWService {
    
    static func getData<T: Decodable>(urlString: String)  async throws -> T {
        
        guard let url = URL(string: urlString) else {
            throw APIError.URLWRong
        }
        
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        }
        catch {
            throw APIError.APIIssue
        }
    }
}
