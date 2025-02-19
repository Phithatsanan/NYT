import SwiftUI

@MainActor
class TimesWireViewModel: ObservableObject {
    @Published var wireStories: [WireStory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let sections = ["all","arts","business","opinion","sports"]
    @Published var selectedSection = "all"
    
    private let repo = NYTRepository()
    
    func loadWireStories() async {
        isLoading = true
        errorMessage = nil
        do {
            let resp = try await repo.getTimesWire(request: .init(section: selectedSection))
            wireStories = resp.results
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func firstImageURL(_ story: WireStory) -> URL? {
        guard let mm = story.multimedia?.first,
              let urlStr = mm.url else { return nil }
        return URL(string: urlStr)
    }
}
