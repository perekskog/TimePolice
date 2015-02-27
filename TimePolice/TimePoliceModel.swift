//
//  TimePoliceModel.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-02-03.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

import Foundation
import CoreData
import UIKit


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
    
    func getSessionSummary(moc: NSManagedObjectContext) -> [Task: (Int, NSTimeInterval)] {
        var sessionSummary: [Task: (Int, NSTimeInterval)] = [:]

        self.work.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
            let work = elem as Work
            let task = work.task
            var taskSummary: (Int, NSTimeInterval) = (0, 0)
            if let t = sessionSummary[task] {
                taskSummary = t
            }
            var (activations, totalTime) = taskSummary
            activations++
            totalTime += work.stopTime.timeIntervalSinceDate(work.startTime)
            sessionSummary[task] = (activations, totalTime)
        }

        return sessionSummary
    }

    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var project: Project
    @NSManaged var tasks: NSOrderedSet
    @NSManaged var work: NSOrderedSet

}

class Task: NSManagedObject {

    class func createInMOC(moc: NSManagedObjectContext, name: String) -> Task {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Task", inManagedObjectContext: moc) as Task

        let date = NSDate()
        let dateAndTime = NSDateFormatter.localizedStringFromDate(date,
                    dateStyle: NSDateFormatterStyle.ShortStyle,
                    timeStyle: NSDateFormatterStyle.MediumStyle)
        newItem.id = "[Task] \(dateAndTime) - \(date.timeIntervalSince1970)"
        newItem.name = name

        return newItem
    }

    @NSManaged var name: String
    @NSManaged var id: String
    @NSManaged var sessions: NSSet
    @NSManaged var work: NSOrderedSet

}

class Work: NSManagedObject {

    class func createInMOC(moc: NSManagedObjectContext, name: String) -> Work {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Work", inManagedObjectContext: moc) as Work

        let date = NSDate()
        let dateAndTime = NSDateFormatter.localizedStringFromDate(date,
                    dateStyle: NSDateFormatterStyle.ShortStyle,
                    timeStyle: NSDateFormatterStyle.MediumStyle)
        newItem.id = "[Work] \(dateAndTime) - \(date.timeIntervalSince1970)"
        newItem.name = name

        return newItem
    }

    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var startTime: NSDate
    @NSManaged var stopTime: NSDate
    @NSManaged var session: Session
    @NSManaged var task: Task

}


//-------------------------------------
// TimePoliceModel - Debug
//-------------------------------------

class TimePoliceModelUtils {

    class func save(moc: NSManagedObjectContext) {
        var error : NSError?
        if(moc.save(&error) ) {
            println("Save: error(\(error?.localizedDescription))")
        }

    }

    class func clearAllData(moc: NSManagedObjectContext) {
        var fetchRequest: NSFetchRequest

        // Delete all work
        fetchRequest = NSFetchRequest(entityName: "Work")
        if let fetchResults = moc.executeFetchRequest(fetchRequest, error: nil) as? [Work] {
            for work in fetchResults {
                moc.deleteObject(work)
            }
        }

        // Delete all tasks
        fetchRequest = NSFetchRequest(entityName: "Task")
        if let fetchResults = moc.executeFetchRequest(fetchRequest, error: nil) as? [Task] {
            for task in fetchResults {
                moc.deleteObject(task)
            }
        }

        // Delete all sessions
        fetchRequest = NSFetchRequest(entityName: "Session")
        if let fetchResults = moc.executeFetchRequest(fetchRequest, error: nil) as? [Session] {
            for session in fetchResults {
                moc.deleteObject(session)
            }
        }

        // Delete all projects
        fetchRequest = NSFetchRequest(entityName: "Project")
        if let fetchResults = moc.executeFetchRequest(fetchRequest, error: nil) as? [Project] {
            for project in fetchResults {
                moc.deleteObject(project)
            }
        }
    }

    class func dumpAllData(moc: NSManagedObjectContext) {
        var fetchRequest: NSFetchRequest

        println("---------------------------")
        println("----------Project----------\n")
        fetchRequest = NSFetchRequest(entityName: "Project")
        if let fetchResults = moc.executeFetchRequest(fetchRequest, error: nil) as? [Project] {
            for project in fetchResults {
                println("P: \(project.name)-\(project.id)")
                for session in project.sessions {
                    println("    S: \(session.name)-\(session.id)")
                    let s = session as Session  // Why is this needed?
                    println("        P: \(s.project.name)-\(session.project.id)")
                }
            }
        }

