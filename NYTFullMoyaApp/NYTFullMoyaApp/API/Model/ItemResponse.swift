import Foundation

struct ItemResponse: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let createdAt: String
}
