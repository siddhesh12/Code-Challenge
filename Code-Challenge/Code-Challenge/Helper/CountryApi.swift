//
//  MovieEndPoint.swift
//  Code-Challenge
//
//  Created by Siddhesh Mahadeshwar on 24/05/18.
//  Copyright © 2018 net.siddhesh. All rights reserved.
//

import Foundation

enum NetworkEnvironment {
  case qa
  case production
  case staging
}

public enum CountryApi {
  case all()
}
//https://assets.windscribe.com/serverlist/ikev2/1/r849yhfueiwgfeuiwbf
extension CountryApi: EndPointType {
  
  var environmentBaseURL : String {
    switch NetworkManager.environment {
    case .production: return "https://assets.windscribe.com"
    case .qa: return "https://qa.windscribe.com"
    case .staging: return "https://staging.windscribe.com"
    }
  }
  
  var baseURL: URL {
    guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL could not be configured.")}
    return url
  }
  
  var path: String {
    switch self {
    case .all():
      return "/serverlist/ikev2/1/r849yhfueiwgfeuiwbf"
    }
  }
}
