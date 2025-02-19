import SwiftUI

@MainActor
class MostPopularViewModel: ObservableObject {
    @Published var articles: [MostPopularArticle] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let periods = [1,7,30]
    @Published var selectedPeriod = 7
    
    private let repo = NYTRepository()
    
    func loadMostPopular() async {
        isLoading = true
        errorMessage = nil
        do {
            let resp = try await repo.getMostPopular(request: .init(period: selectedPeriod))
            articles = resp.results
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func largestImageURL(_ article: MostPopularArticle) -> URL? {
        guard let media = article.media?.first,
              let meta = media.metadata?.last else { return nil }
        return URL(string: meta.url)
    }
}
