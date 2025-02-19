import SwiftUI

@MainActor
class TopStoriesViewModel: ObservableObject {
    @Published var stories: [TopStory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // For user to pick a section
    let sections = ["home","world","technology","science","sports"]
    @Published var selectedSection: String = "home"
    
    private let repo = NYTRepository()
    
    func loadTopStories() async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await repo.getTopStories(request: .init(section: selectedSection))
            stories = response.results
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // Return the first image URL from `multimedia`
    func firstImageURL(_ story: TopStory) -> URL? {
        guard let mm = story.multimedia?.first else { return nil }
        return URL(string: mm.url)
    }
}
