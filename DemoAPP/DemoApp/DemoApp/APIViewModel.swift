//
//  APIViewModel.swift
//  DemoApp
//
//  Created by rajnikanthole on 26/08/25.
//

import Foundation
import SwiftUI


struct UserNew: Decodable, Identifiable {
    var id: Int?
    var username: String?
}

class APIViewModel: ObservableObject {
    
    @Published var users: [UserNew] = []
    
    @MainActor
    func getAPIData() {
        Task {
        users = try await NWService.getData(urlString: "https://jsonplaceholder.typicode.com/users")
        }
    }
}
