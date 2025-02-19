import Foundation

struct GetBooksRequest {
    let listName: String
    init(listName: String = "hardcover-fiction") {
        self.listName = listName
    }
}
