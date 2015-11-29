//
//  Session.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-11-02.
//  Copyright © 2015 Per Ekskog. All rights reserved.
//

import Foundation
import CoreData

/*  TODO

? Session.delete*
? Session.insert*
    Must update relations to session and tasks.

? Session.deleteWork
    Ej implementerad, behövs inte för att ta bort en session.

*/

class Session: NSManagedObject {

    //---------------------------------------------
    // Session - createInMOC
    //---------------------------------------------

    class func createInMOC(moc: NSManagedObjectContext, 
        name: String, project: Project, src: String) -> Session {

        let n = UtilitiesString.getWithoutProperties(name)
        let p = UtilitiesString.getProperties(name)
            let s = Session.createInMOC(moc, name: n, properties: p, project: project, src: src)
        return s
    }

    class func createInMOC(moc: NSManagedObjectContext, 
        name: String, properties: [String: String], project: Project, src: String) -> Session {
        
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Session", inManagedObjectContext: moc) as! Session

        let date = NSDate()
        let dateAndTime = NSDateFormatter.localizedStringFromDate(date,
                    dateStyle: NSDateFormatterStyle.ShortStyle,
                    timeStyle: NSDateFormatterStyle.MediumStyle)
        newItem.id = "[Session=\(name)] \(dateAndTime) - \(date.timeIntervalSince1970)"
        newItem.name = "\(name)"
        newItem.created = date
        newItem.properties = properties
        newItem.src = src
        
        newItem.project = project

        // Maintain relations
        project.addSession(newItem)

        let s = UtilitiesString.dumpProperties(properties)
        UtilitiesApplog.logDefault("Session.createInMOC", logtype: .Debug, message: s)

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
    // Session - getProperty
    //---------------------------------------------
    
    func getProperty(key: String) -> String? {
        guard let p = properties as? [String: String] else {
            return nil
        }
        return p[key]
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
    // Session - addTasks (internal use only)
    //---------------------------------------------

    func deleteTask(task: Task) {
        let st = self.tasks.mutableCopy() as! NSMutableOrderedSet
        st.removeObject(task)
        self.tasks = st
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

    func getSessionTaskSummary() -> [Task: (Int, NSTimeInterval)] {
        var sessionTaskSummary: [Task: (Int, NSTimeInterval)] = [:]

        self.work.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in

            let work = elem as! Work
            // For all ongoing items
            if work.isStopped() {
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
