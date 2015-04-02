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


//=======================================================================================
//=======================================================================================
//  Project
//=======================================================================================

class Project: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var sessions: NSSet

   //---------------------------------------------
    // Project - createInMOC
    //---------------------------------------------

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

    //---------------------------------------------
    // Project - findInMOC
    //---------------------------------------------

    class func findInMOC(moc: NSManagedObjectContext, name: String) -> [Project]? {

        let fetchRequest = NSFetchRequest(entityName: "Project")
        let predicate = NSPredicate(format: "name == %@", name) 
        fetchRequest.predicate = predicate

        let fetchResults = moc.executeFetchRequest(fetchRequest, error: nil) as? [Project]

        return fetchResults
    }

}

//=======================================================================================
//=======================================================================================
//  Session
//=======================================================================================

class Session: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var project: Project
    @NSManaged var tasks: NSOrderedSet
    @NSManaged var work: NSOrderedSet

    //---------------------------------------------
    // Session - createInMOC
    //---------------------------------------------

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
    
    //---------------------------------------------
    // Session - getSessionSummary
    //---------------------------------------------

    func getSessionSummary(moc: NSManagedObjectContext) -> [Task: (Int, NSTimeInterval)] {
        var sessionSummary: [Task: (Int, NSTimeInterval)] = [:]

        self.work.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
            let work = elem as Work
            // For all items but one that is ongoing
            if work.startTime != work.stopTime {
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
        }

        return sessionSummary
    }
    
    //---------------------------------------------
    // Session - getLastWork
    //---------------------------------------------

    func getLastWork() -> Work? {
        if work.count >= 1 {
            return work[work.count-1] as? Work
        } else {
            return nil
        }
    }

    //---------------------------------------------
    // Session modifications - Rules to follow
    //---------------------------------------------

/*
    Rules for modification of list of work in a session.

    * Only last item can be ongoing. 
    * If an item is ongoing, there can't be a successor => stopTime can be changed freely

    Notation:
    | = fixed time
    > = ongoing
    ? = can be fixed time or ongoing
    *** = 0 or more items
    +++ = 1 or more items
    ::: = a gap in time
    ... = possible gap in time
    0 = now
    tx = some specific time

*/




    //---------------------------------------------
    // Session - setStartTime
    //---------------------------------------------

/*
             workToModify
    <c1     |------------?
         t1       t2           0
    
                 previousWork       workToModify
    <c2     *** |------------| ... |------------?
                |    t1        t2        t3           0

                 previousWork       workToModify
    <c3     *** |------------| ... |------------| ... +++
                |    t1        t2        t3     |

Future extensions

- t3/t4 depends on other changes (t3/t4 means that workToModify will become ongoing at some future point in time)

             workToModify
    <c10    |------------?
         t1       t2        0   t3
    
                 previousWork       workToModify
    <c11    *** |------------| ... |------------?
                     t1        t2        t3         0   t4

*/

    func setStartTime(moc: NSManagedObjectContext, workIndex: Int, desiredStartTime: NSDate) {
        if workIndex >= work.count {
            // Index points to non existing item
            return
        }

        var targetTime = desiredStartTime
        let workToModify = work[workIndex] as Work
        if workIndex == 0 {
            // y1, y2, y3
            if workToModify.isOngoing() || targetTime.compare(workToModify.stopTime) == NSComparisonResult.OrderedAscending {
                // Modify stopTime if work is ongoing
                workToModify.stopTime = targetTime
            }
            workToModify.startTime = targetTime
        } else {
            // Not the first item => There is a previous item
            let previousWork = work[workIndex-1] as Work

            if targetTime.compare(previousWork.stopTime) == NSComparisonResult.OrderedDescending {
                // workToModify will not overlap with previousWork
                // x4
                if workToModify.isOngoing() {
                    // Modify stopTime if work is ongoing
                    workToModify.stopTime = targetTime
                }
                workToModify.startTime = targetTime
            } else {
                // workToModify will overlap with previousWork
                if targetTime.compare(previousWork.startTime) == NSComparisonResult.OrderedDescending {
                    // targetTime points to a time between start and stop of previousWork => adjust stoptime of previousWork
                    // x2
                    previousWork.stopTime = targetTime
                    if workToModify.isOngoing() {
                        // Modify stopTime if work is ongoing
                        workToModify.stopTime = targetTime
                    }
                    workToModify.startTime = targetTime
                } else {
                    // targetTime points to a time before start of previousWork => adjust targetTime AND start/stop of previousWork
                    // x1
                    targetTime = previousWork.startTime
                    previousWork.startTime = targetTime
                    previousWork.stopTime = targetTime

                    if workToModify.isOngoing() {
                        // Modify stopTime if work is ongoing
                        workToModify.stopTime = targetTime
                    }
                    workToModify.startTime = targetTime
                }
            }
        }


        TimePoliceModelUtils.save(moc)
    }

    //---------------------------------------------
    // Session - setStopTime
    //---------------------------------------------

