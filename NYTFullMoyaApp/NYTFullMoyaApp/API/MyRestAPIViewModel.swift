import Foundation

final class MyRestAPIViewModel: ObservableObject {
    private let repository: MyAPIRepositoryProtocol
    
    @Published var items: [ItemResponse] = [] {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .dataUpdated, object: nil)
            }
        }
    }
    
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    init(repository: MyAPIRepositoryProtocol) {
        self.repository = repository
        startWebSocketListening() // Start listening for WebSocket updates
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
        let request = ItemRequest(name: name, description: description, createdAt: ISO8601DateFormatter().string(from: Date()))
        
        do {
            let updated = try await repository.updateItem(id: id, request: request)
            if let index = items.firstIndex(where: { $0.id == id }) {
                items[index] = updated
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

    // MARK: - WebSocket Listener
    private func startWebSocketListening() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleWebSocketUpdate(_:)), name: .dataUpdated, object: nil)
    }

    @objc private func handleWebSocketUpdate(_ notification: Notification) {
        guard let update = notification.object as? WebSocketUpdate else { return }
        
        DispatchQueue.main.async {
            switch update.action {
            case "item_added":
                if let newItem = update.item {
                    self.items.append(newItem)
                }
            case "item_updated":
                if let updatedItem = update.item,
                   let index = self.items.firstIndex(where: { $0.id == updatedItem.id }) {
                    self.items[index] = updatedItem
                }
            case "item_deleted":
                if let deletedItem = update.item {
                    self.items.removeAll { $0.id == deletedItem.id }
                }
            default:
                break
            }
        }
    }
}
