import SwiftUI

// MARK: - Models
struct Post: Identifiable, Decodable {
    let id: Int
    let title: String
}

struct User: Identifiable, Decodable {
    let id: Int
    let name: String
}

struct Comment: Identifiable, Decodable {
    let id: Int
    let body: String
}

// MARK: - ViewModel
@MainActor
class ContentViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var users: [User] = []
    @Published var comments: [Comment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchData() async {
        isLoading = true
        errorMessage = nil

        do {
            // Run first two APIs in parallel
            async let postsData: [Post] = fetchPosts()
            async let usersData: [User] = fetchUsers()

            posts = try await postsData
            users = try await usersData

            // Call third API only after both are done
            comments = try await fetchComments()

        } catch {
            errorMessage = "Failed to fetch data: \(error.localizedDescription)"
        }

        isLoading = false
    }

    private func fetchPosts() async throws -> [Post] {
        try await Task.sleep(nanoseconds: 10 * 1_000_000_000) // Delay 10 seconds
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Post].self, from: data)
    }

    private func fetchUsers() async throws -> [User] {
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([User].self, from: data)
    }

    private func fetchComments() async throws -> [Comment] {
        let url = URL(string: "https://jsonplaceholder.typicode.com/comments")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Comment].self, from: data)
    }
}

// MARK: - View
struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List {
                        Section(header: Text("Posts")) {
                            ForEach(viewModel.posts.prefix(5)) { post in
                                Text(post.title)
                                    .lineLimit(2)
                            }
                        }

                        Section(header: Text("Users")) {
                            ForEach(viewModel.users) { user in
                                Text(user.name)
                            }
                        }

                        Section(header: Text("Comments")) {
                            ForEach(viewModel.comments.prefix(5)) { comment in
                                Text(comment.body)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Parallel + Sequential APIs")
            .task {
                await viewModel.fetchData()
            }
        }
    }
}


