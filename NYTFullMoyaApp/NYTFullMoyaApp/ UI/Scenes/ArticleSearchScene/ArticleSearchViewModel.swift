import SwiftUI

@MainActor
class ArticleSearchViewModel: ObservableObject {
    @Published var query: String = ""
    
    // Additional filters
    @Published var beginDate: Date?
    @Published var endDate: Date?
    @Published var sortOrder: String = "newest"
    
    @Published var articles: [ArticleSearchDoc] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repo = NYTRepository()
    
    func search() async {
        guard !query.isEmpty else {
            articles = []
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let req = buildRequest()
            let resp = try await repo.searchArticles(request: req)
            articles = resp.response.docs
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func buildRequest() -> SearchArticlesRequest {
        var req = SearchArticlesRequest(query: query)
        req.beginDate = formatDate(beginDate)   // "yyyyMMdd"
        req.endDate   = formatDate(endDate)
        req.sort      = sortOrder
        return req
    }
    
    private func formatDate(_ date: Date?) -> String? {
        guard let d = date else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: d)
    }
    
    func firstImageURL(_ doc: ArticleSearchDoc) -> URL? {
        guard let mm = doc.multimedia?.first, let part = mm.url else { return nil }
        // The search API often returns partial paths
        return URL(string: "https://www.nytimes.com/\(part)")
    }
}
