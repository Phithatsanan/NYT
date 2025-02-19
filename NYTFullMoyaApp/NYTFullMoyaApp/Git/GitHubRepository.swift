import Foundation
import Moya

final class GitHubRepository {
    private let provider = MoyaProvider<GitHubTarget>(plugins: [NetworkLoggerPlugin()])
    
    private func asyncRequest(_ target: GitHubTarget) async throws -> Response {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getUsers() async throws -> [GitHubUser] {
        let response = try await asyncRequest(.getUsers)
        return try JSONDecoder().decode([GitHubUser].self, from: response.data)
    }
}
