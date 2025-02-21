import Foundation
import Moya

final class MyAPIRepository {
    private let provider = MoyaProvider<MyAPITarget>(plugins: [NetworkLoggerPlugin()])
    
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
    
    func getItems() async throws -> [ItemResponse] {
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
