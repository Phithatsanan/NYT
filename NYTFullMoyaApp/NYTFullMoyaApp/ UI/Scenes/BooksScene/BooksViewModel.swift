import SwiftUI

@MainActor
class BooksViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let listNames = [
        "hardcover-fiction",
        "hardcover-nonfiction",
        "paperback-nonfiction"
    ]
    @Published var selectedList = "hardcover-fiction"
    
    private let repo = NYTRepository()
    
    func loadBooks() async {
        isLoading = true
        errorMessage = nil
        do {
            let resp = try await repo.getBooks(request: .init(listName: selectedList))
            books = resp.results.books
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
