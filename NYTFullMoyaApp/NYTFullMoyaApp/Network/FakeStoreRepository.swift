import Foundation
import Moya

final class FakeStoreRepository {
    private let provider = MoyaProvider<FakeStoreTarget>(plugins: [NetworkLoggerPlugin()])
    
    private func asyncRequest(_ target: FakeStoreTarget) async throws -> Response {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // Products
    func createProduct(request: ProductRequest) async throws -> ProductResponse {
        let resp = try await asyncRequest(.createProduct(product: request))
        return try JSONDecoder().decode(ProductResponse.self, from: resp.data)
    }
    
    func updateProduct(id: Int, request: ProductRequest) async throws -> ProductResponse {
        let resp = try await asyncRequest(.updateProduct(id: id, product: request))
        return try JSONDecoder().decode(ProductResponse.self, from: resp.data)
    }
    
    func deleteProduct(id: Int) async throws -> ProductResponse {
        let resp = try await asyncRequest(.deleteProduct(id: id))
        return try JSONDecoder().decode(ProductResponse.self, from: resp.data)
    }
    
    // Carts
    func createCart(request: CartRequest) async throws -> CartResponse {
        let resp = try await asyncRequest(.createCart(cart: request))
        return try JSONDecoder().decode(CartResponse.self, from: resp.data)
    }
    
    func updateCart(id: Int, request: CartRequest) async throws -> CartResponse {
        let resp = try await asyncRequest(.updateCart(id: id, cart: request))
        return try JSONDecoder().decode(CartResponse.self, from: resp.data)
    }
    
    func deleteCart(id: Int) async throws -> CartResponse {
        let resp = try await asyncRequest(.deleteCart(id: id))
        return try JSONDecoder().decode(CartResponse.self, from: resp.data)
    }
    
    // Users
    func createUser(request: UserRequest) async throws -> UserResponse {
        let resp = try await asyncRequest(.createUser(user: request))
        return try JSONDecoder().decode(UserResponse.self, from: resp.data)
    }
    
    func updateUser(id: Int, request: UserRequest) async throws -> UserResponse {
        let resp = try await asyncRequest(.updateUser(id: id, user: request))
        return try JSONDecoder().decode(UserResponse.self, from: resp.data)
    }
    
    func deleteUser(id: Int) async throws -> UserResponse {
        let resp = try await asyncRequest(.deleteUser(id: id))
        return try JSONDecoder().decode(UserResponse.self, from: resp.data)
    }
    
    // Login
    func login(request: LoginRequest) async throws -> LoginResponse {
        let resp = try await asyncRequest(.login(credentials: request))
        return try JSONDecoder().decode(LoginResponse.self, from: resp.data)
    }
}
