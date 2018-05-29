//
//  NetworkManager.swift
//  Code-Challenge
//
//  Created by Siddhesh Mahadeshwar on 24/05/18.
//  Copyright © 2018 net.siddhesh. All rights reserved.
//

import Foundation
import SwiftyJSON

enum Result<T> {
  case success(T)
  case failure(String)
}

enum NetworkResult<String>{
  case success
  case failure(String)
}

enum NetworkResponse:String {
  case success
  case authenticationError = "You need to be authenticated first."
  case badRequest = "Bad request"
  case outdated = "The url you requested is outdated."
  case failed = "Network request failed."
  case noData = "Response returned with no data to decode."
  case unableToDecode = "We could not decode the response."
}

final class NetworkManager {
  static let configuration = URLSessionConfiguration.default
  static let environment : NetworkEnvironment = .production
  static let shared = NetworkManager()
  
  func getCountries(completion: @escaping (Result<[JSON]>) -> ()) {
    let request = self.buildRequest(from: CountryApi.all())
    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
      let response = response as? HTTPURLResponse
      DispatchQueue.main.async {
        if let e = error {
          completion(.failure(e.localizedDescription))
        } else if let response = response {
          let result = self.handleNetworkResponse(response)
          switch result {
          case .success:
            guard let data = data else {
              completion(.failure(NetworkResponse.noData.rawValue))
              return
            }
            let json = JSON(data)
            guard let jsonArray = json["data"].array else {
              completion(.failure(NetworkResponse.badRequest.rawValue))
              return
            }
            completion(.success(jsonArray))
          case .failure(let networkFailureError):
            completion(.failure(networkFailureError))
          }
        }
      }
    })
    task.resume()
  }
  
  fileprivate func buildRequest(from route: EndPointType) -> URLRequest {
    return URLRequest(url: route.baseURL.appendingPathComponent(route.path),
                             cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                             timeoutInterval: 10.0)
  }
}

extension NetworkManager {
  fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> NetworkResult<String>{
    switch response.statusCode {
    case 200...299: return .success
    case 401...500: return .failure(NetworkResponse.authenticationError.rawValue)
    case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
    case 600: return .failure(NetworkResponse.outdated.rawValue)
    default: return .failure(NetworkResponse.failed.rawValue)
    }
  }
}

