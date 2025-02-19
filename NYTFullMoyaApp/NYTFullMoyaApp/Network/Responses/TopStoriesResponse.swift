import Foundation

struct TopStoriesResponse: Codable {
    let status: String
    let results: [TopStory]
}

struct TopStory: Codable, Identifiable {
    var id: String { url }
    
    let section: String
    let title: String
    let abstract: String
    let url: String
    
    // Multimedia array for images
    let multimedia: [TSMultimedia]?
}

struct TSMultimedia: Codable {
    let url: String
    let format: String?
    let height: Int?
    let width: Int?
}
