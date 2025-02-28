import Foundation
import Moya

protocol MyAPIServiceProtocol {
    func fetchItems() async throws -> [ItemResponse]
    func createItem(request: ItemRequest) async throws -> ItemResponse
    func updateItem(id: Int, request: ItemRequest) async throws -> ItemResponse
    func deleteItem(id: Int) async throws
    func startWebSocketListening() // ✅ New WebSocket function
}

final class MyAPIService: MyAPIServiceProtocol {
    private let provider: MoyaProvider<MyAPITarget>
    private var webSocketTask: URLSessionWebSocketTask?

    init(provider: MoyaProvider<MyAPITarget> = MoyaProvider<MyAPITarget>(plugins: [NetworkLoggerPlugin()])) {
        self.provider = provider
        startWebSocketListening() // ✅ Start WebSocket connection
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

    // MARK: - WebSocket Implementation
    func startWebSocketListening() {
        guard let url = URL(string: "ws://localhost:3000") else { return } // ✅ WebSocket Server URL
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        listenForMessages()
    }

    private func listenForMessages() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.handleWebSocketMessage(text)
                default:
                    break
                }
            case .failure(let error):
                print("❌ WebSocket Error: \(error.localizedDescription)")
            }
            self?.listenForMessages() // ✅ Keep listening
        }
    }

    private func handleWebSocketMessage(_ message: String) {
        guard let data = message.data(using: .utf8),
              let update = try? JSONDecoder().decode(WebSocketUpdate.self, from: data) else { return }
        
        NotificationCenter.default.post(name: .dataUpdated, object: update)
    }
}

// MARK: - WebSocket Update Model
struct WebSocketUpdate: Codable {
    let action: String // "item_added", "item_updated", "item_deleted"
    let item: ItemResponse?
}

// MARK: - NotificationCenter Extension for Real-Time Updates
extension Notification.Name {
    static let dataUpdated = Notification.Name("dataUpdated")
}
