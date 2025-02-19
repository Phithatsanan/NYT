import SwiftUI

struct TopStoriesView: View {
    @StateObject private var vm = TopStoriesViewModel()
    
    // For the detail sheet
    @State private var selectedStory: TopStory?
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // A horizontal “chips” bar to pick the section
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(vm.sections, id: \.self) { section in
                                Button(section.capitalized) {
                                    vm.selectedSection = section
                                    Task { await vm.loadTopStories() }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(vm.selectedSection == section ? Color.blue : Color.clear)
                                .foregroundColor(vm.selectedSection == section ? .white : .blue)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                            }
                        }
                        .padding()
                    }
                    
                    if let error = vm.errorMessage {
                        Text("Error: \(error)").foregroundColor(.red)
                        Spacer()
                    } else {
                        // HORIZONTAL SCROLL of stories
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(vm.stories) { story in
                                    Button {
                                        selectedStory = story
                                    } label: {
                                        NYTCardView(
                                            imageURL: vm.firstImageURL(story),
                                            title: story.title,
                                            subtitle: story.abstract
                                        )
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
                
                if vm.isLoading {
                    LoadingSpinnerView()
                }
            }
            .navigationTitle("Top Stories")
        }
        .task {
            await vm.loadTopStories()
        }
        .sheet(item: $selectedStory) { st in
            TopStoryDetailSheet(story: st)
        }
    }
}

// A simple detail “sheet” wrapper
struct TopStoryDetailSheet: View, Identifiable {
    var id: String { story.url }
    let story: TopStory
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            TopStoryDetailView(story: story)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                }
        }
    }
}

// The actual detail content
struct TopStoryDetailView: View {
    let story: TopStory
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let mm = story.multimedia?.first,
                   let url = URL(string: mm.url) {
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
                Text(story.title)
                    .font(.title).bold()
                
                Text(story.abstract)
                
                if let link = URL(string: story.url) {
                    Link("View Full Article", destination: link)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
