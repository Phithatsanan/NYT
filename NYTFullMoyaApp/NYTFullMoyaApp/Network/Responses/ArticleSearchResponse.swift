import Foundation

struct ArticleSearchResponse: Codable {
    let status: String
    let response: ArticleSearchInner
}

struct ArticleSearchInner: Codable {
    let docs: [ArticleSearchDoc]
}

struct ArticleSearchDoc: Codable, Identifiable {
    var id: String { _id }
    
    let _id: String
    let web_url: String
    let snippet: String?
    let headline: Headline?
    let multimedia: [ASMultimedia]?
}

struct Headline: Codable {
    let main: String
}

struct ASMultimedia: Codable {
    let url: String?
    let subtype: String?
    let type: String?
}
