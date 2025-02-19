import SwiftUI

struct EditItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var name: String
    @State var description: String
    let onSave: (String, String) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Item")) {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                }
            }
            .navigationTitle("Edit Item")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(name, description)  // ✅ Ensure this triggers the update
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.isEmpty || description.isEmpty)
                }
            }
        }
    }
}
