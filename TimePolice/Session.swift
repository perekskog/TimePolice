//
//  Session.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-11-02.
//  Copyright © 2015 Per Ekskog. All rights reserved.
//

import Foundation
import CoreData
import UIKit

/**
A session in project "Templates" is a template session used to create and reconfigure sessions.
A session may be reconfigured with another template with the same name but with different version.

Each session in the template project has a version, which is the template version (which may be an empty string).
Each session in a project is using one specific template with the same version attribute as the session itself.

All sessions in project "X" will have name "X". Each session is using tasks and settings from a template session with same name and version as the session itself.

- todo:
- ? Session.delete*
- ? Session.insert*
- Must update relations to session and tasks.
- ? Session.deleteTaskEntry
- Ej implementerad, behövs inte för att ta bort en session.
*/

class Session: NSManagedObject {

    //---------------------------------------------
    // Session - createInMOC
    //---------------------------------------------

    class func createInMOC(moc: NSManagedObjectContext, 
        name: String, version: String, properties: [String: String], project: Project, src: String) -> Session {
        UtilitiesApplog.logDefault("Session", logtype: .EnterExit, message: "createInMOC(name=\(name),version=\(version),props...)")

        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Session", inManagedObjectContext: moc) as! Session

        let date = NSDate()
        let deviceName = UIDevice.currentDevice().name
        newItem.id = "S:\(name)/\(date.timeIntervalSince1970)/\(deviceName)"
        newItem.name = name
        newItem.version = version
        newItem.created = date
        newItem.properties = properties
        newItem.src = src
        newItem.archived = false
        
        newItem.project = project

        // Maintain relations
        project.addSession(newItem)

        let s = UtilitiesString.dumpProperties(properties)
        UtilitiesApplog.logDefault("Session properties", logtype: .Debug, message: s)

        return newItem
    }

    //---------------------------------------------
    // Session - findInMOC
    //---------------------------------------------

    class func findInMOC(moc: NSManagedObjectContext, name: String) -> [Session]? {
        UtilitiesApplog.logDefault("Session", logtype: .EnterExit, message: "findInMOC(name=\(name))")

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
    // Session - delete
    //---------------------------------------------

    class func deleteObject(session: Session) {
        UtilitiesApplog.logDefault("Session", logtype: .EnterExit, message: "deleteObject(name=\(session.name))")
        guard let moc = session.managedObjectContext else { return }
        let taskEntries = session.taskEntries
        let tasks = session.tasks
        let project = session.project
        moc.deleteObject(session)
        UtilitiesApplog.logDefault("Session", logtype: .EnterExit, message: "Delete all taskentries")
        for taskEntry in taskEntries {
            if let te = taskEntry as? TaskEntry {
                TaskEntry.deleteObject(te)
                Task.purgeIfEmpty(te.task, exceptSession: session, exceptTaskEntry: te)
            }
        }
        UtilitiesApplog.logDefault("Session", logtype: .EnterExit, message: "Purge all orphaned tasks")
        for task in tasks {
            if let t = task as? Task {
                Task.purgeIfEmpty(t, exceptSession:session)
            }
        } 
        UtilitiesApplog.logDefault("Session", logtype: .EnterExit, message: "Purge project if orphaned")
        Project.purgeIfEmpty(project, exceptSession: session)
    }


    //---------------------------------------------
    // Session - get attributes
    //---------------------------------------------
    
    func getProperty(key: String) -> String? {
//        UtilitiesApplog.logDefault("Session", logtype: .EnterExit, message: "getProperty(key=\(key))")
        guard let p = properties as? [String: String] else {
            UtilitiesApplog.logDefault("Session", logtype: .Guard, message: "guard fail getProperty")
            return nil
        }
        return p[key]
    }

    func getDisplayName() -> String {
        var s = self.name
        if self.version != "" {
            s += ".\(self.version)"
        }
        return s
    }

