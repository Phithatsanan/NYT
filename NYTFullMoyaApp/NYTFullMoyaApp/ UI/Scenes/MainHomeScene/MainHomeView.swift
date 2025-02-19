import SwiftUI

struct MainHomeView: View {
    @StateObject private var vm = MainHomeViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    // Less vertical spacing and horizontal padding
                    VStack(alignment: .leading, spacing: 16) {
                        // 1) Top Stories
                        SectionHeader(title: "Featured Top Stories") {
                            vm.selectedTopic = .topStories
                            vm.showAll = true
                        }
                        HorizontalCarousel(
                            items: vm.topStories.prefix(6).map { $0 },
                            imageURL: vm.topStoryImage,
                            title: { $0.title },
                            subtitle: { $0.abstract },
                            cardWidth: 280,    // smaller card
                            cardHeight: 140
                        ) { story in
                            vm.selectedTopStory = story
                        }
                        
                        // 2) Most Popular
                        SectionHeader(title: "Trending Now") {
                            vm.selectedTopic = .mostPopular
                            vm.showAll = true
                        }
                        HorizontalCarousel(
                            items: vm.mostPopular.prefix(6).map { $0 },
                            imageURL: vm.popularImage,
                            title: { $0.title },
                            subtitle: { $0.abstract },
                            cardWidth: 280,
                            cardHeight: 140
                        ) { article in
                            vm.selectedPopular = article
                        }
                        
                        // 3) Books
                        SectionHeader(title: "Book Highlights") {
                            vm.selectedTopic = .books
                            vm.showAll = true
                        }
                        HorizontalCarousel(
                            items: vm.books.prefix(6).map { $0 },
                            imageURL: vm.bookImage,
                            title: { $0.title },
                            subtitle: { $0.author },
                            cardWidth: 160, // narrower
                            cardHeight: 240
                        ) { bk in
                            vm.selectedBook = bk
                        }
                        
                        // 4) Times Wire
                        SectionHeader(title: "Latest Times Wire") {
                            vm.selectedTopic = .timesWire
                            vm.showAll = true
                        }
                        HorizontalCarousel(
                            items: vm.timesWire.prefix(6).map { $0 },
                            imageURL: vm.wireImage,
                            title: { $0.title ?? "" },
                            subtitle: { $0.abstract ?? "" },
                            cardWidth: 280,
                            cardHeight: 140
                        ) { w in
                            vm.selectedWire = w
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
                
                if vm.isLoading {
                    LoadingSpinnerView()
                }
            }
            .navigationTitle("NYT Home")
            .onAppear {
                if !vm.didLoad {
                    Task { await vm.loadAll() }
                }
            }
            // “See All” page
            .sheet(isPresented: $vm.showAll) {
                AllItemsView(topic: vm.selectedTopic)
            }
            // detail sheets
            .sheet(item: $vm.selectedTopStory) { st in
                TopStoryDetailSheet(story: st)
            }
            .sheet(item: $vm.selectedPopular) { pop in
                MostPopularDetailSheet(article: pop)
            }
            .sheet(item: $vm.selectedBook) { b in
                BookDetailSheet(book: b)
            }
            .sheet(item: $vm.selectedWire) { w in
                TimesWireDetailSheet(story: w)
            }
        }
    }
}
