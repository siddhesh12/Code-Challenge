//
//  CountryService.swift
//  Code-Challenge
//
//  Created by Siddhesh Mahadeshwar on 25/05/18.
//  Copyright © 2018 net.siddhesh. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

final class CountryService {
  let managedObjectContext: NSManagedObjectContext
  let coreDataStack: DataStack
  var completion: ((Result<Bool>) -> ())?

  init(managedObjectContext: NSManagedObjectContext, coreDataStack: DataStack) {
    self.managedObjectContext = managedObjectContext
    self.coreDataStack = coreDataStack
  }
}

// MARK:- public
extension CountryService {
  
  func insertAll(rawArray: [JSON], completion: @escaping (Result<Bool>) -> ()) {
    let fetch: NSFetchRequest<Country> = Country.fetchRequest()
    let count = try! coreDataStack.mainContext.count(for: fetch)
    // we can add logic for syncing between server and local db. 
    if count > 0 {
      completion(.success(true))
      return
    }
    
    self.completion = completion
    rawArray.forEach { dictionary in
      if let id  = dictionary["id"].int,
        let name = dictionary["name"].string,
        let dnsHostName = dictionary["dns_hostname"].string,
        let status = dictionary["status"].int {
        
        let country = Country(context: coreDataStack.mainContext)
        country.id = id
        country.name = name
        country.dnsHostname = dnsHostName
        country.status = Bool(truncating: status as NSNumber)
        country.countryCode = dictionary["country_code"].string
        country.isPremium = dictionary["isPre"].bool ?? false
        country.shortName = dictionary["short_name"].string
        country.forceExpand = dictionary["force_expand"].bool ?? false
        
        if let nodesArray = dictionary["nodes"].array {
          nodesArray.forEach { nodeDictionary in
            guard let hostName  = nodeDictionary["hostname"].string,
              let weight = nodeDictionary["weight"].int else { return }
            
            let node = Node(context: coreDataStack.mainContext)
            node.hostName = hostName
            node.ip = nodeDictionary["ip"].string
            node.ip2 = nodeDictionary["ip2"].string
            node.ip3 = nodeDictionary["ip3"].string
            node.weight = weight
            node.group = nodeDictionary["group"].string
            node.proOnly = nodeDictionary["pro_only"].bool ?? false
            if let nodes = country.nodes?.mutableCopy() as? NSMutableOrderedSet {
              nodes.add(node)
              country.nodes = nodes
            }
          }
        }
      }
    }
    do {
         try self.coreDataStack.mainContext.save()
    } catch let error {
      print(error)
      self.completion?(.failure(error.localizedDescription))
    }
  }
  
  func getCountries() -> [Country] {
    let fetchRequest: NSFetchRequest<Country> = Country.fetchRequest()
    fetchRequest.fetchBatchSize = 20
    var results: [Country]
    do {
      try results = managedObjectContext.fetch(fetchRequest)
    } catch {
      results = []
    }
    
    return results
  }
}