    func getDisplayNameWithSuffix() -> String {
        var s = getDisplayName()

        if let e = self.getProperty(sessionExtensionAttribute) {
            s += " \(UtilitiesDate.getStringWithFormat(self.created, format: e))"
        }

        return s
    }
    
    
    //---------------------------------------------
    // Session - addTaskEntry (internal use only)
    //---------------------------------------------
    
    func addTaskEntry(taskEntry: TaskEntry) {
        UtilitiesApplog.logDefault("Session", logtype: .EnterExit, message: "addTaskEntry(taskEntry=\(taskEntry.name))")
        let sw = self.taskEntries.mutableCopy() as! NSMutableOrderedSet
        sw.addObject(taskEntry)
        self.taskEntries = sw
    }

    func insertTaskEntryBefore(taskEntry: TaskEntry, index: Int) {
        UtilitiesApplog.logDefault("Session", logtype: .EnterExit, message: "insertTaskEntryBefore(taskEntry=\(taskEntry.name), index=\(index))")
        let sw = self.taskEntries.mutableCopy() as! NSMutableOrderedSet
        sw.insertObject(taskEntry, atIndex: index)
        self.taskEntries = sw
    }

    func insertTaskEntryAfter(taskEntry: TaskEntry, index: Int) {
        UtilitiesApplog.logDefault("Session", logtype: .EnterExit, message: "insertTaskEntryAfter(taskEntry=\(taskEntry.name), index=\(index))")
        let sw = self.taskEntries.mutableCopy() as! NSMutableOrderedSet
        sw.insertObject(taskEntry, atIndex: index+1)
        self.taskEntries = sw
    }

    //---------------------------------------------
    // Session - getLastTaskEntry
    //---------------------------------------------

    func getLastTaskEntry() -> TaskEntry? {
        // UtilitiesApplog.logDefault("Session", logtype: .EnterExit, message: "getLastTaskEntry")
        if taskEntries.count >= 1 {
            return taskEntries[taskEntries.count-1] as? TaskEntry
        } else {
            return nil
        }
    }

    //---------------------------------------------
    // Session - getTaskEntry
    //---------------------------------------------

    func getTaskEntry(index: Int) -> TaskEntry? {
        UtilitiesApplog.logDefault("Session", logtype: .EnterExit, message: "getTaskEntry(index=\(index))")
        if index >= 0 && taskEntries.count > index {
            return taskEntries[index] as? TaskEntry
        } else {
            return nil
        }
    }


    //---------------------------------------------
    // Session - addTask (internal use only)
    //---------------------------------------------

    func addTask(task: Task) {
        UtilitiesApplog.logDefault("Session", logtype: .EnterExit, message: "addTask(task=\(task.name))")
        let st = self.tasks.mutableCopy() as! NSMutableOrderedSet
        st.addObject(task)
        self.tasks = st
    }

    func addTasks(taskList: [Task]) {
        UtilitiesApplog.logDefault("Session", logtype: .EnterExit, message: "addTasks(...)")
        for task in taskList {
            addTask(task)
        }
    }


    //---------------------------------------------
    // Session - deleteTasks (internal use only)
    //---------------------------------------------

    func deleteTask(task: Task) {
        UtilitiesApplog.logDefault("Session", logtype: .EnterExit, message: "deleteTask(task=\(task.name))")
        let st = self.tasks.mutableCopy() as! NSMutableOrderedSet
        st.removeObject(task)
        self.tasks = st
    }


    //---------------------------------------------
    // Session - replaceTasks (internal use only)
    //---------------------------------------------

    func replaceTasksWith(newTasks: [Task]) {
        UtilitiesApplog.logDefault("Session", logtype: .EnterExit, message: "replaceTasksWith(tasks...)")
        let oldTasks = self.tasks


        let s = NSOrderedSet(array:newTasks)
        self.tasks = s
        if let moc = self.managedObjectContext {
            TimePoliceModelUtils.save(moc)
        }

        for task in oldTasks {
            if let t = task as? Task {
                Task.purgeIfEmpty(t)
            }
        }
    }

