import SwiftUI


@MainActor
class ViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var users: [User] = []
    @Published var comments: [Comment] = []
    @Published var isLoading = true
    
    func fetchData() {
        Task {
            isLoading = true
            await withTaskGroup(of: Void.self) { group in
                group.addTask { [weak self] in
                    guard let self = self else { return }
                   // try? await Task.sleep(nanoseconds: 10 * 1_000_000_000) // Delay posts
                    if let posts = try? await self.fetchPosts() {
                        await MainActor.run { self.posts = posts }
                    }
                }
                
                group.addTask { [weak self] in
                    guard let self = self else { return }
                    if let users = try? await self.fetchUsers() {
                        await MainActor.run { self.users = users }
                    }
                }
            }
            
            // Third API after both complete
            isLoading = false
            if let comments = try? await fetchComments() {
                self.comments = comments
            }
            
            isLoading = false
        }
    }
    
    private func fetchPosts() async throws -> [Post] {
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
        try? await Task.sleep(nanoseconds: 2 * 1_000_000_000) // Delay posts
        let url = URL(string: "https://jsonplaceholder.typicode.com/comments")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Comment].self, from: data)
    }
}

struct SecionViewS: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
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
                .navigationTitle("Data")
            }
        }
        .onAppear {
            viewModel.fetchData()
        }
    }
}

struct SectionView: View {
    let title: String
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(items, id: \.self) { item in
                        
                        NavigationLink(destination: ZstackExample()) {
                            
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

