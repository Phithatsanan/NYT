import Foundation

extension Date {
    static func convertNYTDateString(
        _ dateString: String,
        fromPattern: String = "yyyy-MM-dd'T'HH:mm:ssZ",
        toPattern: String = "MMM d, yyyy"
    ) -> String {
        let inFormatter = DateFormatter()
        inFormatter.dateFormat = fromPattern
        inFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let outFormatter = DateFormatter()
        outFormatter.dateFormat = toPattern
        outFormatter.locale = Locale(identifier: "en_US")
        
        guard let date = inFormatter.date(from: dateString) else {
            return dateString
        }
        return outFormatter.string(from: date)
    }
}
