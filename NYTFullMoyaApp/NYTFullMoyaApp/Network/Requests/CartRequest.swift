import Foundation

struct CartRequest: Codable {
    let userId: Int
    let date: String  // Format: "YYYY-MM-DD"
    let products: [CartProduct]
}

struct CartProduct: Codable {
    let productId: Int
    let quantity: Int
}
