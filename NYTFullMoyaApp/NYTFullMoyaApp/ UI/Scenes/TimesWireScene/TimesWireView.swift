import SwiftUI

struct TimesWireView: View {
    @StateObject private var vm = TimesWireViewModel()
    @State private var selectedStory: WireStory?
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // horizontal chips for sections
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(vm.sections, id: \.self) { sec in
                                Button(sec.capitalized) {
                                    vm.selectedSection = sec
                                    Task { await vm.loadWireStories() }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(vm.selectedSection == sec ? Color.blue : Color.clear)
                                .foregroundColor(vm.selectedSection == sec ? .white : .blue)
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
                    } else if vm.wireStories.isEmpty && !vm.isLoading {
                        Text("No results.")
                            .foregroundColor(.secondary)
                        Spacer()
                    } else {
                        // Horizontal scroller
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(vm.wireStories) { story in
                                    Button {
                                        selectedStory = story
                                    } label: {
                                        NYTCardView(
                                            imageURL: vm.firstImageURL(story),
                                            title: story.title ?? "No Title",
                                            subtitle: story.abstract ?? ""
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
            .navigationTitle("Times Wire")
        }
        .task {
            await vm.loadWireStories()
        }
        .sheet(item: $selectedStory) { ws in
            TimesWireDetailSheet(story: ws)
        }
    }
}

struct TimesWireDetailSheet: View, Identifiable {
    let story: WireStory
    var id: String { story.url }
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            TimesWireDetailView(story: story)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                }
        }
    }
}

struct TimesWireDetailView: View {
    let story: WireStory
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let mm = story.multimedia?.first,
                   let urlStr = mm.url,
                   let url = URL(string: urlStr) {
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
                Text(story.title ?? "No Title").font(.title).bold()
                
                if let abs = story.abstract {
                    Text(abs)
                }
                
                if let published = story.published_date {
                    Text("Published: \(published)")
                        .foregroundColor(.secondary)
                }
                
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
