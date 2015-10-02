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

Session.deleteWork
    Ej implementerad, behövs inte för att ta bort en session.

- Missing: AppLog

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
    // Project - delete
    //---------------------------------------------

    class func deleteInMOC(moc: NSManagedObjectContext, project: Project) {
    
        for session in project.sessions {
            Session.deleteInMOC(moc, session: session as! Session)
        }
        moc.deleteObject(project)
    }


    //---------------------------------------------
    // Project - addSession (internal use only)
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

        do {
            let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Project]

            return fetchResults
        } catch {
            return nil
        }
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
    // Session - delete
    //---------------------------------------------

    class func deleteInMOC(moc: NSManagedObjectContext, session: Session) {
    
        for work in session.work {
            Work.deleteInMOC(moc, work: work as! Work)
        }
        moc.deleteObject(session)
    }


    //---------------------------------------------
    // Session - addWork (internal use only)
    //---------------------------------------------

    func addWork(work: Work) {
        let sw = self.work.mutableCopy() as! NSMutableOrderedSet
        sw.addObject(work)
        self.work = sw
    }


    //---------------------------------------------
    // Session - addWork (internal use only)
    //---------------------------------------------

    func insertWorkBefore(work: Work, index: Int) {
        let sw = self.work.mutableCopy() as! NSMutableOrderedSet
        sw.insertObject(work, atIndex: index)
        self.work = sw
    }


    //---------------------------------------------
    // Session - addWork (internal use only)
    //---------------------------------------------

    func insertWorkAfter(work: Work, index: Int) {
        let sw = self.work.mutableCopy() as! NSMutableOrderedSet
        sw.insertObject(work, atIndex: index+1)
        self.work = sw
    }


    //---------------------------------------------
    // Session - addTask (internal use only)
    //---------------------------------------------

    func addTask(task: Task) {
        let st = self.tasks.mutableCopy() as! NSMutableOrderedSet
        st.addObject(task)
        self.tasks = st
    }


    //---------------------------------------------
    // Session - addTasks (internal use only)
    //---------------------------------------------

    func addTasks(taskList: [Task]) {
        for task in taskList {
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

        do {
            let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Session]
            return fetchResults
        } catch {
            return nil
        }
    }

    
    //---------------------------------------------
    // Session - getSessionTaskSummary
    //---------------------------------------------

    func getSessionTaskSummary(moc: NSManagedObjectContext) -> [Task: (Int, NSTimeInterval)] {
        var sessionTaskSummary: [Task: (Int, NSTimeInterval)] = [:]

        self.work.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in

            let work = elem as! Work
            // For all items but the last one, if it is ongoing
            if idx != self.work.count-1 || work.isStopped() {
                let task = work.task
                var taskSummary: (Int, NSTimeInterval) = (0, 0)
                if let t = sessionTaskSummary[task] {
                    taskSummary = t
                }
                var (activations, totalTime) = taskSummary
                activations++
                totalTime += work.stopTime.timeIntervalSinceDate(work.startTime)
                sessionTaskSummary[task] = (activations, totalTime)
            }
        }

        return sessionTaskSummary
    }

    //---------------------------------------------
    // Session - getSessionSummary
    //---------------------------------------------

    func getSessionSummary(moc: NSManagedObjectContext) -> (Int, NSTimeInterval) {
        var sessionSummary: (Int, NSTimeInterval) = (0,0)

        self.work.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in

            let work = elem as! Work
            // For all items but the last one, if it is ongoing
            if idx != self.work.count-1 || work.isStopped() {
                var (activations, totalTime) = sessionSummary
                activations++
                totalTime += work.stopTime.timeIntervalSinceDate(work.startTime)
                sessionSummary = (activations, totalTime)
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
    // Session - getWork
    //---------------------------------------------

    func getWork(index: Int) -> Work? {
        if index >= 0 && work.count > index {
            return work[index] as? Work
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

        let workToModify = work[workIndex] as! Work
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

        let workToModify = work[workIndex] as! Work
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

        let workToModify = work[workIndex] as! Work
        Work.deleteInMOC(moc, work: workToModify)
        TimePoliceModelUtils.save(moc)        
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
    // Task - delete
    //---------------------------------------------

    class func deleteInMOC(moc: NSManagedObjectContext, task: Task) {
    
        for work in task.work {
            Work.deleteInMOC(moc, work: work as! Work)
        }
        moc.deleteObject(task)
    }

    
    //---------------------------------------------
    // Task - addWork
    //---------------------------------------------
    
    func addWork(work: Work) {
        let sw = self.work.mutableCopy() as! NSMutableOrderedSet
        sw.addObject(work)
        self.work = sw
    }
    
    //---------------------------------------------
    // Task - addSession
    //---------------------------------------------
    
    func addSession(session: Session) {
        let ss = self.sessions.mutableCopy() as! NSMutableSet
        ss.addObject(session)
        self.sessions = ss
    }

    //---------------------------------------------
    // Task - deleteSession
    //---------------------------------------------
    
    func deleteSession(session: Session) {
        let ss = self.sessions.mutableCopy() as! NSMutableSet
        ss.removeObject(session)
        self.sessions = ss
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

    let stoptimeOngoing = NSDate(timeIntervalSince1970: 0)

    //---------------------------------------------
    // Work - createInMOC
    //---------------------------------------------

    class func createInMOC(moc: NSManagedObjectContext, name: String, session: Session, task: Task) -> Work {
        
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Work", inManagedObjectContext: moc) as! Work

        let date = NSDate()
        let dateAndTime = NSDateFormatter.localizedStringFromDate(date,
                    dateStyle: NSDateFormatterStyle.ShortStyle,
                    timeStyle: NSDateFormatterStyle.MediumStyle)
        newItem.id = "[Work] \(dateAndTime) - \(date.timeIntervalSince1970)"
        newItem.name = name

        let now = NSDate()
        newItem.startTime = now
        newItem.stopTime = NSDate(timeIntervalSince1970: 0) // stoptimeOngoing

        // Maintain relations
        newItem.task = task
        newItem.session = session

        task.addWork(newItem)
        session.addWork(newItem)

        return newItem
    }
    
    class func createInMOCBeforeIndex(moc: NSManagedObjectContext, session: Session, index: Int) -> Work? {
        
        if let templateItem = session.getWork(index) {
            let newItem = NSEntityDescription.insertNewObjectForEntityForName("Work", inManagedObjectContext: moc) as! Work

            let date = NSDate()
            let dateAndTime = NSDateFormatter.localizedStringFromDate(date,
                    dateStyle: NSDateFormatterStyle.ShortStyle,
                    timeStyle: NSDateFormatterStyle.MediumStyle)
            newItem.id = "[Work] \(dateAndTime) - \(date.timeIntervalSince1970)"

            newItem.name = templateItem.name
            newItem.startTime = templateItem.startTime
            newItem.stopTime = templateItem.startTime

            templateItem.task.addWork(newItem)
            templateItem.session.insertWorkBefore(newItem, index: index)

            // Maintain relations
            newItem.task = templateItem.task
            newItem.session = templateItem.session

            return newItem
        }

        return nil
    }

    class func createInMOCAfterIndex(moc: NSManagedObjectContext, session: Session, index: Int) -> Work? {
        
        if let templateItem = session.getWork(index) {
            let newItem = NSEntityDescription.insertNewObjectForEntityForName("Work", inManagedObjectContext: moc) as! Work

            let date = NSDate()
            let dateAndTime = NSDateFormatter.localizedStringFromDate(date,
                    dateStyle: NSDateFormatterStyle.ShortStyle,
                    timeStyle: NSDateFormatterStyle.MediumStyle)
            newItem.id = "[Work] \(dateAndTime) - \(date.timeIntervalSince1970)"

            newItem.name = templateItem.name
            newItem.startTime = templateItem.stopTime
            newItem.stopTime = templateItem.stopTime

            templateItem.task.addWork(newItem)
            templateItem.session.insertWorkAfter(newItem, index: index)

            // Maintain relations
            newItem.task = templateItem.task
            newItem.session = templateItem.session

            return newItem
        }

        return nil
    }


    //---------------------------------------------
    // Work - delete
    //---------------------------------------------

    class func deleteInMOC(moc: NSManagedObjectContext, work: Work) {
        moc.deleteObject(work)
    }


    //---------------------------------------------
    // Work - isOngoing
    //---------------------------------------------

    func isOngoing() -> Bool {
        if stopTime == stoptimeOngoing {
            return true
        } else {
            return false
        }
    }

    func isStopped() -> Bool {
        return !isOngoing()
    }

    func setStartedAt(time: NSDate) {
        if isStopped() && time.compare(self.stopTime) == .OrderedDescending {
            // Don't set a stopped item's starttime > stoptime
            return
        }
        if isOngoing() {
            // Keep work as ongoing if it already is ongoing
            self.stopTime = stoptimeOngoing
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
        self.stopTime = stoptimeOngoing
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
        do {
            try moc.save()
            print("Save: ok")
        } catch {
            print("Save: error")
            // Swift 2: Where to get the error?
        }

    }

    //---------------------------------------------
    // TimePoliceModelUtils - clearAllData
    //---------------------------------------------

    class func clearAllData(moc: NSManagedObjectContext) {
        var fetchRequest: NSFetchRequest

        do {
            // Delete all work
            fetchRequest = NSFetchRequest(entityName: "Work")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Work] {
                for work in fetchResults {
                    moc.deleteObject(work)
                }
            }
            // Delete all tasks
            fetchRequest = NSFetchRequest(entityName: "Task")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Task] {
                for task in fetchResults {
                    moc.deleteObject(task)
                }
            }
            // Delete all sessions
            fetchRequest = NSFetchRequest(entityName: "Session")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Session] {
                for session in fetchResults {
                    moc.deleteObject(session)
                }
            }
            
            // Delete all projects
            fetchRequest = NSFetchRequest(entityName: "Project")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Project] {
                for project in fetchResults {
                    moc.deleteObject(project)
                }
            }

        } catch {
            
        }


    }

    //---------------------------------------------
    // TimePoliceModelUtils - dumpAllData
    //---------------------------------------------

    class func dumpAllData(moc: NSManagedObjectContext) -> String {
        var fetchRequest: NSFetchRequest
        var s: String
        
        do {
            
            s = ("---------------------------\n")
            s += ("----------Project----------\n\n")
            fetchRequest = NSFetchRequest(entityName: "Project")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Project] {
                s += "[Project container size=\(fetchResults.count)]\n"
                for project in fetchResults {
                    s += ("P: \(project.name)-\(project.id)\n")
                    s += "    [Session container size=\(project.sessions.count)]\n"
                    for session in project.sessions {
                        s += ("    S: \(session.name)-\(session.id)\n")
                    }
                }
            }
            
            s += "\n"
            s += ("---------------------------\n")
            s += ("----------Session----------\n\n")
            fetchRequest = NSFetchRequest(entityName: "Session")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Session] {
                s += "[Session container size=\(fetchResults.count)]\n"
                for session in fetchResults {
                    s += ("S: \(session.name)-\(session.id)\n")
                    s += ("    P: \(session.project.name)-\(session.project.id)\n")
                    s += "    [Work container size=\(session.work.count)]\n"
                    session.work.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
                        let work = elem as! Work
                        if work.isStopped() {
                            let timeForWork = work.stopTime.timeIntervalSinceDate(work.startTime)
                            s += "    W: \(work.task.name) \(getString(work.startTime))->\(getStringNoDate(work.stopTime)) = \(getString(timeForWork))\n"
                        } else {
                            s += "    W: \(work.task.name) \(getString(work.startTime))->(ongoing) = ------\n"
                        }
                    }
                    s += "    [Task container size=\(session.tasks.count)]\n"
                    session.tasks.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
                        let task = elem as! Task
                        s += ("    T: \(task.name)\n")
                    }
                }
            }
            
            s += "\n"
            s += ("---------------------------\n")
            s += ("----------Session 2--------\n\n")
            fetchRequest = NSFetchRequest(entityName: "Session")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Session] {
                s += "[Session container size=\(fetchResults.count)]\n"
                for session in fetchResults {
                    s += ("S: \(session.name)-\(session.id)\n")
                    s += ("    P: \(session.project.name)-\(session.project.id)\n")
                    s += "    [Work container size=\(session.work.count)]\n"
                    let n = session.work.count
                    if n > 0 {
                        for i in 0...n-1 {
                            let work = session.work.objectAtIndex(i)
                            if work.isStopped() {
                                let timeForWork = work.stopTime.timeIntervalSinceDate(work.startTime)
                                s += "    W: \(work.task.name) \(getString(work.startTime))->\(getStringNoDate(work.stopTime)) = \(getString(timeForWork))\n"
                            } else {
                                s += "    W: \(work.task.name) \(getString(work.startTime))->(ongoing) = ------\n"
                            }
                        }
                    }
                    s += "    [Task container size=\(session.tasks.count)]\n"
                    session.tasks.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
                        let task = elem as! Task
                        s += ("    T: \(task.name)\n")
                    }
                }
            }
            
            s += "\n"
            s += ("------------------------\n")
            s += ("----------Work----------\n\n")
            fetchRequest = NSFetchRequest(entityName: "Work")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Work] {
                s += "[Work container size=\(fetchResults.count)]\n"
                for work in fetchResults {
                    if work.isStopped() {
                        let timeForWork = work.stopTime.timeIntervalSinceDate(work.startTime)
                        s += "W: \(work.task.name) \(getString(work.startTime))->\(getStringNoDate(work.stopTime)) = \(getString(timeForWork))\n"
                    } else {
                        s += "W: \(work.task.name) \(getString(work.startTime))->(ongoing) = ------\n"
                    }
                    s += ("    S: \(work.session.name)\n")
                    s += ("    T: \(work.task.name)\n")
                }
            }
            
            s += "\n"
            s += ("------------------------\n")
            s += ("----------Task----------\n\n")
            fetchRequest = NSFetchRequest(entityName: "Task")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Task] {
                s += "[Task container size=\(fetchResults.count)]\n"
                for task in fetchResults {
                    s += ("T: \(task.name)\n")
                    s += "    [Session container size=\(task.sessions.count)]\n"
                    for session in task.sessions {
                        s += ("    S: \(session.name)\n")
                    }
                    s += "    [Work container size=\(task.work.count)]\n"
                    task.work.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
                        let work = elem as! Work
                        if work.isStopped() {
                            let timeForWork = work.stopTime.timeIntervalSinceDate(work.startTime)
                            s += "    W: \(work.task.name) \(getString(work.startTime))->\(getStringNoDate(work.stopTime)) = \(getString(timeForWork))\n"
                        } else {
                            s += "    W: \(work.task.name) \(getString(work.startTime))->(ongoing) = ------\n"                                
                        }
                    }
                }
            }
        
        } catch {

            
        }

        return s
    }

    //---------------------------------------------
    // TimePoliceModelUtils - getSessionWork
    //---------------------------------------------

    class func getSessionWork(session: Session) -> String {

        var s: String

        s = "Current Session:\n"
        s += "S: \(session.name)-\(session.id)\n"
        s += "    P: \(session.project.name)-\(session.project.id)\n"
        session.work.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
            let work = elem as! Work
            if work.isStopped() {
                let timeForWork = work.stopTime.timeIntervalSinceDate(work.startTime)
                s += "    W: \(work.task.name) \(getString(work.startTime))->\(getStringNoDate(work.stopTime)) = \(getString(timeForWork))\n"                
            } else {
                s += "    W: \(work.task.name) \(getString(work.startTime))->(ongoing) = ------\n"                                
            }
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

    class func addSession(moc: NSManagedObjectContext, projectName: String, sessionTemplateName: String, sessionTemplateTasks: [String], sessionName: String) {
        var project: Project
        var projectTemplate: Project
        var session: Session
        var taskList: [Task] = []

        if let projects = Project.findInMOC(moc, name: "Templates") {
            if projects.count > 0 {
                projectTemplate = projects[0]
            } else {
                projectTemplate = Project.createInMOC(moc, name: "Templates")
            }
        } else {
            return
        }

        if let projects = Project.findInMOC(moc, name: projectName) {
            if projects.count > 0 {
                project = projects[0]
            } else {
                project = Project.createInMOC(moc, name: projectName)
            }
        } else {
            return
        }
        
        if let sessions = Session.findInMOC(moc, name: sessionTemplateName) {
            if sessions.count > 0 {
                let sessionTemplate = sessions[0] as Session
                taskList = sessionTemplate.tasks.array as! [Task]
            } else {
                let sessionTemplate = Session.createInMOC(moc, name: sessionTemplateName, project: projectTemplate)
                for taskName in sessionTemplateTasks {
                    let task = Task.createInMOC(moc, name: taskName, session: sessionTemplate)
                    taskList.append(task)
                }
                taskList = sessionTemplate.tasks.array as! [Task]
            }
        }

        session = Session.createInMOC(moc, name: "\(sessionName)", project: project)

        session.addTasks(taskList)
    }

    //---------------------------------------------
    // TestData - addSessionToHome
    //---------------------------------------------

    class func addSessionToPrivate(moc: NSManagedObjectContext) {
        // 24
        let taskList =  [
            "RC#color=4c4", "Dev#color=4c4", "Media#color=4c4",
            "Läsa/Titta#color=4c4", "Div hemma#color=4c4", "Div borta#color=4c4",
            "Fysiskt#color=4c4", "Time in#color=4c4", "Relationer#color=4c4",
            "Lek#color=4c4", "Down#color=4c4", "Pers. utv#color=4c4",
            
            "Person#color=44f", "Hem#color=44f", "Hus/tomt#color=44f",
            "Bil#color=44f", "Behöver div#color=44f", "",
                        
            "Oaktivitet#color=bbb", "", "",
            
            "Läsa/titta#color=b84", "", "",

            "Blockerad#color=b44", "Avbrott#color=b44", "",
            "Brand#color=b44", "Fokusskift#color=b44", ""
            
        ]

        addSession(moc, projectName: "Privat", sessionTemplateName: "Template - Privat", sessionTemplateTasks: taskList, sessionName: "Privat")
    }

    //---------------------------------------------
    // TestData - addSessionToWork
    //---------------------------------------------

    class func addSessionToWork(moc: NSManagedObjectContext) {
        // 27
        let taskList = [
            "Dev#color=4c4", "PPO#color=4c4", "Stage 7#color=4c4",

            "Fysiskt#color=4c4", "Time in#color=4c4", "Relationer#color=4c4",
            "Lek#color=4c4", "Down#color=4c4", "Pers. utv#color=4c4",
            
            "Inbox#color=44f", "Pågående#color=44f", "Städa upp#color=44f",
            "Team#color=44f", "Adm#color=44f", "Annat#color=44f",
            
            "Oaktivitet#color=bbb", "", "",

            "Läsa/titta#color=b84", "", "",

            "Blockerad#color=b44", "Avbrott#color=b44", "",
            "Brand#color=b44", "Fokusskift#color=b44", "",
        ]
        
        addSession(moc, projectName: "Jobb", sessionTemplateName: "Template - Jobb", sessionTemplateTasks: taskList, sessionName: "Jobb")
    }
    
    //---------------------------------------------
    // TestData - addSessionToDaytime
    //---------------------------------------------

    class func addSessionToDaytime(moc: NSManagedObjectContext) {
        // 21
        let taskList = [
            "Hemma", "Hemma ute", "Sova",
            
            "Jobb", "Jobb ute", "Lunch",
                
            "Bil morgon", "Bil kväll", "",
            "P morgon", "P kväll", "",
            "T morgon", "T kväll", "",
            "B morgon", "B kväll", "",

            "Ärende", "F&S", "Annat"
        ]
        
        addSession(moc, projectName: "Ett dygn", sessionTemplateName: "Template - Ett dygn", sessionTemplateTasks: taskList, sessionName: "Ett dygn")
    }

    //---------------------------------------------
    // TestData - addSessionToCost
    //---------------------------------------------
    
    class func addSessionToCost(moc: NSManagedObjectContext) {
        let taskList = [
            "Comp 16A", "Comp 16B", "", "",
            "Maint", "SM Yearly", "", "",
            
            "Alfa", "Bravo", "Charlie",
            "Delta", "Echo", "Foxtrot",
            "Golf", "Hotel", "India",
            "Juliet", "Kilo", "Lima",
            "Mike", "November", "Oscar",
            "Papa", "Quebeq", "Romeo",
            "Sierra", "Tango", "Uniform",
            "Victor", "Whiskey", "X-ray",
            "Yankee", "Zulu"
        ]
        
        addSession(moc, projectName: "Cost", sessionTemplateName: "Template - Cost", sessionTemplateTasks: taskList, sessionName: "Cost")
    }

    //---------------------------------------------
    // TestData - addSessionToTest
    //---------------------------------------------
    
    class func addSessionToTest(moc: NSManagedObjectContext) {
        // 6
        let taskList = [
            "", "Bertil#color=8f8,x=bertil", "Ceasar#color=88f,x=ceasar",
            
            "", "Tvåa#color=0f0", "Trea#color=00f"
        ]

        addSession(moc, projectName: "Test", sessionTemplateName: "Template - Test", sessionTemplateTasks: taskList, sessionName: "Test")
    }

}


