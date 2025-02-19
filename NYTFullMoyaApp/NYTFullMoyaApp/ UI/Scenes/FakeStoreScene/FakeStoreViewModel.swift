import SwiftUI

enum FakeStoreOperation: String, CaseIterable, Identifiable {
    case product = "Product"
    case cart = "Cart"
    case user = "User"
    case login = "Login"
    
    var id: String { self.rawValue }
}

@MainActor
class FakeStorePostViewModel: ObservableObject {
    @Published var selectedOperation: FakeStoreOperation = .product
    @Published var resultText: String = ""
    @Published var isLoading: Bool = false
    
    // Product sample defaults (from fakestoreapi example)
    @Published var productTitle: String = "test product"
    @Published var productPrice: String = "13.5"
    @Published var productDescription: String = "lorem ipsum set"
    @Published var productImage: String = "https://i.pravatar.cc"
    @Published var productCategory: String = "electronic"
    
    // Cart sample defaults
    @Published var cartUserId: String = "5"
    @Published var cartDate: String = "2020-02-03"
    // Use a JSON string representing an array of CartProduct objects.
    // Example: [{ "productId": 5, "quantity": 1 }, { "productId": 1, "quantity": 5 }]
    @Published var cartProducts: String = "[{\"productId\":5,\"quantity\":1},{\"productId\":1,\"quantity\":5}]"
    
    // User sample defaults
    @Published var userEmail: String = "John@gmail.com"
    @Published var userUsername: String = "johnd"
    @Published var userPassword: String = "m38rmF$"
    @Published var userFirstName: String = "John"
    @Published var userLastName: String = "Doe"
    @Published var userCity: String = "kilcoole"
    @Published var userStreet: String = "7835 new road"
    @Published var userNumber: String = "3"
    @Published var userZipcode: String = "12926-3874"
    @Published var userLat: String = "-37.3159"
    @Published var userLong: String = "81.1496"
    @Published var userPhone: String = "1-570-236-7033"
    
    // Login sample defaults (using known test credentials from FakeStore API)
    @Published var loginUsername: String = "mor_2314"
    @Published var loginPassword: String = "83r5^_"
    
    private let repository = FakeStoreRepository()
    
    func submit() async {
        isLoading = true
        resultText = ""
        do {
            switch selectedOperation {
            case .product:
                guard let price = Double(productPrice) else {
                    resultText = "Invalid price value."
                    isLoading = false
                    return
                }
                let req = ProductRequest(
                    title: productTitle,
                    price: price,
                    description: productDescription,
                    image: productImage,
                    category: productCategory
                )
                let resp = try await repository.createProduct(request: req)
                resultText = "Product created with ID \(resp.id)"
                
            case .cart:
                guard let userId = Int(cartUserId) else {
                    resultText = "Invalid user ID."
                    isLoading = false
                    return
                }
                // Decode cartProducts from JSON string into [CartProduct]
                guard let data = cartProducts.data(using: .utf8),
                      let products = try? JSONDecoder().decode([CartProduct].self, from: data) else {
                    resultText = "Invalid products JSON."
                    isLoading = false
                    return
                }
                let req = CartRequest(
                    userId: userId,
                    date: cartDate,
                    products: products
                )
                let resp = try await repository.createCart(request: req)
                resultText = "Cart created with ID \(resp.id)"
                
            case .user:
                guard let number = Int(userNumber) else {
                    resultText = "Invalid street number."
                    isLoading = false
                    return
                }
                let req = UserRequest(
                    email: userEmail,
                    username: userUsername,
                    password: userPassword,
                    name: Name(firstname: userFirstName, lastname: userLastName),
                    address: Address(
                        city: userCity,
                        street: userStreet,
                        number: number,
                        zipcode: userZipcode,
                        geolocation: Geolocation(lat: userLat, long: userLong)
                    ),
                    phone: userPhone
                )
                let resp = try await repository.createUser(request: req)
                resultText = "User created with ID \(resp.id)"
                
            case .login:
                let req = LoginRequest(username: loginUsername, password: loginPassword)
                let resp = try await repository.login(request: req)
                resultText = "Login successful. Token: \(resp.token)"
            }
        } catch {
            resultText = "Error: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
