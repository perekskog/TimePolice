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

/*  TODO

- Missing: AppLog
  Or perhaps throw some errors?

*/




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
        } catch {
            print("Can't fetch work for deletion")
        }
        
        do {
            // Delete all tasks
            fetchRequest = NSFetchRequest(entityName: "Task")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Task] {
                for task in fetchResults {
                    moc.deleteObject(task)
                }
            }
        } catch {
            print("Can't fetch tasks for deletion")
        }
        
        do {
            // Delete all sessions
            fetchRequest = NSFetchRequest(entityName: "Session")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Session] {
                for session in fetchResults {
                    moc.deleteObject(session)
                }
            }
        } catch {
            print("Can't fetch sessions for deletion")
        }
        
        do {
            // Delete all projects
            fetchRequest = NSFetchRequest(entityName: "Project")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Project] {
                for project in fetchResults {
                    moc.deleteObject(project)
                }
            }
        } catch {
            print("Can't fetch projects for deletion")
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
                    s += ("P: \(project.name) @ \(UtilitiesDate.getString(project.created))\n")
                    for (key, value) in project.properties as! [String: String] {
                        s += "[\(key)]=[\(value)]\n"
                    }
                    s += "    [Session container size=\(project.sessions.count)]\n"
                    for session in project.sessions {
                        s += "    S: \(session.name) @ \(UtilitiesDate.getString(session.created))\n"
                    }
                }
            }
        } catch {
            print("Can't fetch projects")
        }

        do {
            s += "\n"
            s += ("---------------------------\n")
            s += ("----------Session----------\n\n")
            fetchRequest = NSFetchRequest(entityName: "Session")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Session] {
                s += "[Session container size=\(fetchResults.count)]\n"
                for session in fetchResults {
                    s += ("S: \(session.name) @ \(UtilitiesDate.getString(session.created))\n")
                    for (key, value) in session.properties as! [String: String] {
                        s += "[\(key)]=[\(value)]\n"
                    }
                    s += ("    P: \(session.project.name) @ \(UtilitiesDate.getString(session.project.created))\n")
                    s += "    [Work container size=\(session.work.count)]\n"
                    session.work.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
                        let work = elem as! Work
                        if work.isStopped() {
                            let timeForWork = work.stopTime.timeIntervalSinceDate(work.startTime)
                            s += "    W: \(work.task.name) \(UtilitiesDate.getString(work.startTime))->\(UtilitiesDate.getStringNoDate(work.stopTime)) = \(UtilitiesDate.getString(timeForWork))\n"
                        } else {
                            s += "    W: \(work.task.name) \(UtilitiesDate.getString(work.startTime))->(ongoing) = ------\n"
                        }
                    }
                    s += "    [Task container size=\(session.tasks.count)]\n"
                    session.tasks.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
                        let task = elem as! Task
                        s += ("    T: \(task.name)\n")
                    }
                }
            }
        } catch {
            print("Can't fetch sessions")
        }
        
        
        do {
            s += "\n"
            s += ("------------------------\n")
            s += ("----------Work----------\n\n")
            fetchRequest = NSFetchRequest(entityName: "Work")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Work] {
                s += "[Work container size=\(fetchResults.count)]\n"
                for work in fetchResults {
                    if work.isStopped() {
                        let timeForWork = work.stopTime.timeIntervalSinceDate(work.startTime)
                        s += "W: \(work.task.name) \(UtilitiesDate.getString(work.startTime))->\(UtilitiesDate.getStringNoDate(work.stopTime)) = \(UtilitiesDate.getString(timeForWork))\n"
                    } else {
                        s += "W: \(work.task.name) \(UtilitiesDate.getString(work.startTime))->(ongoing) = ------\n"
                    }
                    for (key, value) in work.properties as! [String: String] {
                        s += "[\(key)]=[\(value)]\n"
                    }
                    s += "    S: \(work.session.name) @ \(UtilitiesDate.getString(work.session.created))\n"
                    s += "    T: \(work.task.name) @ \(UtilitiesDate.getString(work.task.created))\n"
                }
            }
        } catch {
            print("Can't fetch work")
        }
        
        do {
            s += "\n"
            s += ("------------------------\n")
            s += ("----------Task----------\n\n")
            fetchRequest = NSFetchRequest(entityName: "Task")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Task] {
                s += "[Task container size=\(fetchResults.count)]\n"
                for task in fetchResults {
                    s += ("T: \(task.name) @ \(UtilitiesDate.getString(task.created))\n")
                    for (key, value) in task.properties as! [String: String] {
                        s += "[\(key)]=[\(value)]\n"
                    }
                    s += "    [Session container size=\(task.sessions.count)]\n"
                    for session in task.sessions {
                        s += ("    S: \(session.name) @ \(UtilitiesDate.getString(session.created))\n")
                    }
                    s += "    [Work container size=\(task.work.count)]\n"
                    task.work.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
                        let work = elem as! Work
                        if work.isStopped() {
                            let timeForWork = work.stopTime.timeIntervalSinceDate(work.startTime)
                            s += "    W: \(work.task.name) \(UtilitiesDate.getString(work.startTime))->\(UtilitiesDate.getStringNoDate(work.stopTime)) = \(UtilitiesDate.getString(timeForWork))\n"
                        } else {
                            s += "    W: \(work.task.name) \(UtilitiesDate.getString(work.startTime))->(ongoing) = ------\n"
                        }
                    }
                }
            }
        
        } catch {
            print("Can't fetch tasks")
        }

        return s
    }

    //---------------------------------------------
    // TimePoliceModelUtils - getSessionTasks
    //---------------------------------------------

    class func getSessionTasks(session: Session) -> String {
        var s = "\(session.name)-\(UtilitiesDate.getString(session.created))\n"
        let summary = session.getSessionTaskSummary()
        for task in session.tasks.array as! [Task] {
            let withoutComment = task.name
            if withoutComment != "" {
                var time: NSTimeInterval = 0
                if let (_, t) = summary[task] {
                    time = t
                }
                s += "\(withoutComment)\t\(UtilitiesDate.getString(time))\n"
            }
        }
        return s
    }



    //---------------------------------------------
    // TimePoliceModelUtils - getSessionWork
    //---------------------------------------------

    class func getSessionWork(session: Session) -> String {

        var s: String

        s = "Current Session:\n"
        s += "S: \(session.name) @ \(UtilitiesDate.getString(session.created))\n"
        s += "    P: \(session.project.name) @ \(UtilitiesDate.getString(session.project.created))\n"
        session.work.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
            let work = elem as! Work
            if work.isStopped() {
                let timeForWork = work.stopTime.timeIntervalSinceDate(work.startTime)
                s += "    W: \(work.task.name) \(UtilitiesDate.getString(work.startTime))->\(UtilitiesDate.getStringNoDate(work.stopTime)) = \(UtilitiesDate.getString(timeForWork))\n"
            } else {
                s += "    W: \(work.task.name) \(UtilitiesDate.getString(work.startTime))->(ongoing) = ------\n"
            }
        }

        return s
    }

}



