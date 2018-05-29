//
//  Country.swift
//  Code-Challenge
//
//  Created by Siddhesh Mahadeshwar on 24/05/18.
//  Copyright © 2018 net.siddhesh. All rights reserved.
//

import UIKit
import CoreData

class Country: NSManagedObject {
  @NSManaged public var id: Int
  @NSManaged public var name: String?
  @NSManaged public var countryCode: String?
  @NSManaged public var status: Bool
  @NSManaged public var isPremium: Bool
  @NSManaged public var shortName: String?
  @NSManaged public var forceExpand: Bool
  @NSManaged public var dnsHostname: String
  @NSManaged public var nodes: NSOrderedSet?
  var expand: Bool = false
}

extension Country {
  @nonobjc public class func fetchRequest() -> NSFetchRequest<Country> {
    return NSFetchRequest<Country>(entityName: "Country")
  }
}
