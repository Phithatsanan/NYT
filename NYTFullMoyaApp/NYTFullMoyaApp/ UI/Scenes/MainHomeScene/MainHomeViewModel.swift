import SwiftUI

@MainActor
class MainHomeViewModel: ObservableObject {
    @Published var topStories: [TopStory] = []
    @Published var mostPopular: [MostPopularArticle] = []
    @Published var books: [Book] = []
    @Published var timesWire: [WireStory] = []
    
    @Published var isLoading = false
    @Published var didLoad = false
    
    enum Topic { case topStories, mostPopular, books, timesWire }
    @Published var selectedTopic: Topic = .topStories
    @Published var showAll = false
    
    // For detail sheets
    @Published var selectedTopStory: TopStory?
    @Published var selectedPopular: MostPopularArticle?
    @Published var selectedBook: Book?
    @Published var selectedWire: WireStory?
    
    private let repo = NYTRepository()
    
    func loadAll() async {
        isLoading = true
        defer { isLoading = false; didLoad = true }
        do {
            let topResp = try await repo.getTopStories(request: .init(section: "home"))
            topStories = topResp.results
            
            let popResp = try await repo.getMostPopular(request: .init(period: 7))
            mostPopular = popResp.results
            
            let booksResp = try await repo.getBooks(request: .init(listName: "hardcover-fiction"))
            books = booksResp.results.books
            
            let wireResp = try await repo.getTimesWire(request: .init(section: "all"))
            timesWire = wireResp.results
        } catch {
            print("Error loading home data: \(error)")
        }
    }
    
    func topStoryImage(_ story: TopStory) -> URL? {
        story.multimedia?.first.flatMap { URL(string: $0.url) }
    }
    func popularImage(_ article: MostPopularArticle) -> URL? {
        guard let media = article.media?.first,
              let meta = media.metadata?.last else { return nil }
        return URL(string: meta.url)
    }
    func bookImage(_ book: Book) -> URL? {
        URL(string: book.book_image)
    }
    func wireImage(_ wire: WireStory) -> URL? {
        guard let mm = wire.multimedia?.first, let urlStr = mm.url else { return nil }
        return URL(string: urlStr)
    }
}
