// MARK: - MyAPIService.swift
import Foundation
import Moya

// 1) Protocol
protocol MyAPIServiceProtocol {
    func fetchItems() async throws -> [ItemResponse]
    func createItem(request: ItemRequest) async throws -> ItemResponse
    func updateItem(id: Int, request: ItemRequest) async throws -> ItemResponse
    func deleteItem(id: Int) async throws
}

// 2) Concrete Service
final class MyAPIService: MyAPIServiceProtocol {
    private let provider: MoyaProvider<MyAPITarget>
    
    init(provider: MoyaProvider<MyAPITarget> = MoyaProvider<MyAPITarget>(plugins: [NetworkLoggerPlugin()])) {
        self.provider = provider
    }
    
    private func asyncRequest(_ target: MyAPITarget) async throws -> Response {
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
    
    func fetchItems() async throws -> [ItemResponse] {
        let response = try await asyncRequest(.getItems)
        return try JSONDecoder().decode([ItemResponse].self, from: response.data)
    }
    
    func createItem(request: ItemRequest) async throws -> ItemResponse {
        let response = try await asyncRequest(.createItem(item: request))
        return try JSONDecoder().decode(ItemResponse.self, from: response.data)
    }
    
    func updateItem(id: Int, request: ItemRequest) async throws -> ItemResponse {
        let response = try await asyncRequest(.updateItem(id: id, item: request))
        return try JSONDecoder().decode(ItemResponse.self, from: response.data)
    }
    
    func deleteItem(id: Int) async throws {
        _ = try await asyncRequest(.deleteItem(id: id))
    }
}