    //---------------------------------------------
    // Session - getSessionTaskSummary
    //---------------------------------------------

    func getSessionTaskSummary(includeOngoing: Bool) -> [Task: (Int, NSTimeInterval)] {
        var sessionTaskSummary: [Task: (Int, NSTimeInterval)] = [:]

        UtilitiesApplog.logDefault("Session", logtype: .EnterExit, message: "getSessionTaskSummary")

        self.taskEntries.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in

            let taskEntry = elem as! TaskEntry
            // For all ongoing items
            if taskEntry.isStopped() || includeOngoing {
                let task = taskEntry.task
                var taskSummary: (Int, NSTimeInterval) = (0, 0)
                if let t = sessionTaskSummary[task] {
                    taskSummary = t
                }
                var (activations, totalTime) = taskSummary
                activations++
                if taskEntry.isStopped() {
                    totalTime += taskEntry.stopTime.timeIntervalSinceDate(taskEntry.startTime)
                } else {
                    totalTime += NSDate().timeIntervalSinceDate(taskEntry.startTime)
                }
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

        UtilitiesApplog.logDefault("Session", logtype: .EnterExit, message: "getSessionSummary")

        self.taskEntries.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in

            let taskEntry = elem as! TaskEntry
            // For all items but the last one, if it is ongoing
            if idx != self.taskEntries.count-1 || taskEntry.isStopped() {
                var (activations, totalTime) = sessionSummary
                activations++
                totalTime += taskEntry.stopTime.timeIntervalSinceDate(taskEntry.startTime)
                sessionSummary = (activations, totalTime)
            }
        }

        return sessionSummary
    }

    //---------------------------------------------
    // Session - archived
    //---------------------------------------------

    func setArchivedTo(archived: Bool) {
        UtilitiesApplog.logDefault("Session", logtype: .EnterExit, message: "getSessionSummary")

        self.archived = archived

        if let moc = self.managedObjectContext {
            TimePoliceModelUtils.save(moc)
        }
    }

    //---------------------------------------------
    // Session modifications - Rules to follow
    //---------------------------------------------

/*
    Rules for modification of list of taskentry in a session.

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
            taskEntryToModify
    c1      |------------>
         t1       t2          0
    
            taskEntryToModify
    c2      |------------| ***
         t1       t2     |

                previousTaskEntry  taskEntryToModify
    c11     *** |------------| ... |------------?
                |    t1        t2        t3           0

                previousTaskEntry  taskEntryToModify
    c12     *** |------------| ... |------------| ***
                |    t1        t2        t3     |

Future extensions

- t3/t4 depends on other changes (t3/t4 means that taskEntryToModify will become ongoing at some future point in time)

             taskEntryToModify
            |------------?
         t1       t2        0   t3
    
                 previousTaskEntry  taskEntryToModify
            *** |------------| ... |------------?
                     t1        t2        t3         0   t4

*/

