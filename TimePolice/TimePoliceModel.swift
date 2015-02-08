//
//  TimePoliceModel.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-02-03.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

import Foundation
import CoreData

/*
class Address: NSManagedObject {

    class func createInMOC(moc: NSManagedObjectContext, street: String, number: String, city:String, country:String) -> Address {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Address", inManagedObjectContext: moc) as Address
        newItem.street = street
        newItem.number = number
        newItem.city = city
        newItem.country = country
        newItem.created = NSDate()

        return newItem
    }

    @NSManaged var street: String
    @NSManaged var number: String
    @NSManaged var city: String
    @NSManaged var country: String
    @NSManaged var created: NSDate
    @NSManaged var persons: NSSet

}
*/

////////////////////////////////////////////////
// Session and SessionTaskListUpdateDelegate

/*
class Session {	
	var name: String!
	var taskList: [Task]!
	var workDone: [Work]!

	init(name: String, taskList: [Task]) {
		self.name = name
		self.taskList = taskList
		self.workDone = []
	}

    var currentWork: Work?

    func taskSignIn(task: Task) {
        currentWork = Work(task: task)
        currentWork?.startTime = NSDate()
    }

    func taskSignOut(task: Task) {
        currentWork?.stopTime = NSDate()
        if let work = currentWork {
            workDone.append(work)
        }
        currentWork = nil
    }
}
*/
/////////////////////////////
// Work and Task

class Work {
	var task: Task!
    var startTime: NSDate!
    var stopTime: NSDate!

	init(task: Task) {
		self.task = task
		startTime = NSDate()
		stopTime = NSDate()
	}

}

func == (lhs: Task, rhs: Task) -> Bool {
    return lhs.id == rhs.id
}

class Task: Equatable {
	var id: String!
	var name: String!

	// Used when creating a new task
	init(name: String) {
        let date = NSDate()
        let dateAndTime = NSDateFormatter.localizedStringFromDate(date,
                    dateStyle: NSDateFormatterStyle.ShortStyle,
                    timeStyle: NSDateFormatterStyle.MediumStyle)
		self.id = "\(dateAndTime) - \(date.timeIntervalSince1970)"
		self.name = name
 	}
 	// Used when deserialized from external storage
	init(id: String, name: String) {
		self.id = id
		self.name = name
	}
}

