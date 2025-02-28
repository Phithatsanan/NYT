import Foundation

final class MyAPIRepository {
    private let service = MyAPIService()
    
    func getItems() async throws -> [ItemResponse] {
        return try await service.fetchItems()
    }
    
    func createItem(request: ItemRequest) async throws -> ItemResponse {
        return try await service.createItem(request: request)
    }

    func updateItem(id: Int, request: ItemRequest) async throws -> ItemResponse {
        return try await service.updateItem(id: id, request: request)
    }

    func deleteItem(id: Int) async throws {
        try await service.deleteItem(id: id)
    }
}
