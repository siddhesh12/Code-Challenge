//
//  Node.swift
//  Code-Challenge
//
//  Created by Siddhesh Mahadeshwar on 24/05/18.
//  Copyright © 2018 net.siddhesh. All rights reserved.
//

import UIKit
import CoreData

class Node: NSManagedObject {
  @NSManaged public var ip: String?
  @NSManaged public var ip2: String?
  @NSManaged public var ip3: String?
  @NSManaged public var hostName: String
  @NSManaged public var weight: Int
  @NSManaged public var group: String?
  @NSManaged public var forceExpand: Bool
  @NSManaged public var proOnly: Bool
  @NSManaged public var country: Country?
}

extension Node {
  @nonobjc public class func fetchRequest() -> NSFetchRequest<Node> {
    return NSFetchRequest<Node>(entityName: "Node")
  }
}
