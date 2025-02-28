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
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
                        .onSubmit {
                            saveItem()
                        }

                    TextField("Description", text: $description)
                        .textInputAutocapitalization(.sentences)
                        .submitLabel(.done)
                        .onSubmit {
                            saveItem()
                        }
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
                        saveItem()
                    }
                    .disabled(name.isEmpty || description.isEmpty)
                }
            }
        }
    }
    
    private func saveItem() {
        if !name.isEmpty && !description.isEmpty {
            onSave(name, description)
            presentationMode.wrappedValue.dismiss()
        }
    }
}
