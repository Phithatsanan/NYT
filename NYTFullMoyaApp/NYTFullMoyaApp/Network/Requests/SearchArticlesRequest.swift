import Foundation

/// Allows advanced filters for the Article Search
struct SearchArticlesRequest {
    var query: String
    var beginDate: String? = nil  // "yyyyMMdd"
    var endDate: String? = nil
    var sort: String? = nil       // "newest" or "oldest"
    
    init(query: String) {
        self.query = query
    }
}