    func setStartTime(moc: NSManagedObjectContext, taskEntryIndex: Int, desiredStartTime: NSDate) {
        UtilitiesApplog.logDefault("Session", logtype: .EnterExit, message: "setStartTime(taskEntryIndex=\(index), time=\(UtilitiesDate.getString(desiredStartTime)))")

        if taskEntryIndex < 0 || taskEntryIndex >= taskEntries.count  {
            // Index out of bounds
            return
        }

        var targetTime = desiredStartTime
        let taskEntryToModify = taskEntries[taskEntryIndex] as! TaskEntry

        // Never change starttime into the future
        let now = NSDate()
        if targetTime.compare(now) == .OrderedDescending {
            // c1, c11
            targetTime = now
        }

        // Don't set starttime passed a stopped taskEntryToModify
        if taskEntryToModify.isStopped() && targetTime.compare(taskEntryToModify.stopTime) == .OrderedDescending {
            // c2, c12
            targetTime = taskEntryToModify.stopTime
        }

        if taskEntryIndex == 0 {

            // c1, c2
            // Prepare modification of taskEntryToModify
            // ...Everything has already been taken care of

        } else {

            // c11, c12
            // Prepare modification of taskEntryToModify, also modify previousTaskEntry

            // Not the first item => There is a previous item
            let previousTaskEntry = taskEntries[taskEntryIndex-1] as! TaskEntry

            // Don't set starttime earlier than start of previous taskentry
            if targetTime.compare(previousTaskEntry.startTime) == .OrderedAscending {
                targetTime = previousTaskEntry.startTime
            }

            if targetTime.compare(previousTaskEntry.stopTime) == .OrderedAscending {
                // c11/c12: t1
                // taskEntryToModify will overlap with previousTaskEntry
                previousTaskEntry.setStoppedAt(targetTime)
            }
        }

        // Do the modification of taskEntryToModify
        taskEntryToModify.setStartedAt(targetTime)

        TimePoliceModelUtils.save(moc)
    }

    //---------------------------------------------
    // Session - setStopTime
    //---------------------------------------------

/*
                taskEntryToModify
    c1      *** |------------?
                |     t1         0
    
                taskEntryToModify  nextTaskEntry
    c11     *** |------------| ... |-------->
                |     t1        t2     t3        0

                taskEntryToModify  nextTaskEntry
    c12     *** |------------| ... |--------| ***
                |     t1        t2     t3   |

Future extensions

- t3/t4 depend on other chnages (t3/t4 = taskEntryToModify will be stopped in the future)

                taskEntryToModify
            *** |------------?
                      t2         0   t3
*/


    func setStopTime(moc: NSManagedObjectContext, taskEntryIndex: Int, desiredStopTime: NSDate) {
        UtilitiesApplog.logDefault("Session", logtype: .EnterExit, message: "setStopTime(taskEntryIndex=\(index), time=\(UtilitiesDate.getString(desiredStopTime)))")

        if taskEntryIndex < 0 || taskEntryIndex >= taskEntries.count  {
            // Index out of bounds
            return
        }

        var targetTime = desiredStopTime

        let taskEntryToModify = taskEntries[taskEntryIndex] as! TaskEntry

        // Never change stoptime into the future
        let now = NSDate()
        if targetTime.compare(now) == .OrderedDescending {
            // c1, c11
            targetTime = now
        }

        // Never set stoptime before start of taskEntryToModify
        if targetTime.compare(taskEntryToModify.startTime) == .OrderedAscending {
            targetTime = taskEntryToModify.startTime
        }

        if taskEntryIndex == taskEntries.count-1 {

            // c1
            // Prepare modification of taskEntryToModify
            // ...Everything has already been taken care of


        } else {
            // c11, c12
            // Prepare modification of taskEntryToModify, also modify previousTaskEntry

            // Not the last item => There is a next item
            let nextTaskEntry = taskEntries[taskEntryIndex+1] as! TaskEntry

            if targetTime.compare(nextTaskEntry.startTime) == .OrderedDescending {
                // Need to adjust next taskentry

                if !nextTaskEntry.isOngoing() && targetTime.compare(nextTaskEntry.stopTime) == .OrderedDescending {
                    // c12
                    targetTime = nextTaskEntry.stopTime
                }

                nextTaskEntry.setStartedAt(targetTime)
            }
        }

        // Do the modification of taskEntryToModify
        taskEntryToModify.setStoppedAt(targetTime)

        TimePoliceModelUtils.save(moc)
    }