/*
                 workToModify
    >c1     *** |------------?
                |     t1         0
    
                 workToModify       nextWork
    >c2     *** |------------| ... |-------->
                |     t1        t2     t3        0

                 workToModify       nextWork
    >c3     *** |------------| ... |--------| ***
                |     t1        t2     t3   |

Future extensions

- t3/t4 depend on other chnages (t3/t4 = workToModify will be stopped in the future)

                 workToModify
    >c10    *** |------------?
                      t2         0   t3
*/


    func setStopTime(workIndex: Int, stopTime: NSDate) {

    }




    //---------------------------------------------
    // Session - deletePreviousWorkAndAlignStart
    //---------------------------------------------

/*
    GUI operation: "swipeUp"

             workToModify
    N/A     |------------? ***


             previousWork       workToModify                      workToModify
    pc1 *** |------------| ... |------------? ***     ==>    *** |------------? ***
            1            2     3            4                    1            4
*/
    func deletePreviousWorkAndAlignStart(workIndex: Int) {

    }




    //---------------------------------------------
    // Session - deleteNextWorkAndAlignStop
    //---------------------------------------------

/*
    GUI operation: "swipeDown"


             workToModify
    N/A *** |------------?


             workToModify       nextWork                      workToModify
    pc1 *** |------------| ... |--------? ***     ==>    *** |------------? ***
            1            2     3        4                    1            4
*/
    func deleteNextWorkAndAlignStop(workIndex: Int) {

    }





    //---------------------------------------------
    // Session - deleteWork
    //---------------------------------------------

/*
    GUI operation: "swipeLR"

             workToModify
    pc1 *** |------------? ***                       ==>  ***  (removed)  ***
*/

    func deleteWork(workIndex: Int) {

    }





    //---------------------------------------------
    // Session - insertWork
    //---------------------------------------------

/*
    GUI operation: ???


*/

    func insertWork(workIndex: Int, work: Work) {

    }

}



//=======================================================================================
//=======================================================================================
//  Task
//=======================================================================================

class Task: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var id: String
    @NSManaged var sessions: NSSet
    @NSManaged var work: NSOrderedSet

    //---------------------------------------------
    // Task - createInMOC
    //---------------------------------------------

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

}

//=======================================================================================
//=======================================================================================
//  Work
//=======================================================================================

class Work: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var startTime: NSDate
    @NSManaged var stopTime: NSDate
    @NSManaged var session: Session
    @NSManaged var task: Task

    //---------------------------------------------
    // Work - createInMOC
    //---------------------------------------------

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
    
    //---------------------------------------------
    // Work - isOngoing
    //---------------------------------------------

    func isOngoing() -> Bool {
        if startTime == stopTime {
            return true
        } else {
            return false
        }
    }

}


//=======================================================================================
//=======================================================================================
//  TimePoliceModelUtils
//=======================================================================================

class TimePoliceModelUtils {

    //---------------------------------------------
    // TimePoliceModelUtils - save
    //---------------------------------------------

    class func save(moc: NSManagedObjectContext) {
        var error : NSError?
        if(moc.save(&error) ) {
            println("Save: error(\(error?.localizedDescription))")
        }

    }

    //---------------------------------------------
    // TimePoliceModelUtils - clearAllData
    //---------------------------------------------

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

    //---------------------------------------------
    // TimePoliceModelUtils - dumpAllData
    //---------------------------------------------

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

    //---------------------------------------------
    // TimePoliceModelUtils - getSessionWork
    //---------------------------------------------

    class func getSessionWork(session: Session) -> String {

        var s: String

        s = "\nCurrent Session:"
        s += "\nS: \(session.name)-\(session.id)"
        s += "\n    P: \(session.project.name)-\(session.project.id)"
        session.work.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
            let work = elem as Work
            s += "\n    W: \(work.task.name) \(getString(work.startTime))->\(getString(work.stopTime))"
        }

        return s
    }

}

//=======================================================================================
//=======================================================================================
//  TestData
//=======================================================================================

class TestData {

    //---------------------------------------------
    // TestData - addSessionToHome
    //---------------------------------------------

    class func addSessionToHome(managedObjectContext: NSManagedObjectContext) {
        var project: Project
        var session: Session
        var taskList: [Task]

        if let projects = Project.findInMOC(managedObjectContext, name: "Home") {
            if projects.count > 0 {
                project = projects[0]
            } else {
                project = Project.createInMOC(managedObjectContext, name: "Home")
            }
        } else {
            return
        }

        session = Session.createInMOC(managedObjectContext, name: "Home \(getString(NSDate()))")
        session.project = project

        let s = project.sessions.mutableCopy() as NSMutableSet
        s.addObject(session)
        project.sessions = s

