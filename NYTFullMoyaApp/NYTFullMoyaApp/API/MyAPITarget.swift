// MARK: - MyAPITarget.swift
import Foundation
import Moya

enum MyAPITarget {
    case getItems
    case createItem(item: ItemRequest)
    case updateItem(id: Int, item: ItemRequest)
    case deleteItem(id: Int)
}

extension MyAPITarget: TargetType {
    var baseURL: URL {
        URL(string: "http://localhost:3000/api")!
    }
    
    var path: String {
        switch self {
        case .getItems, .createItem:
            return "/items"
        case .updateItem(let id, _), .deleteItem(let id):
            return "/items/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getItems:     return .get
        case .createItem:   return .post
        case .updateItem:   return .put
        case .deleteItem:   return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .getItems:
            return .requestPlain
        case .createItem(let item),
             .updateItem(_, let item):
            return .requestJSONEncodable(item)
        case .deleteItem:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        ["Content-type": "application/json"]
    }
}
