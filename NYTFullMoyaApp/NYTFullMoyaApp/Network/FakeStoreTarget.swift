import Foundation
import Moya

enum FakeStoreTarget {
    // Products endpoints
    case createProduct(product: ProductRequest)
    case updateProduct(id: Int, product: ProductRequest)
    case deleteProduct(id: Int)
    
    // Carts endpoints
    case createCart(cart: CartRequest)
    case updateCart(id: Int, cart: CartRequest)
    case deleteCart(id: Int)
    
    // Users endpoints
    case createUser(user: UserRequest)
    case updateUser(id: Int, user: UserRequest)
    case deleteUser(id: Int)
    
    // Login endpoint
    case login(credentials: LoginRequest)
}

extension FakeStoreTarget: TargetType {
    var baseURL: URL {
        URL(string: "https://fakestoreapi.com")!
    }
    
    var path: String {
        switch self {
        case .createProduct:
            return "/products"
        case .updateProduct(let id, _):
            return "/products/\(id)"
        case .deleteProduct(let id):
            return "/products/\(id)"
            
        case .createCart:
            return "/carts"
        case .updateCart(let id, _):
            return "/carts/\(id)"
        case .deleteCart(let id):
            return "/carts/\(id)"
            
        case .createUser:
            return "/users"
        case .updateUser(let id, _):
            return "/users/\(id)"
        case .deleteUser(let id):
            return "/users/\(id)"
            
        case .login:
            return "/auth/login"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createProduct, .createCart, .createUser, .login:
            return .post
        case .updateProduct, .updateCart, .updateUser:
            return .put
        case .deleteProduct, .deleteCart, .deleteUser:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .createProduct(let product):
            return .requestJSONEncodable(product)
        case .updateProduct(_, let product):
            return .requestJSONEncodable(product)
        case .deleteProduct:
            return .requestPlain
            
        case .createCart(let cart):
            return .requestJSONEncodable(cart)
        case .updateCart(_, let cart):
            return .requestJSONEncodable(cart)
        case .deleteCart:
            return .requestPlain
            
        case .createUser(let user):
            return .requestJSONEncodable(user)
        case .updateUser(_, let user):
            return .requestJSONEncodable(user)
        case .deleteUser:
            return .requestPlain
            
        case .login(let credentials):
            return .requestJSONEncodable(credentials)
        }
    }
    
    var headers: [String : String]? {
        ["Content-type": "application/json"]
    }
    
    var sampleData: Data { Data() }
}
