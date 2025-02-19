import SwiftUI

struct ArticleSearchView: View {
    @StateObject private var vm = ArticleSearchViewModel()
    @State private var selectedDoc: ArticleSearchDoc?
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .leading, spacing: 12) {
                    
                    // Filter panel
                    Text("Advanced Search").font(.headline)
                    
                    HStack {
                        TextField("Search articles...", text: $vm.query)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Begin Date")
                                DatePicker(
                                    "",
                                    selection: Binding<Date>(
                                        get: { vm.beginDate ?? Date() },
                                        set: { vm.beginDate = $0 }
                                    ),
                                    displayedComponents: .date
                                )
                                .labelsHidden()
                            }
                            
                            VStack(alignment: .leading) {
                                Text("End Date")
                                DatePicker(
                                    "",
                                    selection: Binding<Date>(
                                        get: { vm.endDate ?? Date() },
                                        set: { vm.endDate = $0 }
                                    ),
                                    displayedComponents: .date
                                )
                                .labelsHidden()
                            }
                        }

                    
                    HStack {
                        Text("Sort:")
                        Picker("Sort", selection: $vm.sortOrder) {
                            Text("Newest").tag("newest")
                            Text("Oldest").tag("oldest")
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Button(action: {
                        Task { await vm.search() }
                    }) {
                        Text("Search")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Divider().padding(.vertical, 4)
                    
                    // Results
                    if let err = vm.errorMessage {
                        Text("Error: \(err)").foregroundColor(.red)
                        Spacer()
                    } else if vm.articles.isEmpty {
                        Text("No results yet.")
                            .foregroundColor(.secondary)
                        Spacer()
                    } else {
                        // Horizontal scroller of results
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(vm.articles) { doc in
                                    Button {
                                        selectedDoc = doc
                                    } label: {
                                        NYTCardView(
                                            imageURL: vm.firstImageURL(doc),
                                            title: doc.headline?.main ?? "No Title",
                                            subtitle: doc.snippet ?? ""
                                        )
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                .padding()
                
                if vm.isLoading {
                    LoadingSpinnerView()
                }
            }
            .navigationTitle("Article Search")
        }
        .sheet(item: $selectedDoc) { doc in
            ArticleSearchDetailSheet(article: doc)
        }
    }
}

struct ArticleSearchDetailSheet: View, Identifiable {
    let article: ArticleSearchDoc
    var id: String { article._id }
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ArticleSearchDetailView(article: article)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                }
        }
    }
}

struct ArticleSearchDetailView: View {
    let article: ArticleSearchDoc
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // If there's an image
                if let mm = article.multimedia?.first,
                   let part = mm.url,
                   let url = URL(string: "https://www.nytimes.com/\(part)") {
                    AsyncImage(url: url) { phase in
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
                }
                Text(article.headline?.main ?? "")
                    .font(.title).bold()
                if let snippet = article.snippet {
                    Text(snippet)
                }
                if let link = URL(string: article.web_url) {
                    Link("View Full Article", destination: link)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
