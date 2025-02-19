import Foundation

struct ProductRequest: Codable {
    let title: String
    let price: Double
    let description: String
    let image: String
    let category: String
}