        println("\n---------------------------")
        println("----------Session----------\n")
        fetchRequest = NSFetchRequest(entityName: "Session")
        if let fetchResults = moc.executeFetchRequest(fetchRequest, error: nil) as? [Session] {
            for session in fetchResults {
                println("S: \(session.name)-\(session.id)")
                println("    P: \(session.project.name)-\(session.project.id)")
                session.work.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
                    let work = elem as Work
                    println("W: \(work.task.name) \(work.startTime)->\(work.stopTime)")
                }
                session.tasks.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
                    let task = elem as Task
                    println("    T: \(task.name)")
                }
            }
        }

        println("\n------------------------")
        println("----------Work----------\n")
        fetchRequest = NSFetchRequest(entityName: "Work")
        if let fetchResults = moc.executeFetchRequest(fetchRequest, error: nil) as? [Work] {
            for work in fetchResults {
                println("W: \(work.task.name) \(work.startTime)->\(work.stopTime)")
            }
        }

        println("\n------------------------")
        println("----------Task----------\n")
        fetchRequest = NSFetchRequest(entityName: "Task")
        if let fetchResults = moc.executeFetchRequest(fetchRequest, error: nil) as? [Task] {
            for task in fetchResults {
                println("T: \(task.name)")
            }
        }

    }

    class func dumpSessionWork(session: Session) {

        println("\n---------------------------")
        println("----------Session----------\n")
        println("S: \(session.name)-\(session.id)")
        println("    P: \(session.project.name)-\(session.project.id)")
        session.work.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
            let work = elem as Work
            println("W: \(work.task.name) \(work.startTime)->\(work.stopTime)")
        }
    }

    class func getSessionWork(session: Session) -> String {

        var s: String

        s = "\n---------------------------"
        s += "\n----------Session----------"
        s += "\nS: \(session.name)-\(session.id)"
        s += "\n    P: \(session.project.name)-\(session.project.id)"
        session.work.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
            let work = elem as Work
            s += "\n    W: \(work.task.name) \(work.startTime)->\(work.stopTime)"
        }

        return s
    }

}

//----------------------------------------
// TimePoliceModel - Test data
//----------------------------------------

class TestData {

    class func addTestData1(managedObjectContext: NSManagedObjectContext) {
        var project1: Project
        var session11: Session
        var taskListHome: [Task]

        project1 = Project.createInMOC(managedObjectContext, name: "Home \(getString(NSDate()))")

        session11 = Session.createInMOC(managedObjectContext, name: "Home \(getString(NSDate()))")
        session11.project = project1
        project1.sessions = NSSet(array: [session11])

        // Personal
        taskListHome = [ 
            Task.createInMOC(managedObjectContext, name: "I F2F"),
            Task.createInMOC(managedObjectContext, name: "---"),
            Task.createInMOC(managedObjectContext, name: "I Chat"),

            Task.createInMOC(managedObjectContext, name: "I Email"),
            Task.createInMOC(managedObjectContext, name: "---"),
            Task.createInMOC(managedObjectContext, name: "I Blixt"),

            Task.createInMOC(managedObjectContext, name: "P OF"),
            Task.createInMOC(managedObjectContext, name: "---"),
            Task.createInMOC(managedObjectContext, name: "P Lista"),

            Task.createInMOC(managedObjectContext, name: "P Hushåll"),
            Task.createInMOC(managedObjectContext, name: "---"),
            Task.createInMOC(managedObjectContext, name: "P Other"),

            Task.createInMOC(managedObjectContext, name: "N Waste"),
            Task.createInMOC(managedObjectContext, name: "---"),
            Task.createInMOC(managedObjectContext, name: "N Work"),

            Task.createInMOC(managedObjectContext, name: "N Connect"),
            Task.createInMOC(managedObjectContext, name: "N Down"),
            Task.createInMOC(managedObjectContext, name: "N Time-in"),

            Task.createInMOC(managedObjectContext, name: "N Physical"),
            Task.createInMOC(managedObjectContext, name: "N Coffe/WC"),
            Task.createInMOC(managedObjectContext, name: "N Other"),
        ]

        session11.tasks = NSOrderedSet(array: taskListHome)
    }

    class func addTestData2(managedObjectContext: NSManagedObjectContext) {

        var project2: Project
        var session21: Session
        var session22: Session
        var taskListWork: [Task]
        
        project2 = Project.createInMOC(managedObjectContext, name: "Work \(getString(NSDate()))")
        
        session21 = Session.createInMOC(managedObjectContext, name: "Work 1 \(getString(NSDate()))")
        session21.project = project2
        session22 = Session.createInMOC(managedObjectContext, name: "Work 2 \(getString(NSDate()))")
        session22.project = project2
        project2.sessions = NSSet(array:[session21, session22])
        
        
        // Work
        taskListWork = [
            Task.createInMOC(managedObjectContext, name: "I F2F"),
            Task.createInMOC(managedObjectContext, name: "---"),
            Task.createInMOC(managedObjectContext, name: "I Lync"),
            
            Task.createInMOC(managedObjectContext, name: "I Email"),
            Task.createInMOC(managedObjectContext, name: "I Ticket"),
            Task.createInMOC(managedObjectContext, name: "I Blixt"),
            
            Task.createInMOC(managedObjectContext, name: "P OF"),
            Task.createInMOC(managedObjectContext, name: "P Task"),
            Task.createInMOC(managedObjectContext, name: "P Ticket"),
            
            Task.createInMOC(managedObjectContext, name: "P US"),
            Task.createInMOC(managedObjectContext, name: "P Meeting"),
            Task.createInMOC(managedObjectContext, name: "P Other"),
            
            Task.createInMOC(managedObjectContext, name: "N Waste"),
            Task.createInMOC(managedObjectContext, name: "---"),
            Task.createInMOC(managedObjectContext, name: "N Not work"),
            
            Task.createInMOC(managedObjectContext, name: "N Connect"),
            Task.createInMOC(managedObjectContext, name: "N Down"),
            Task.createInMOC(managedObjectContext, name: "N Time-in"),
            
            Task.createInMOC(managedObjectContext, name: "N Physical"),
            Task.createInMOC(managedObjectContext, name: "N Coffe/WC"),
            Task.createInMOC(managedObjectContext, name: "N Other"),
        ]
        
        session21.tasks = NSOrderedSet(array: taskListWork)
        session22.tasks = NSOrderedSet(array: taskListWork)
        
    }

}

