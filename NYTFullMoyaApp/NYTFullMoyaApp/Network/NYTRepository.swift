import Foundation
import Moya

final class NYTRepository {
    private let provider = MoyaProvider<NYTTarget>(plugins: [NetworkLoggerPlugin()])
    
    private func asyncRequest(_ target: NYTTarget) async throws -> Response {
        return try await withCheckedThrowingContinuation { continuation in
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
    
    func getTopStories(request: GetTopStoriesRequest) async throws -> TopStoriesResponse {
        let resp = try await asyncRequest(.topStories(section: request.section))
        return try JSONDecoder().decode(TopStoriesResponse.self, from: resp.data)
    }
    
    func getMostPopular(request: GetMostPopularRequest) async throws -> MostPopularResponse {
        let resp = try await asyncRequest(.mostPopular(period: request.period))
        return try JSONDecoder().decode(MostPopularResponse.self, from: resp.data)
    }
    
    func getBooks(request: GetBooksRequest) async throws -> BooksResponse {
        let resp = try await asyncRequest(.books(listName: request.listName))
        return try JSONDecoder().decode(BooksResponse.self, from: resp.data)
    }
    
    func getTimesWire(request: GetTimesWireRequest) async throws -> TimesWireResponse {
        let resp = try await asyncRequest(.timesWire(section: request.section))
        return try JSONDecoder().decode(TimesWireResponse.self, from: resp.data)
    }
    
    func searchArticles(request: SearchArticlesRequest) async throws -> ArticleSearchResponse {
        let resp = try await asyncRequest(.searchArticles(request))
        return try JSONDecoder().decode(ArticleSearchResponse.self, from: resp.data)
    }
}
