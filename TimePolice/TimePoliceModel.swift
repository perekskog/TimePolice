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

/*  TODO in this file

Session.delete*
Session.insert*
    Must update relations to session and tasks.

TestData
    Update according to relation maintaining methods
*/


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
        /*1.2OK*/
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Project", inManagedObjectContext: moc) as! Project

        let date = NSDate()
        let dateAndTime = NSDateFormatter.localizedStringFromDate(date,
                    dateStyle: NSDateFormatterStyle.ShortStyle,
                    timeStyle: NSDateFormatterStyle.MediumStyle)
        newItem.id = "[Project] \(dateAndTime) - \(date.timeIntervalSince1970)"
        newItem.name = name

        return newItem
    }

    //---------------------------------------------
    // Project - addSession
    //---------------------------------------------

    func addSession(session: Session) {
        let s = self.sessions.mutableCopy() as! NSMutableSet
        s.addObject(session)
        self.sessions = s
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

    class func createInMOC(moc: NSManagedObjectContext, name: String, project: Project) -> Session {
        /*1.2OK*/
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Session", inManagedObjectContext: moc) as! Session

        let date = NSDate()
        let dateAndTime = NSDateFormatter.localizedStringFromDate(date,
                    dateStyle: NSDateFormatterStyle.ShortStyle,
                    timeStyle: NSDateFormatterStyle.MediumStyle)
        newItem.id = "[Session] \(dateAndTime) - \(date.timeIntervalSince1970)"
        newItem.name = name

        // Maintain relations
        project.addSession(newItem)

        return newItem
    }

    //---------------------------------------------
    // Session - addWork
    //---------------------------------------------

    func addWork(work: Work) {
        let sw = self.work.mutableCopy() as! NSMutableOrderedSet
        sw.addObject(work)
        self.work = sw
    }

    //---------------------------------------------
    // Session - addTask
    //---------------------------------------------

    func addTask(task: Task) {
        let st = self.tasks.mutableCopy() as! NSMutableOrderedSet
        st.addObject(task)
        self.tasks = st
    }


    //---------------------------------------------
    // Session - addTasks
    //---------------------------------------------

    func addTasks(task: [Task]) {
        for task in tasks {
            addTask(task)
        }
    }



    //---------------------------------------------
    // Session - findInMOC
    //---------------------------------------------

    class func findInMOC(moc: NSManagedObjectContext, name: String) -> [Session]? {

        let fetchRequest = NSFetchRequest(entityName: "Session")
        let predicate = NSPredicate(format: "name == %@", name) 
        fetchRequest.predicate = predicate

        let fetchResults = moc.executeFetchRequest(fetchRequest, error: nil) as? [Session]

        return fetchResults
    }

    
    //---------------------------------------------
    // Session - getSessionSummary
    //---------------------------------------------

    func getSessionSummary(moc: NSManagedObjectContext) -> [Task: (Int, NSTimeInterval)] {
        var sessionSummary: [Task: (Int, NSTimeInterval)] = [:]

        self.work.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
            /*1.2OK*/
            let work = elem as! Work
            // For all items but the last one, if it is ongoing
            if idx != self.work.count-1 || work.isStopped() {
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
    // Session - replaceLastWork
    //---------------------------------------------


// Should not be needed, update the current item instead.

/*
    func replaceLastWork(work: Work) {
        let sw = self.work.mutableCopy() as! NSMutableOrderedSet
        sw.replaceObjectAtIndex(sw.count-1, withObject: work)
        self.work = sw
        work.session = self
    }
*/

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
    tx = some specific point in time
*/




    //---------------------------------------------
    // Session - setStartTime
    //---------------------------------------------

/*
             workToModify
    c1      |------------>
         t1       t2          0
    
             workToModify
    c2      |------------| ***
         t1       t2     |

                 previousWork       workToModify
    c11     *** |------------| ... |------------?
                |    t1        t2        t3           0

                 previousWork       workToModify
    c12     *** |------------| ... |------------| ***
                |    t1        t2        t3     |

Future extensions

- t3/t4 depends on other changes (t3/t4 means that workToModify will become ongoing at some future point in time)

             workToModify
            |------------?
         t1       t2        0   t3
    
                 previousWork       workToModify
            *** |------------| ... |------------?
                     t1        t2        t3         0   t4

*/

    func setStartTime(moc: NSManagedObjectContext, workIndex: Int, desiredStartTime: NSDate) {
        if workIndex < 0 || workIndex >= work.count  {
            // Index out of bounds
            return
        }

        var targetTime = desiredStartTime
        /*1.2OK*/
        let workToModify = work[workIndex] as! Work

        // Never change starttime into the future
        let now = NSDate()
        if targetTime.compare(now) == .OrderedDescending {
            // c1, c11
            targetTime = now
        }

        // Don't set starttime passed a stopped workToModify
        if workToModify.isStopped() && targetTime.compare(workToModify.stopTime) == .OrderedDescending {
            // c2, c12
            targetTime = workToModify.stopTime
        }

        if workIndex == 0 {

            // c1, c2
            // Prepare modification of workToModify
            // ...Everything has already been taken care of

        } else {

            // c11, c12
            // Prepare modification of workToModify, also modify previousWork

            // Not the first item => There is a previous item
            /*1.2OK*/
            let previousWork = work[workIndex-1] as! Work

            // Don't set starttime earlier than start of previous work
            if targetTime.compare(previousWork.startTime) == .OrderedAscending {
                targetTime = previousWork.startTime
            }

            if targetTime.compare(previousWork.stopTime) == .OrderedAscending {
                // c11/c12: t1
                // workToModify will overlap with previousWork
                previousWork.setStoppedAt(targetTime)
            }
        }

        // Do the modification of workToModify
        workToModify.setStartedAt(targetTime)

        TimePoliceModelUtils.save(moc)
    }

    //---------------------------------------------
    // Session - setStopTime
    //---------------------------------------------

/*
                 workToModify
    c1      *** |------------?
                |     t1         0
    
                 workToModify       nextWork
    c11     *** |------------| ... |-------->
                |     t1        t2     t3        0

                 workToModify       nextWork
    c12     *** |------------| ... |--------| ***
                |     t1        t2     t3   |

Future extensions

- t3/t4 depend on other chnages (t3/t4 = workToModify will be stopped in the future)

                 workToModify
            *** |------------?
                      t2         0   t3
*/


    func setStopTime(moc: NSManagedObjectContext, workIndex: Int, desiredStopTime: NSDate) {
        if workIndex < 0 || workIndex >= work.count  {
            // Index out of bounds
            return
        }

        var targetTime = desiredStopTime
        /*1.2OK*/
        let workToModify = work[workIndex] as! Work

        // Never change stoptime into the future
        let now = NSDate()
        if targetTime.compare(now) == .OrderedDescending {
            // c1, c11
            targetTime = now
        }

        // Never set stoptime before start of workToModify
        if targetTime.compare(workToModify.startTime) == .OrderedAscending {
            targetTime = workToModify.startTime
        }

        if workIndex == work.count-1 {

            // c1
            // Prepare modification of workToModify
            // ...Everything has already been taken care of


        } else {
            // c11, c12
            // Prepare modification of workToModify, also modify previousWork

            // Not the last item => There is a next item
            /*1.2OK*/
            let nextWork = work[workIndex+1] as! Work

            if targetTime.compare(nextWork.startTime) == .OrderedDescending {
                // Need to adjust next work

                if !nextWork.isOngoing() && targetTime.compare(nextWork.stopTime) == .OrderedDescending {
                    // c12
                    targetTime = nextWork.stopTime
                }

                nextWork.setStartedAt(targetTime)
            }
        }

        // Do the modification of workToModify
        workToModify.setStoppedAt(targetTime)

        TimePoliceModelUtils.save(moc)
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
    func deletePreviousWorkAndAlignStart(moc: NSManagedObjectContext, workIndex: Int) {
        if workIndex < 0 || workIndex >= work.count  {
            // Index out of bounds
            return
        }

        if workIndex == 0 {
            // No previous item
            return
        }

        /*1.2OK*/
        let workToModify = work[workIndex] as! Work
        /*1.2OK*/
        let previousWork = work[workIndex-1] as! Work
        let startTime = previousWork.startTime

        moc.deleteObject(previousWork)
        workToModify.setStartedAt(startTime)

        TimePoliceModelUtils.save(moc)
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
    func deleteNextWorkAndAlignStop(moc: NSManagedObjectContext, workIndex: Int) {
        if workIndex < 0 || workIndex >= work.count  {
            // Index out of bounds
            return
        }

        if workIndex == work.count-1 {
            // No next work
            return
        }

        /*1.2OK*/
        let workToModify = work[workIndex] as! Work
        /*1.2OK*/
        let nextWork = work[workIndex+1] as! Work

        if nextWork.isOngoing() {
            workToModify.setAsOngoing()
        } else {
            workToModify.setStoppedAt(nextWork.stopTime)
        }

        moc.deleteObject(nextWork)

        TimePoliceModelUtils.save(moc)        
    }





    //---------------------------------------------
    // Session - deleteWork
    //---------------------------------------------

/*
    GUI operation: "swipeLR"

             workToModify
    pc1 *** |------------? ***                       ==>  ***  (removed)  ***
*/

    func deleteWork(moc: NSManagedObjectContext, workIndex: Int) {
        if workIndex < 0 || workIndex >= work.count  {
            // Index out of bounds
            return
        }

        /*1.2OK*/
        let workToModify = work[workIndex] as! Work
        moc.deleteObject(workToModify)

        TimePoliceModelUtils.save(moc)        
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

    class func createInMOC(moc: NSManagedObjectContext, name: String, session: Session) -> Task {
        /*1.2OK*/
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Task", inManagedObjectContext: moc) as! Task

        let date = NSDate()
        let dateAndTime = NSDateFormatter.localizedStringFromDate(date,
                    dateStyle: NSDateFormatterStyle.ShortStyle,
                    timeStyle: NSDateFormatterStyle.MediumStyle)
        newItem.id = "[Task] \(dateAndTime) - \(date.timeIntervalSince1970)"
        newItem.name = name

        // Maintain relations
        session.addTask(newItem)

        return newItem
    }
    
    //---------------------------------------------
    // Task - addWork
    //---------------------------------------------
    
    func addWork(work: Work) {
        let sw = work.mutableCopy() as! NSMutableOrderedSet
        sw.addObject(work)
        self.work = sw
    }
    
    //---------------------------------------------
    // Task - addSession
    //---------------------------------------------
    
    func addSession(session: Session) {
        let ss = self.sessions.mutableCopy() as! NSMutableOrderedSet
        ss.addObject(session)
        self.work = ss
    }

}


//=======================================================================================
//=======================================================================================
//  Work
//=======================================================================================

/*
    create -> [Ongoing] <- setAsOngoing / setAsFinished(time) -> [Finished]
*/

class Work: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var name: String
    /* Readonly attribute */
    @NSManaged var startTime: NSDate
    /* Readonly attribute. Valid if isOngoing retirns true. */
    @NSManaged var stopTime: NSDate
    @NSManaged var session: Session
    @NSManaged var task: Task

    //---------------------------------------------
    // Work - createInMOC
    //---------------------------------------------

    class func createInMOC(moc: NSManagedObjectContext, name: String, session: Session, task: Task) -> Work {
        /*1.2OK*/
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Work", inManagedObjectContext: moc) as! Work

        let date = NSDate()
        let dateAndTime = NSDateFormatter.localizedStringFromDate(date,
                    dateStyle: NSDateFormatterStyle.ShortStyle,
                    timeStyle: NSDateFormatterStyle.MediumStyle)
        newItem.id = "[Work] \(dateAndTime) - \(date.timeIntervalSince1970)"
        newItem.name = name

        let now = NSDate()
        newItem.startTime = now
        newItem.stopTime = now

        // Maintain relations
        newItem.session = session
        session.addWork(newItem)
        newItem.task = task
        task.addWork(newItem)

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

    func isStopped() -> Bool {
        return !isOngoing()
    }

    func setStartedAt(time: NSDate) {
        if isStopped() && time.compare(self.startTime) == .OrderedDescending {
            // Don't set a stopped item's starttime > stoptime
            return
        }
        if isOngoing() {
            // Keep work as ongoing if it already is ongoing
            self.stopTime = time
        }
        self.startTime = time
    }

    func setStoppedAt(time: NSDate) {
        if time.compare(self.startTime) == .OrderedAscending {
            // Don't set an item's stoptime < starttime
            return
        }
        self.stopTime = time            
    }

    func setAsOngoing() {
        self.stopTime = self.startTime
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
                    let s = session as! Session
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
                    /*1.2OK*/
                    let work = elem as! Work
                    println("W: \(work.task.name) \(work.startTime)->\(work.stopTime)")
                }
                session.tasks.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
                    /*1.2OK*/
                    let task = elem as! Task
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
            /*1.2OK*/
            let work = elem as! Work
            let timeForWork = work.stopTime.timeIntervalSinceDate(work.startTime)
            s += "\n    W: \(work.task.name) \(getString(work.startTime))->\(getStringNoDate(work.stopTime)) = \(getString(timeForWork))"
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
    // TestData - addSession
    //---------------------------------------------

    class func addSession(moc: NSManagedObjectContext, projectName: String, templateName: String, templateTasks: [String], sessionName: String) {
        var project: Project
        var session: Session
        var taskList: [Task] = []

        if let projects = Project.findInMOC(moc, name: projectName) {
            if projects.count > 0 {
                project = projects[0]
            } else {
                project = Project.createInMOC(moc, name: projectName)
            }
        } else {
            return
        }

        if let sessions = Session.findInMOC(moc, name: templateName) {
            if sessions.count > 0 {
                let sessionTemplate = sessions[0] as Session
                taskList = sessionTemplate.tasks.array as! [Task]
            } else {
                let sessionTemplate = Session.createInMOC(moc, name: templateName, project: project)
                for taskName in templateTasks {
                    let task = Task.createInMOC(moc, name: taskName, session: sessionTemplate)
                    taskList.append(task)
                }
                taskList = sessionTemplate.tasks
            }
        }

        session = Session.createInMOC(moc, name: "\(sessionName) \(getString(NSDate()))", project: project)

        session.addTasks(taskList)
    }

    //---------------------------------------------
    // TestData - addSessionToHome
    //---------------------------------------------

    class func addSessionToHome(moc: NSManagedObjectContext) {

        let taskList =  [
            "I F2F", "I Eva", "I Chat",

            "I Email", "---", "I Blixt",

            "P OF", "---", "P Lista",

            "P Hushåll", "P Eva", "P Other",

            "N Waste", "---", "N Not home",

            "N Connect", "N Down", "N Time-in",

            "N Physical", "N Coffe/WC", "N Other"
        ]

        addSession(moc, projectName: "Home", templateName: "Template - Home", templateTasks: taskList, sessionName: "Home")
    }

    //---------------------------------------------
    // TestData - addSessionToWork
    //---------------------------------------------

    class func addSessionToWork(moc: NSManagedObjectContext) {

        let taskList = [
            "I F2F", "---", "I Lync",
            
            "I Email", "I Ticket", "I Blixt",
            
            "P OF", "P Task", "P Ticket",
            
            "P US", "P Meeting", "P Other",
            
            "N Waste", "---", "N Not work",
            
            "N Connect", "N Down", "N Time-in",
            
            "N Physical", "N Coffe/WC", "N Other"
        ]
        
        addSession(moc, projectName: "Work", templateName: "Template - Work", templateTasks: taskList, sessionName: "Work")
    }
    
    //---------------------------------------------
    // TestData - addSessionToDaytime
    //---------------------------------------------

    class func addSessionToDaytime(moc: NSManagedObjectContext) {

        let taskList = [
            "Sleep", "Sleep in-out", "---",
            
            "Home", "Home in-out", "Home outside",
            
            "Work", "---", "Work outside",
                
            "Car morning", "T morning", "P morning",

            "Car evening", "T evening", "P evening",

            "Lunch", "Errand", "F&S",

            "1", "2", "3"
        ]
        
        addSession(moc, projectName: "Daytime", templateName: "Template - Daytime", templateTasks: taskList, sessionName: "Daytime")
    }


}