    //---------------------------------------------
    // Session - deletePreviousTaskEntryAndAlignStart
    //---------------------------------------------

/*
    GUI operation: "swipeUp"

            taskEntryToModify
    N/A     |------------? ***


            previousTaskEntry  taskEntryToModify                 taskEntryToModify
    pc1 *** |------------| ... |------------? ***     ==>    *** |------------? ***
            1            2     3            4                    1            4
*/
    func deletePreviousTaskEntryAndAlignStart(moc: NSManagedObjectContext, taskEntryIndex: Int) {
        UtilitiesApplog.logDefault("Session", logtype: .EnterExit, message: "deletePreviousTaskEntryAndAlignStart(taskEntryIndex=\(taskEntryIndex))")

        if taskEntryIndex < 0 || taskEntryIndex >= taskEntries.count  {
            // Index out of bounds
            return
        }

        if taskEntryIndex == 0 {
            // No previous item
            return
        }

        let taskEntryToModify = taskEntries[taskEntryIndex] as! TaskEntry
        let previousTaskEntry = taskEntries[taskEntryIndex-1] as! TaskEntry
        let startTime = previousTaskEntry.startTime

        TaskEntry.deleteObject(previousTaskEntry)

        // Purge Task if it is not referenced any longer.
        Task.purgeIfEmpty(previousTaskEntry.task, exceptTaskEntry: previousTaskEntry)

        taskEntryToModify.setStartedAt(startTime)

        TimePoliceModelUtils.save(moc)
    }




    //---------------------------------------------
    // Session - deleteNextTaskEntryAndAlignStop
    //---------------------------------------------

/*
    GUI operation: "swipeDown"


            taskEntryToModify
    N/A *** |------------?


            taskEntryToModify  nextTaskEntry                 taskEntryToModify
    pc1 *** |------------| ... |--------? ***     ==>    *** |------------? ***
            1            2     3        4                    1            4
*/
    func deleteNextTaskEntryAndAlignStop(moc: NSManagedObjectContext, taskEntryIndex: Int) {
        UtilitiesApplog.logDefault("Session", logtype: .EnterExit, message: "deletePreviousTaskEntryAndAlignStop(taskEntryIndex=\(taskEntryIndex))")

        if taskEntryIndex < 0 || taskEntryIndex >= taskEntries.count  {
            // Index out of bounds
            return
        }

        if taskEntryIndex == taskEntries.count-1 {
            // No next taskentry
            return
        }

        let taskEntryToModify = taskEntries[taskEntryIndex] as! TaskEntry
        let nextTaskEntry = taskEntries[taskEntryIndex+1] as! TaskEntry

        if nextTaskEntry.isOngoing() {
            taskEntryToModify.setAsOngoing()
        } else {
            taskEntryToModify.setStoppedAt(nextTaskEntry.stopTime)
        }

        TaskEntry.deleteObject(nextTaskEntry)

        // Purge Task if it is not referenced any longer.
        Task.purgeIfEmpty(nextTaskEntry.task, exceptTaskEntry: nextTaskEntry)

        TimePoliceModelUtils.save(moc)        
    }





    //---------------------------------------------
    // Session - deleteTaskEntry
    //---------------------------------------------

/*
    GUI operation: "swipeLR"

            taskEntryToModify
    pc1 *** |------------? ***                       ==>  ***  (removed)  ***
*/

    func deleteTaskEntry(moc: NSManagedObjectContext, taskEntryIndex: Int) {
        UtilitiesApplog.logDefault("Session", logtype: .EnterExit, message: "deleteTaskEntry(taskEntryIndex=\(taskEntryIndex))")

        if taskEntryIndex < 0 || taskEntryIndex >= taskEntries.count  {
            // Index out of bounds
            return
        }

        let taskEntryToModify = taskEntries[taskEntryIndex] as! TaskEntry
        
        UtilitiesApplog.logDefault("Session", logtype: .Debug, message: "delete the taskentry item")
        
        // Deete taskentry, this will also try to purge the task.
        TaskEntry.deleteObject(taskEntryToModify)

        TimePoliceModelUtils.save(moc)        
    }

}
