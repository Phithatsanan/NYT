// MyRestAPIViewModel.swift
import Foundation

final class MyRestAPIViewModel {
    private let repository: MyAPIRepositoryProtocol
    
    // These hold our "View" state
    private(set) var items: [ItemResponse] = []
    private(set) var errorMessage: String?
    private(set) var isLoading = false
    
    init(repository: MyAPIRepositoryProtocol) {
        self.repository = repository
    }
    
    @MainActor
    func loadItems() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await repository.getItems()
            items = fetched
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    func createItem(name: String, description: String) async {
        isLoading = true
        errorMessage = nil
        let createdAt = ISO8601DateFormatter().string(from: Date())
        let request = ItemRequest(name: name, description: description, createdAt: createdAt)
        
        do {
            let newItem = try await repository.createItem(request: request)
            items.append(newItem)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    func updateItem(id: Int, name: String, description: String) async {
        isLoading = true
        errorMessage = nil
        let request = ItemRequest(
            name: name,
            description: description,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
        
        do {
            let updated = try await repository.updateItem(id: id, request: request)
            if let idx = items.firstIndex(where: { $0.id == id }) {
                items[idx] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    func deleteItem(id: Int) async {
        isLoading = true
        errorMessage = nil
        do {
            try await repository.deleteItem(id: id)
            items.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
