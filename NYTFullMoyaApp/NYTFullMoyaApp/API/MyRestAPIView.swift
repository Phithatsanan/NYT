import SwiftUI

struct MyRestAPIView: View {
    @StateObject private var vm = MyRestAPIViewModel()
    @State private var isAdding = false
    @State private var isEditing = false
    @State private var selectedItem: ItemResponse?

    var body: some View {
        NavigationView {
            VStack {
                if vm.isLoading {
                    ProgressView("Loading...")
                } else {
                    List {
                        ForEach(vm.items) { item in
                            VStack(alignment: .leading) {
                                Text(item.name).font(.headline)
                                Text(item.description).font(.subheadline)
                                Text("Created: \(item.createdAt)").font(.caption).foregroundColor(.gray)
                                HStack {
                                    Button("Edit") {
                                        selectedItem = item
                                        isEditing = true
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    .foregroundColor(.blue)
                                    
                                    Button("Delete") {
                                        Task { await vm.deleteItem(id: item.id) }
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("My RESTful API")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") { isAdding = true }
                }
            }
            .sheet(isPresented: $isAdding) {
                AddItemView { name, description in
                    Task { await vm.createItem(name: name, description: description) }
                }
            }
            .sheet(isPresented: $isEditing) {
                if let item = selectedItem {
                    EditItemView(name: item.name, description: item.description) { newName, newDesc in
                        Task {
                            await vm.updateItem(id: item.id, name: newName, description: newDesc)
                        }
                    }
                }
            }

            .onAppear {
                Task { await vm.loadItems() }
            }
        }
    }
}
