//
//  Work+CoreDataProperties.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-11-02.
//  Copyright © 2015 Per Ekskog. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Work {

    @NSManaged var created: NSDate
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var startTime: NSDate
    @NSManaged var stopTime: NSDate
    @NSManaged var properties: NSObject
    @NSManaged var session: Session
    @NSManaged var task: Task

}
