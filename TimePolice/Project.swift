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

    @NSManaged var name: String
    @NSManaged var sessions: NSOrderedSet

}
