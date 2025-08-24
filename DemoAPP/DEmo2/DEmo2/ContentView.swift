//
//  ContentView.swift
//  DEmo2
//
//  Created by rajnikanthole on 12/08/25.
//

import SwiftUI
import CoreData


// MARK: - Entities
struct Post: Codable, Identifiable { let id: Int; let title: String }
struct User: Codable, Identifiable { let id: Int; let name: String }
struct Comment: Codable, Identifiable { let id: Int; let body: String }

// MARK: - Repository Protocol
protocol DataRepository {
    func fetchPosts() async throws -> [Post]
    func fetchUsers() async throws -> [User]
    func fetchComments() async throws -> [Comment]
}

// MARK: - Repository Implementation
final class NetworkRepository: DataRepository {
    
    private func fetch<T: Decodable>(from urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func fetchPosts() async throws -> [Post] {
        try await fetch(from: "https://jsonplaceholder.typicode.com/posts")
    }
    
    func fetchUsers() async throws -> [User] {
        try await fetch(from: "https://jsonplaceholder.typicode.com/users")
    }
    
    func fetchComments() async throws -> [Comment] {
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000) // simulate delay
        return try await fetch(from: "https://jsonplaceholder.typicode.com/comments")
    }
}

// MARK: - Use Case
final class FetchDataUseCase {
    private let repository: DataRepository
    init(repository: DataRepository) { self.repository = repository }
    
    func execute() async -> (posts: [Post], users: [User], comments: [Comment]) {

        print("1111 execute \(Thread.current.isMainThread)")
        
        let repository = NetworkRepository()
                
                do {
                    let (posts, users) = try await withThrowingTaskGroup(of: (String, Any).self) { group in
                        
                        group.addTask {
                            print("1111 posts \(Thread.current.isMainThread)")
                            return ("posts", try await repository.fetchPosts())

                        }
                        group.addTask {
                            ("users", try await repository.fetchUsers())
                        }
                        
                        var posts: [Post] = []
                        var users: [User] = []
                        
                        for try await (label, value) in group {
                            switch label {
                            case "posts": posts = value as? [Post] ?? []
                            case "users": users = value as? [User] ?? []
                            default: break
                            }
                        }
                        
                        return (posts, users)
                    }
                    
                    print("Posts count:", posts.count)
                    print("Users count:", users.count)
                    
                    // After both finish → fetch comments
                    try await Task.sleep(nanoseconds: 10_000_000_000)
                    
                    
                              let comments = try await repository.fetchComments()
                    print("comments count:", posts.count)
                              return (posts, users, comments)
                    
                    
                    return (posts, users, comments)
                    
                } catch {
                    print("Error:", error)
                    return ([], [], [])
                }
        return ([], [], [])
    }
}

// MARK: - ViewModel
@MainActor
final class ContentViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var users: [User] = []
    @Published var comments: [Comment] = []
    @Published var isLoading = false
    
    private let fetchDataUseCase: FetchDataUseCase
    
    init(fetchDataUseCase: FetchDataUseCase) {
        self.fetchDataUseCase = fetchDataUseCase
    }
    
    func loadData() {
        
       // print("1111 loadData 1 \(Thread.current.isMainThread)")
  
        
        Task(priority: .high) {
            isLoading = true
            let result = await fetchDataUseCase.execute()
            
            print("1111 loadData 2 \(Thread.current.isMainThread)")
            posts = result.posts
            users = result.users
            comments = result.comments
            isLoading = false
        }
    }
}

// MARK: - UI
struct ContentView: View {
    @StateObject private var viewModel: ContentViewModel
    
    init() {
        let repository = NetworkRepository()
        let useCase = FetchDataUseCase(repository: repository)
        _viewModel = StateObject(wrappedValue: ContentViewModel(fetchDataUseCase: useCase))
    }
    
    var body: some View {
        NavigationView {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        SectionView(title: "Posts", items: viewModel.posts.prefix(5).map { $0.title })
                        SectionView(title: "Users", items: viewModel.users.prefix(5).map { $0.name })
                        SectionView(title: "Comments", items: viewModel.comments.prefix(5).map { $0.body })
                    }
                    .padding()
                }
               // .navigationTitle("Data")
            }
        }
        .onAppear { viewModel.loadData() }
    }
}

struct SectionView: View {
    let title: String
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                        ForEach(items, id: \.self) { item in
                            NavigationLink (destination: DetailView(item: item)){
                            Text(item)
                                .frame(width: 150, height: 80)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}


struct DetailView: View {
    let item: String
    
    var body: some View {
        VStack {
            Text("Detail View for \(item)")
                .font(.largeTitle)
                .padding()
                .foregroundColor(.red)
            Spacer()
        }
        .navigationTitle("")
        .navigationBarTitle("", displayMode: .inline) // hides title space
       // .navigationBarHidden(true) // hides navigation bar entirely
    }
}
