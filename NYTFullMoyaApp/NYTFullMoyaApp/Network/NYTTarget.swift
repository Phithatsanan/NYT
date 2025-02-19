import Foundation
import Moya

enum NYTTarget {
    case topStories(section: String)
    case mostPopular(period: Int)
    case books(listName: String)
    case timesWire(section: String)
    case searchArticles(SearchArticlesRequest)
}

extension NYTTarget: TargetType {
    var baseURL: URL {
        URL(string: "https://api.nytimes.com/svc")!
    }
    
    var path: String {
        switch self {
        case .topStories(let section):
            return "/topstories/v2/\(section).json"
        case .mostPopular(let period):
            return "/mostpopular/v2/viewed/\(period).json"
        case .books(let listName):
            return "/books/v3/lists/current/\(listName).json"
        case .timesWire(let section):
            return "/news/v3/content/nyt/\(section).json"
        case .searchArticles:
            return "/search/v2/articlesearch.json"
        }
    }
    
    var method: Moya.Method { .get }
    
    var task: Task {
        var params: [String: Any] = [:]
        params["api-key"] = ""  // <--- Replace with your NYT key

        switch self {
        case .searchArticles(let req):
            params["q"] = req.query
            if let b = req.beginDate { params["begin_date"] = b } // e.g. "20230101"
            if let e = req.endDate   { params["end_date"] = e }
            if let s = req.sort      { params["sort"] = s }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
            
        case .topStories, .mostPopular, .books, .timesWire:
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        ["Content-type": "application/json"]
    }
    
    var sampleData: Data { Data() }
}
