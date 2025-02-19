import SwiftUI

struct BooksView: View {
    @StateObject private var vm = BooksViewModel()
    @State private var selectedBook: Book?
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // Horizontal “chips” for list names
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(vm.listNames, id: \.self) { list in
                                Button(list.replacingOccurrences(of: "-", with: " ").capitalized) {
                                    vm.selectedList = list
                                    Task { await vm.loadBooks() }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(vm.selectedList == list ? Color.blue : Color.clear)
                                .foregroundColor(vm.selectedList == list ? .white : .blue)
                                .cornerRadius(16)
                                .overlay(RoundedRectangle(cornerRadius:16).stroke(Color.blue))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 0)
                    }
                    
                    if let err = vm.errorMessage {
                        Text("Error: \(err)").foregroundColor(.red)
                        Spacer()
                    } else if vm.books.isEmpty && !vm.isLoading {
                        Text("No books found.")
                            .foregroundColor(.secondary)
                        Spacer()
                    } else {
                        // Horizontal scroller
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(vm.books) { book in
                                    Button {
                                        selectedBook = book
                                    } label: {
                                        // A bigger card
                                        BookCardView(
                                            book: book,
                                            width: 180,  // was 160, make it bigger
                                            height: 280  // was 240, try 280 or 320
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 20)
                        }

                    }
                }
                
                if vm.isLoading {
                    LoadingSpinnerView()
                }
            }
            .navigationTitle("NYT Books")
        }
        .task {
            await vm.loadBooks()
        }
        .sheet(item: $selectedBook) { book in
            BookDetailSheet(book: book)
        }
    }
}

// A detail “sheet”
struct BookDetailSheet: View, Identifiable {
    let book: Book
    var id: String { book.title + book.author }
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            BookDetailView(book: book)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                }
        }
    }
}

struct BookDetailView: View {
    let book: Book
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: book.book_image)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let img):
                        img.resizable().scaledToFit()
                    case .failure(_):
                        Color.gray.frame(height: 200)
                    @unknown default:
                        EmptyView()
                    }
                }
                Text(book.title).font(.title).bold()
                Text("by \(book.author)").foregroundColor(.secondary)
                Text(book.description)
                
                Divider()
                Text("Buy Links:").font(.headline)
                ForEach(book.buy_links, id: \.url) { link in
                    Link(link.name, destination: URL(string: link.url)!)
                }
            }
            .padding()
        }
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
