import Foundation

struct MostPopularResponse: Codable {
    let status: String
    let results: [MostPopularArticle]
}

struct MostPopularArticle: Codable, Identifiable {
    var id: String { url }
    
    let url: String
    let title: String
    let abstract: String
    
    // "media" array can contain images
    let media: [MPMedia]?
}

struct MPMedia: Codable {
    let type: String?
    
    // "media-metadata"
    let metadata: [MPMediaMetadata]?
    enum CodingKeys: String, CodingKey {
        case type
        case metadata = "media-metadata"
    }
}

struct MPMediaMetadata: Codable {
    let url: String
    let format: String
    let height: Int
    let width: Int
}
