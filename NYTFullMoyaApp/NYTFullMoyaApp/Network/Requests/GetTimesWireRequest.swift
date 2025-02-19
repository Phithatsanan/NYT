import Foundation

struct GetTimesWireRequest {
    let section: String
    init(section: String = "all") {
        self.section = section
    }
}
