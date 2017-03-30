//
//  Task.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-11-02.
//  Copyright © 2015 Per Ekskog. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class Task: NSManagedObject {

    //---------------------------------------------
    // Task - createInMOC
    //---------------------------------------------

    class func createInMOC(_ moc: NSManagedObjectContext, 
            name: String, session: Session) -> Task {
        UtilitiesApplog.logDefault("Task", logtype: .enterExit, message: "createInMOC(name=\(name), session=\(session.name))")
        
        let n = UtilitiesString.getWithoutProperties(name)
        let p = UtilitiesString.getProperties(name)
        return Task.createInMOC(moc, name: n, properties: p, session: session)
    }


    class func createInMOC(_ moc: NSManagedObjectContext, 
            name: String, properties: [String: String], session: Session) -> Task {
        UtilitiesApplog.logDefault("Task", logtype: .enterExit, message: "createInMOC(name=\(name), session=\(session.name), props...)")

        let newItem = NSEntityDescription.insertNewObject(forEntityName: "Task", into: moc) as! Task

        let date = Date()
        let deviceName = UIDevice.current.name
        newItem.id = "T:\(name)/\(date.timeIntervalSince1970)/\(deviceName)"
        newItem.name = name
        newItem.created = date
        newItem.properties = properties as NSObject

        // Maintain relations
        session.addTask(newItem)

        let s = UtilitiesString.dumpProperties(properties)
        UtilitiesApplog.logDefault("Task properties", logtype: .debug, message: s)

        return newItem
    }

    //---------------------------------------------
    // Task - delete
    //---------------------------------------------

    class func deleteObjectOnly(_ task: Task) {
        UtilitiesApplog.logDefault("Task", logtype: .enterExit, message: "deleteObjectOnly(name=\(task.name))")
        guard let moc = task.managedObjectContext else { return }
        moc.delete(task)
    }

    class func deleteObject(_ task: Task) {
        UtilitiesApplog.logDefault("Task", logtype: .enterExit, message: "deleteObject(name=\(task.name))")
        guard let moc = task.managedObjectContext else { return }
        let taskEntries = task.taskEntries
        moc.delete(task)
        UtilitiesApplog.logDefault("Task", logtype: .debug, message: "Delete all taskentries")
        for taskEntry in taskEntries {
            if let te = taskEntry as? TaskEntry {
                TaskEntry.deleteObject(te)
            }
        }
    }

    //---------------------------------------------
    // Task - purge
    //---------------------------------------------

    class func purgeIfEmpty(_ task: Task) {
        UtilitiesApplog.logDefault("Task", logtype: .enterExit, message: "purgeIfEmpty(name=\(task.name))")
        if task.sessions.count==0 && task.taskEntries.count==0 {
            Task.deleteObjectOnly(task)
            UtilitiesApplog.logDefault("Task", logtype: .enterExit, message: "Task deleted because no sessions and no taskentry left.")
        } else {
            UtilitiesApplog.logDefault("Task", logtype: .enterExit, message: "Task not deleted, \(task.sessions.count) sessions left, \(task.taskEntries.count) taskentry left.")
        }
    }

    class func purgeIfEmpty(_ task: Task, exceptSession session: Session) {
        UtilitiesApplog.logDefault("Task", logtype: .enterExit, message: "purgeIfEmpty(name=\(task.name),session=\(session.name))")
        if (task.sessions.count==0 || (task.sessions.count==1 && task.sessions.contains(session))) && task.taskEntries.count==0 {
            Task.deleteObjectOnly(task)
            UtilitiesApplog.logDefault("Task", logtype: .enterExit, message: "Task deleted because none or only 1 specific session left, and no taskentry left.")
        } else {
            UtilitiesApplog.logDefault("Task", logtype: .enterExit, message: "Task not deleted, \(task.sessions.count) sessions left, \(task.taskEntries.count) taskentry left.")
        }
    }

    class func purgeIfEmpty(_ task: Task, exceptTaskEntry taskEntry: TaskEntry) {
        UtilitiesApplog.logDefault("Task", logtype: .enterExit, message: "purgeIfEmpty(name=\(task.name),taskEntry=\(taskEntry.name))")
        if (task.taskEntries.count==0 || (task.taskEntries.count==1 && task.taskEntries.contains(taskEntry))) && task.sessions.count==0 {
            Task.deleteObjectOnly(task)
            UtilitiesApplog.logDefault("Task", logtype: .enterExit, message: "Task deleted because none or only 1 specific taskentry left, and no sessions left.")
        } else {
            UtilitiesApplog.logDefault("Task", logtype: .enterExit, message: "Task not deleted, \(task.sessions.count) sessions left, \(task.taskEntries.count) taskentry left.")
        }
    }

    class func purgeIfEmpty(_ task: Task, exceptSession session: Session, exceptTaskEntry taskEntry: TaskEntry) {
        UtilitiesApplog.logDefault("Task", logtype: .enterExit, message: "purgeIfEmpty(name=\(task.name),session=\(session.name),taskEntry=\(taskEntry.name))")
        if (task.taskEntries.count==0 || (task.taskEntries.count==1 && task.taskEntries.contains(taskEntry))) &&
            (task.sessions.count==0 || (task.sessions.count==1 && task.sessions.contains(session))){
            Task.deleteObjectOnly(task)
            UtilitiesApplog.logDefault("Task", logtype: .enterExit, message: "Task deleted because none or only 1 specific taskentry and/or session left.")
        } else {
            UtilitiesApplog.logDefault("Task", logtype: .enterExit, message: "Task not deleted, \(task.sessions.count) sessions left, \(task.taskEntries.count) taskentry left.")
        }
    }

    //---------------------------------------------
    // Task - getProperty
    //---------------------------------------------
    
    func getProperty(_ key: String) -> String? {
        // UtilitiesApplog.logDefault("Task", logtype: .EnterExit, message: "getProperty(key=\(key))")
        guard let p = properties as? [String: String] else {
            UtilitiesApplog.logDefault("Task", logtype: .guard, message: "guard fail getProperty")
            return nil
        }
        return p[key]
    }

    
    //---------------------------------------------
    // Task - addTaskEntry
    //---------------------------------------------
    
    func addTaskEntry(_ taskEntry: TaskEntry) {
        UtilitiesApplog.logDefault("Task", logtype: .enterExit, message: "addTaskEntry(taskEntry=\(taskEntry.name))")
        let sw = self.taskEntries.mutableCopy() as! NSMutableOrderedSet
        sw.add(taskEntry)
        self.taskEntries = sw
    }
    
    //---------------------------------------------
    // Task - addSession
    //---------------------------------------------
    
    func addSession(_ session: Session) {
        UtilitiesApplog.logDefault("Task", logtype: .enterExit, message: "addSession(session=\(session.name))")
        let ss = self.sessions.mutableCopy() as! NSMutableSet
        ss.add(session)
        self.sessions = ss
    }

    //---------------------------------------------
    // Task - deleteSession
    //---------------------------------------------
    
    func deleteSession(_ session: Session) {
        UtilitiesApplog.logDefault("Task", logtype: .enterExit, message: "deleteSession(session=\(session.name))")
        let ss = self.sessions.mutableCopy() as! NSMutableSet
        ss.remove(session)
        self.sessions = ss
    }

}
