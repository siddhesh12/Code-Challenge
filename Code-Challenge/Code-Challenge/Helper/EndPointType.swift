//
//  EndPointType.swift
//  Code-Challenge
//
//  Created by Siddhesh Mahadeshwar on 24/05/18.
//  Copyright © 2018 net.siddhesh. All rights reserved.
//

import Foundation

protocol EndPointType {
  var baseURL: URL { get }
  var path: String { get }
}
