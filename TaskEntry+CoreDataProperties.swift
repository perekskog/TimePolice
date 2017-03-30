//
//  TaskEntry+CoreDataProperties.swift
//  TimePolice
//
//  Created by Per Ekskog on 2016-01-25.
//  Copyright © 2016 Per Ekskog. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TaskEntry {

    @NSManaged var created: Date
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var properties: NSObject
    @NSManaged var startTime: Date
    @NSManaged var stopTime: Date
    @NSManaged var session: Session
    @NSManaged var task: Task

}
