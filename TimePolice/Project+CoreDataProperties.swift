//
//  Project+CoreDataProperties.swift
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

extension Project {

    @NSManaged var created: Date
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var properties: NSObject
    @NSManaged var sessions: NSOrderedSet

}
