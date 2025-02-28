import SwiftUI

struct MyRestAPIView: View {
    @StateObject private var vm = MyRestAPIViewModel()
    @State private var isAdding = false
    @State private var isEditing = false
    @State private var selectedItem: ItemResponse?

    var body: some View {
        NavigationView {
            List {
                ForEach(vm.items) { item in
                    VStack(alignment: .leading) {
                        Text(item.name).font(.headline)
                        Text(item.description).font(.subheadline)
                        Text("Created: \(item.createdAt)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            Task { await vm.deleteItem(id: item.id) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            selectedItem = item
                            isEditing = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
            .refreshable {
                await vm.loadItems()
            }
            .navigationTitle("My REST API")
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
