//
//  TimePoliceModel.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-02-03.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

import Foundation
import CoreData


class Project: NSManagedObject {

    class func createInMOC(moc: NSManagedObjectContext, name: String) -> Project {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Project", inManagedObjectContext: moc) as Project

        let date = NSDate()
        let dateAndTime = NSDateFormatter.localizedStringFromDate(date,
                    dateStyle: NSDateFormatterStyle.ShortStyle,
                    timeStyle: NSDateFormatterStyle.MediumStyle)
        newItem.id = "[Project] \(dateAndTime) - \(date.timeIntervalSince1970)"
        newItem.name = name

        return newItem
    }

    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var sessions: NSSet

}

class Session: NSManagedObject {

    class func createInMOC(moc: NSManagedObjectContext, name: String) -> Session {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Session", inManagedObjectContext: moc) as Session

        let date = NSDate()
        let dateAndTime = NSDateFormatter.localizedStringFromDate(date,
                    dateStyle: NSDateFormatterStyle.ShortStyle,
                    timeStyle: NSDateFormatterStyle.MediumStyle)
        newItem.id = "[Session] \(dateAndTime) - \(date.timeIntervalSince1970)"
        newItem.name = name

        return newItem
    }

    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var currentWork: Work
    @NSManaged var project: Project
    @NSManaged var workDone: NSOrderedSet
    @NSManaged var taskList: NSOrderedSet

}

class Work: NSManagedObject {

    class func createInMOC(moc: NSManagedObjectContext) -> Work {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Work", inManagedObjectContext: moc) as Work

        let date = NSDate()
        let dateAndTime = NSDateFormatter.localizedStringFromDate(date,
                    dateStyle: NSDateFormatterStyle.ShortStyle,
                    timeStyle: NSDateFormatterStyle.MediumStyle)
        newItem.id = "[Work] \(dateAndTime) - \(date.timeIntervalSince1970)"

        return newItem
    }

    @NSManaged var startTime: NSDate
    @NSManaged var stopTime: NSDate
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var session: Session
    @NSManaged var task: Task

}

class Task: NSManagedObject {

    class func createInMOC(moc: NSManagedObjectContext, name: String) -> Task {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Task", inManagedObjectContext: moc) as Task

        newItem.name = name

        return newItem
    }

    @NSManaged var name: String

}

class SessionTemplate: NSManagedObject {

    class func createInMOC(moc: NSManagedObjectContext, name: String) -> SessionTemplate {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("SessionTemplate", inManagedObjectContext: moc) as SessionTemplate

        let date = NSDate()
        let dateAndTime = NSDateFormatter.localizedStringFromDate(date,
                    dateStyle: NSDateFormatterStyle.ShortStyle,
                    timeStyle: NSDateFormatterStyle.MediumStyle)
        newItem.id = "[SessionTemplate] \(dateAndTime) - \(date.timeIntervalSince1970)"
        newItem.name = name

        return newItem
    }

    @NSManaged var name: String
    @NSManaged var id: String
    @NSManaged var taskList: NSOrderedSet

}

