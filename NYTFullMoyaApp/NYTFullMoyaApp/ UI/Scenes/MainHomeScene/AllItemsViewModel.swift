import SwiftUI

/// The same “topic” as in MainHomeViewModel
enum AllTopic { case topStories, mostPopular, books, timesWire }

@MainActor
class AllItemsViewModel: ObservableObject {
    @Published var anyItems: [AnyNYTItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Filters for top stories
    let topSections = ["home","world","science","business","sports"]
    @Published var topSection = "home"
    
    // Filters for most popular
    @Published var popPeriod = 7
    
    // Filters for books
    let bookListNames = ["hardcover-fiction","hardcover-nonfiction","paperback-nonfiction"]
    @Published var selectedBookList = "hardcover-fiction"
    
    // Filters for times wire
    let wireSections = ["all","arts","business","opinion","sports"]
    @Published var wireSection = "all"
    
    // For detail
    @Published var selectedItem: AnyNYTItem?
    
    private let repo = NYTRepository()
    
    func loadTopic(_ topic: AllTopic) async {
        isLoading = true
        errorMessage = nil
        do {
            switch topic {
            case .topStories:
                let resp = try await repo.getTopStories(request: .init(section: topSection))
                anyItems = resp.results.map { AnyNYTItem(topStory: $0) }
                
            case .mostPopular:
                let resp = try await repo.getMostPopular(request: .init(period: popPeriod))
                anyItems = resp.results.map { AnyNYTItem(mostPopular: $0) }
                
            case .books:
                let resp = try await repo.getBooks(request: .init(listName: selectedBookList))
                anyItems = resp.results.books.map { AnyNYTItem(book: $0) }
                
            case .timesWire:
                let resp = try await repo.getTimesWire(request: .init(section: wireSection))
                anyItems = resp.results.map { AnyNYTItem(wire: $0) }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

struct AllItemsView: View {
    let topic: MainHomeViewModel.Topic
    @StateObject private var vm = AllItemsViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    filterBar
                    if let error = vm.errorMessage {
                        Text("Error: \(error)").foregroundColor(.red)
                        Spacer()
                    } else {
                        List(vm.anyItems) { item in
                            Button {
                                vm.selectedItem = item
                            } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    AsyncImage(url: item.imageURL) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let img):
                                            img.resizable().scaledToFill()
                                        case .failure(_):
                                            Color.gray
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .frame(width: 80, height: 60)
                                    .cornerRadius(8)
                                    .clipped()
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.title).font(.headline)
                                        Text(item.subtitle).font(.subheadline).foregroundColor(.secondary)
                                            .lineLimit(3)
                                    }
                                }
                            }
                        }
                    }
                }
                if vm.isLoading {
                    LoadingSpinnerView()
                }
            }
            .navigationTitle(navigationTitle)
            .task {
                await vm.loadTopic(toAllTopic(topic))
            }
            .sheet(item: $vm.selectedItem) { aitem in
                VerticalDetailSheet(item: aitem)
            }
        }
    }
    
    private var navigationTitle: String {
        switch topic {
        case .topStories: return "All Top Stories"
        case .mostPopular: return "All Popular"
        case .books: return "All Books"
        case .timesWire: return "All Times Wire"
        }
    }
    
    private func toAllTopic(_ t: MainHomeViewModel.Topic) -> AllTopic {
        switch t {
        case .topStories: return .topStories
        case .mostPopular: return .mostPopular
        case .books: return .books
        case .timesWire: return .timesWire
        }
    }
    
    @ViewBuilder
    private var filterBar: some View {
        switch topic {
        case .topStories:
            Picker("Section", selection: $vm.topSection) {
                ForEach(vm.topSections, id: \.self) { s in
                    Text(s.capitalized).tag(s)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .onChange(of: vm.topSection) { _ in
                Task { await vm.loadTopic(.topStories) }
            }
        case .mostPopular:
            Picker("Period", selection: $vm.popPeriod) {
                ForEach([1,7,30], id: \.self) { p in
                    Text("\(p) Days").tag(p)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .onChange(of: vm.popPeriod) { _ in
                Task { await vm.loadTopic(.mostPopular) }
            }
        case .books:
            Menu {
                ForEach(vm.bookListNames, id: \.self) { list in
                    Button(list.capitalized) {
                        vm.selectedBookList = list
                        Task { await vm.loadTopic(.books) }
                    }
                }
            } label: {
                Text("List: \(vm.selectedBookList.capitalized)").padding()
            }
        case .timesWire:
            Menu {
                ForEach(vm.wireSections, id: \.self) { s in
                    Button(s.capitalized) {
                        vm.wireSection = s
                        Task { await vm.loadTopic(.timesWire) }
                    }
                }
            } label: {
                Text("Section: \(vm.wireSection.capitalized)").padding()
            }
        }
    }
}
