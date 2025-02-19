import SwiftUI

// A type-erased item so we can store them in a single [AnyNYTItem] array
struct AnyNYTItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let imageURL: URL?
    let detailType: DetailType
    
    enum DetailType {
        case topStory(TopStory)
        case mostPopular(MostPopularArticle)
        case book(Book)
        case wire(WireStory)
    }
    
    init(topStory: TopStory) {
        self.id = topStory.url
        self.title = topStory.title
        self.subtitle = topStory.abstract
        if let mm = topStory.multimedia?.first {
            self.imageURL = URL(string: mm.url)
        } else {
            self.imageURL = nil
        }
        self.detailType = .topStory(topStory)
    }
    
    init(mostPopular: MostPopularArticle) {
        self.id = mostPopular.url
        self.title = mostPopular.title
        self.subtitle = mostPopular.abstract
        if let media = mostPopular.media?.first,
           let meta = media.metadata?.last {
            self.imageURL = URL(string: meta.url)
        } else {
            self.imageURL = nil
        }
        self.detailType = .mostPopular(mostPopular)
    }
    
    init(book: Book) {
        self.id = book.title + book.author
        self.title = book.title
        self.subtitle = book.author
        self.imageURL = URL(string: book.book_image)
        self.detailType = .book(book)
    }
    
    init(wire: WireStory) {
        self.id = wire.url
        self.title = wire.title ?? "No Title"
        self.subtitle = wire.abstract ?? ""
        if let mm = wire.multimedia?.first,
           let urlStr = mm.url {
            self.imageURL = URL(string: urlStr)
        } else {
            self.imageURL = nil
        }
        self.detailType = .wire(wire)
    }
}

extension AnyNYTItem: Equatable {
    static func ==(lhs: AnyNYTItem, rhs: AnyNYTItem) -> Bool {
        lhs.id == rhs.id
    }
}

// A sheet that picks the correct detail view based on detailType
struct VerticalDetailSheet: View {
    let item: AnyNYTItem
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        switch item.detailType {
        case .topStory(let st):
            NavigationView {
                TopStoryDetailView(story: st)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { dismiss() }
                        }
                    }
            }
        case .mostPopular(let art):
            NavigationView {
                MostPopularDetailView(article: art)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { dismiss() }
                        }
                    }
            }
        case .book(let bk):
            NavigationView {
                BookDetailView(book: bk)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { dismiss() }
                        }
                    }
            }
        case .wire(let ws):
            NavigationView {
                TimesWireDetailView(story: ws)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { dismiss() }
                        }
                    }
            }
        }
    }
}
