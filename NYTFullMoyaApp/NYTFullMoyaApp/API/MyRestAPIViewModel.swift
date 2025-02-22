import SwiftUI

@MainActor
class MyRestAPIViewModel: ObservableObject {
    @Published var items: [ItemResponse] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository = MyAPIRepository()
    
    func loadItems() async {
        isLoading = true
        errorMessage = nil
        do {
            items = try await repository.getItems()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func createItem(name: String, description: String) async {
        isLoading = true
        errorMessage = nil
        let createdAt = ISO8601DateFormatter().string(from: Date())
        let request = ItemRequest(name: name, description: description, createdAt: createdAt)
        do {
            let response = try await repository.createItem(request: request)
            items.append(response)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func updateItem(id: Int, name: String, description: String) async {
        isLoading = true
        errorMessage = nil
        let request = ItemRequest(name: name, description: description, createdAt: ISO8601DateFormatter().string(from: Date()))

        do {
            let updatedItem = try await repository.updateItem(id: id, request: request)
            
            if let index = items.firstIndex(where: { $0.id == id }) {
                items[index] = updatedItem
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    
    func deleteItem(id: Int) async {
        isLoading = true
        errorMessage = nil
        do {
            try await repository.deleteItem(id: id)
            
            // ✅ Ensure SwiftUI updates after deletion
            DispatchQueue.main.async {
                self.items.removeAll { $0.id == id }
            }
            
            print("✅ Item deleted from UI: \(id)")
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
            print("❌ Failed to delete from UI: \(error.localizedDescription)")
        }
        isLoading = false
    }
}
