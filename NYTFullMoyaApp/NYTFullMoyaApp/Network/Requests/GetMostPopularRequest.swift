import Foundation

struct GetMostPopularRequest {
    let period: Int
    init(period: Int = 7) {
        self.period = period
    }
}
