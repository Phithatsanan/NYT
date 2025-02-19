import SwiftUI

struct FakeStorePostView: View {
    @StateObject private var vm = FakeStorePostViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Operation", selection: $vm.selectedOperation) {
                    ForEach(FakeStoreOperation.allCases) { op in
                        Text(op.rawValue).tag(op)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Form {
                    switch vm.selectedOperation {
                    case .product:
                        Section(header: Text("Create Product")) {
                            TextField("Title", text: $vm.productTitle)
                            TextField("Price", text: $vm.productPrice)
                                .keyboardType(.decimalPad)
                            TextField("Description", text: $vm.productDescription)
                            TextField("Image URL", text: $vm.productImage)
                            TextField("Category", text: $vm.productCategory)
                        }
                    case .cart:
                        Section(header: Text("Create Cart")) {
                            TextField("User ID", text: $vm.cartUserId)
                                .keyboardType(.numberPad)
                            TextField("Date (YYYY-MM-DD)", text: $vm.cartDate)
                            TextField("Products (JSON Array)", text: $vm.cartProducts)
                        }
                    case .user:
                        Section(header: Text("Create User")) {
                            TextField("Email", text: $vm.userEmail)
                            TextField("Username", text: $vm.userUsername)
                            SecureField("Password", text: $vm.userPassword)
                            TextField("First Name", text: $vm.userFirstName)
                            TextField("Last Name", text: $vm.userLastName)
                            TextField("City", text: $vm.userCity)
                            TextField("Street", text: $vm.userStreet)
                            TextField("Number", text: $vm.userNumber)
                                .keyboardType(.numberPad)
                            TextField("Zipcode", text: $vm.userZipcode)
                            TextField("Latitude", text: $vm.userLat)
                            TextField("Longitude", text: $vm.userLong)
                            TextField("Phone", text: $vm.userPhone)
                        }
                    case .login:
                        Section(header: Text("User Login")) {
                            TextField("Username", text: $vm.loginUsername)
                            SecureField("Password", text: $vm.loginPassword)
                        }
                    }
                    
                    Section {
                        Button("Submit") {
                            Task { await vm.submit() }
                        }
                    }
                    
                    if !vm.resultText.isEmpty {
                        Section(header: Text("Result")) {
                            Text(vm.resultText)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .navigationTitle("FakeStore POST")
        }
    }
}
