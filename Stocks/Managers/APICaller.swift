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
        static let apiKey = ""
        static let sandboxApiKey = ""
        static let baseUrl = ""
    }
    
    private init() {}

    //MARK: - Public

    // get stock info

    // search stocks

    //MARK: - Private

    private enum EndPoint: String {
        case search
    }

    private enum APIError: Error {
        case noDataReturned
        case invalidUrl
    }

    private func url(
        for endpoint: EndPoint,
        queryParams: [String: String] = [:]) -> URL? {

            return nil
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