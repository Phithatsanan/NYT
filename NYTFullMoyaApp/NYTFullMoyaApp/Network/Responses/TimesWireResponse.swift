import Foundation

struct TimesWireResponse: Codable {
    let status: String
    let results: [WireStory]
}

struct WireStory: Codable, Identifiable {
    var id: String { url }
    
    let url: String
    let title: String?
    let abstract: String?
    let section: String?
    let published_date: String?
    let multimedia: [TWMultimedia]?
}

struct TWMultimedia: Codable {
    let url: String?
    let format: String?
    let height: Int?
    let width: Int?
}
