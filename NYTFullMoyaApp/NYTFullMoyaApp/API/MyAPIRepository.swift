// MARK: - MyAPIRepository.swift
import Foundation

// 1) Protocol
protocol MyAPIRepositoryProtocol {
    func getItems() async throws -> [ItemResponse]
    func createItem(request: ItemRequest) async throws -> ItemResponse
    func updateItem(id: Int, request: ItemRequest) async throws -> ItemResponse
    func deleteItem(id: Int) async throws
}

// 2) Concrete Repository
final class MyAPIRepository: MyAPIRepositoryProtocol {
    private let service: MyAPIServiceProtocol
    
    init(service: MyAPIServiceProtocol) {
        self.service = service
    }
    
    func getItems() async throws -> [ItemResponse] {
        try await service.fetchItems()
    }
    
    func createItem(request: ItemRequest) async throws -> ItemResponse {
        try await service.createItem(request: request)
    }
    
    func updateItem(id: Int, request: ItemRequest) async throws -> ItemResponse {
        try await service.updateItem(id: id, request: request)
    }
    
    func deleteItem(id: Int) async throws {
        try await service.deleteItem(id: id)
    }
}
