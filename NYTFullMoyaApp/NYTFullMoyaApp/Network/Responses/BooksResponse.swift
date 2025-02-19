import Foundation

struct BooksResponse: Codable {
    let status: String
    let results: BooksResult
}

struct BooksResult: Codable {
    let list_name: String
    let books: [Book]
}

struct Book: Codable, Identifiable {
    var id: String { title + author }
    
    let title: String
    let description: String
    let author: String
    let book_image: String
    let buy_links: [BuyLink]
}

struct BuyLink: Codable {
    let name: String
    let url: String
}
