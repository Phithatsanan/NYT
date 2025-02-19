import SwiftUI

// Model that maps to the JSON sample from GitHub
struct GitHubUser: Codable, Identifiable {
    let login: String
    let id: Int
    let node_id: String?
    let avatar_url: String
    let gravatar_id: String?
    let url: String
    let html_url: String
    let followers_url: String?
    let following_url: String?
    let gists_url: String?
    let starred_url: String?
    let subscriptions_url: String?
    let organizations_url: String?
    let repos_url: String?
    let events_url: String?
    let received_events_url: String?
    let type: String?
    let user_view_type: String?
    let site_admin: Bool?

    var idValue: Int { id }
}

@MainActor
class GitHubUsersViewModel: ObservableObject {
    @Published var users: [GitHubUser] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let repository = GitHubRepository()
    
    func loadUsers() async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await repository.getUsers()
            self.users = result
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