        // Personal
        taskList = [
            Task.createInMOC(managedObjectContext, name: "I F2F"),
            Task.createInMOC(managedObjectContext, name: "I Eva"),
            Task.createInMOC(managedObjectContext, name: "I Chat"),

            Task.createInMOC(managedObjectContext, name: "I Email"),
            Task.createInMOC(managedObjectContext, name: "---"),
            Task.createInMOC(managedObjectContext, name: "I Blixt"),

            Task.createInMOC(managedObjectContext, name: "P OF"),
            Task.createInMOC(managedObjectContext, name: "---"),
            Task.createInMOC(managedObjectContext, name: "P Lista"),

            Task.createInMOC(managedObjectContext, name: "P Hushåll"),
            Task.createInMOC(managedObjectContext, name: "P Eva"),
            Task.createInMOC(managedObjectContext, name: "P Other"),

            Task.createInMOC(managedObjectContext, name: "N Waste"),
            Task.createInMOC(managedObjectContext, name: "---"),
            Task.createInMOC(managedObjectContext, name: "N Not home"),

            Task.createInMOC(managedObjectContext, name: "N Connect"),
            Task.createInMOC(managedObjectContext, name: "N Down"),
            Task.createInMOC(managedObjectContext, name: "N Time-in"),

            Task.createInMOC(managedObjectContext, name: "N Physical"),
            Task.createInMOC(managedObjectContext, name: "N Coffe/WC"),
            Task.createInMOC(managedObjectContext, name: "N Other"),
        ]

        session.tasks = NSOrderedSet(array: taskList)
    }

    //---------------------------------------------
    // TestData - addSessionToWork
    //---------------------------------------------

    class func addSessionToWork(managedObjectContext: NSManagedObjectContext) {

        var project: Project
        var session: Session
        var taskList: [Task]


        let projects = Project.findInMOC(managedObjectContext, name: "Work")

        if let projects = Project.findInMOC(managedObjectContext, name: "Work") {
            if projects.count > 0 {
                project = projects[0]
            } else {
                project = Project.createInMOC(managedObjectContext, name: "Work")
            }
        } else {
            return
        }

        session = Session.createInMOC(managedObjectContext, name: "Work \(getString(NSDate()))")
        session.project = project

        let s = project.sessions.mutableCopy() as NSMutableSet
        s.addObject(session)
        project.sessions = s
        
        // Work
        taskList = [
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
        
        session.tasks = NSOrderedSet(array: taskList)
    }
    
    //---------------------------------------------
    // TestData - addSessionToDaytime
    //---------------------------------------------

    class func addSessionToDaytime(managedObjectContext: NSManagedObjectContext) {
        var project: Project
        var session: Session
        var taskList: [Task]
        
        if let projects = Project.findInMOC(managedObjectContext, name: "Daytime") {
            if projects.count > 0 {
                project = projects[0]
            } else {
                project = Project.createInMOC(managedObjectContext, name: "Daytime")
            }
        } else {
            return
        }
        
        session = Session.createInMOC(managedObjectContext, name: "Daytime \(getString(NSDate()))")
        session.project = project
        
        let s = project.sessions.mutableCopy() as NSMutableSet
        s.addObject(session)
        project.sessions = s
        
        // Personal
        taskList = [
            Task.createInMOC(managedObjectContext, name: "Sleep"),
            Task.createInMOC(managedObjectContext, name: "Sleep in-out"),
            Task.createInMOC(managedObjectContext, name: "---"),
            
            Task.createInMOC(managedObjectContext, name: "Home"),
            Task.createInMOC(managedObjectContext, name: "Home in-out"),
            Task.createInMOC(managedObjectContext, name: "Home outside"),
            
            Task.createInMOC(managedObjectContext, name: "Work"),
            Task.createInMOC(managedObjectContext, name: "---"),
            Task.createInMOC(managedObjectContext, name: "Work outside"),
                
            Task.createInMOC(managedObjectContext, name: "Car morning"),
            Task.createInMOC(managedObjectContext, name: "T morning"),
            Task.createInMOC(managedObjectContext, name: "P morning"),

            Task.createInMOC(managedObjectContext, name: "Car evening"),
            Task.createInMOC(managedObjectContext, name: "T evening"),
            Task.createInMOC(managedObjectContext, name: "P evening"),

            Task.createInMOC(managedObjectContext, name: "Lunch"),
            Task.createInMOC(managedObjectContext, name: "Errand"),
            Task.createInMOC(managedObjectContext, name: "F&S"),

            Task.createInMOC(managedObjectContext, name: "1"),
            Task.createInMOC(managedObjectContext, name: "2"),
            Task.createInMOC(managedObjectContext, name: "3"),
        ]
        
        session.tasks = NSOrderedSet(array: taskList)
    }


}

