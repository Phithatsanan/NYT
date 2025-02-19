import Foundation

struct GetTopStoriesRequest {
    let section: String
    init(section: String = "home") {
        self.section = section
    }
}
