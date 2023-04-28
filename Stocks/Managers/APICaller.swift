//
//  APICaller.swift
//  Stocks
//
//  Created by Sergio on 27.04.23.
//

import Foundation

final class APICaller {
    static let shared = APICaller()

    private struct Constants {
        static let apiKey = "ch55u81r01quc2n54r6gch55u81r01quc2n54r70"
        static let sandboxApiKey = ""
        static let baseUrl = "https://finnhub.io/api/v1/"
        static let day: TimeInterval = 3600 * 24
    }
    
    private init() {}

    //MARK: - Public

    public func search(
        query: String,
        completion: @escaping (Result<SearchResponse, Error>) -> Void) {

            guard let safeQuery = query.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed) else {
                return // проверка на пробел
            }

        request(url: url(for: .search, queryParams: ["q":query]),
            expecting: SearchResponse.self,
            completion: completion)
    }

    // search stocks
    public func news(for type: NewsViewController.`Type`, completion: @escaping (Result<[NewStory], Error>) -> Void) {
        switch type {
        case .topStories:
            let url = url(for: .topStories, queryParams: ["category":"general"])
            request(url: url, expecting: [NewStory].self, completion: completion)
        case .compan(let symbol):
            let today = Date()
            let oneMonthBack = today.addingTimeInterval(-(Constants.day * 7))
            let url = url(
                for: .companyNews,
                queryParams: [
                    "symbol":symbol,
                    "from": DateFormatter.newsDateFormatter.string(from: oneMonthBack),
                    "to": DateFormatter.newsDateFormatter.string(from: today)
                ])

            request(url: url, expecting: [NewStory].self, completion: completion)
        }
    }

    //MARK: - Private

    private enum EndPoint: String {
        case search
        case topStories = "news"
        case companyNews = "company-news"
    }

    private enum APIError: Error {
        case noDataReturned
        case invalidUrl
    }

    private func url(
        for endpoint: EndPoint,
        queryParams: [String: String] = [:]) -> URL? {

            var urlString = Constants.baseUrl + endpoint.rawValue

            var queryItems = [URLQueryItem]()

            // add any parameters
            for (name, value) in queryParams {
                queryItems.append(.init(name: name, value: value))
            }
            // add token
            queryItems.append(.init(name: "token", value: Constants.apiKey))

            // Convert queri items to suffix string
            urlString += "?" + queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")

            print("\n\(urlString)\n")
            
            return URL(string: urlString)
        }

    private func request<T: Codable>(
        url: URL?,
        expecting: T.Type,
        completion: @escaping (Result<T, Error>) -> Void) {

            guard let url = url else {
                //Invalid url
                completion(.failure(APIError.invalidUrl))
                return
            }

            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil else {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(APIError.noDataReturned))
                    }
                    return
                }

                do {
                    let result = try JSONDecoder().decode(expecting, from: data)
                    completion(.success(result))//успех
                }
                catch {
                    completion(.failure(error))//неудача
                }
            }
            task.resume()
        }
}
