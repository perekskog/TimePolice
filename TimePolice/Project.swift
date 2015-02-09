//
//  Project.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-02-09.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

import Foundation
import CoreData

class Project: NSManagedObject {

	class func createInMOC(moc: NSManagedObjectContext, name: String) -> Project {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Project", inManagedObjectContext: moc) as Project
        newItem.name = name

        return newItem
    }

    @NSManaged var name: String
    @NSManaged var sessions: NSOrderedSet

}
