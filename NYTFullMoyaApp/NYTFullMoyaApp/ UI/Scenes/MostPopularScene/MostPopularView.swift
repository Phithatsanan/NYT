import SwiftUI

struct MostPopularView: View {
    @StateObject private var vm = MostPopularViewModel()
    @State private var selectedArticle: MostPopularArticle?
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // Horizontal chip
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(vm.periods, id: \.self) { p in
                                Button("\(p) Days") {
                                    vm.selectedPeriod = p
                                    Task { await vm.loadMostPopular() }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(vm.selectedPeriod == p ? Color.blue : Color.clear)
                                .foregroundColor(vm.selectedPeriod == p ? .white : .blue)
                                .cornerRadius(16)
                                .overlay(RoundedRectangle(cornerRadius:16).stroke(Color.blue))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                    
                    if let err = vm.errorMessage {
                        Text("Error: \(err)").foregroundColor(.red)
                        Spacer()
                    } else if vm.articles.isEmpty && !vm.isLoading {
                        Text("No articles found.")
                            .foregroundColor(.secondary)
                        Spacer()
                    } else {
                        // Horizontal scroller
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(vm.articles) { art in
                                    Button {
                                        selectedArticle = art
                                    } label: {
                                        NYTCardView(
                                            imageURL: vm.largestImageURL(art),
                                            title: art.title,
                                            subtitle: art.abstract
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                    }
                }
                
                if vm.isLoading {
                    LoadingSpinnerView()
                }
            }
            .navigationTitle("Most Popular")
        }
        .task {
            await vm.loadMostPopular()
        }
        .sheet(item: $selectedArticle) { article in
            MostPopularDetailSheet(article: article)
        }
    }
}

// The detail, same as before (with a sheet):
struct MostPopularDetailSheet: View, Identifiable {
    let article: MostPopularArticle
    var id: String { article.url }
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            MostPopularDetailView(article: article)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                }
        }
    }
}

struct MostPopularDetailView: View {
    let article: MostPopularArticle
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let url = largestImageURL(article) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty: ProgressView()
                        case .success(let img): img.resizable().scaledToFit()
                        case .failure(_): Color.gray.frame(height:200)
                        @unknown default: EmptyView()
                        }
                    }
                }
                Text(article.title).font(.title).bold()
                Text(article.abstract)
                
                if let link = URL(string: article.url) {
                    Link("View Full Article", destination: link)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle("Popular Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func largestImageURL(_ art: MostPopularArticle) -> URL? {
        guard let media = art.media?.first,
              let meta = media.metadata?.last else { return nil }
        return URL(string: meta.url)
    }
}
