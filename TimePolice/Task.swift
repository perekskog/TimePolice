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

    class func createInMOC(moc: NSManagedObjectContext, 
            name: String, session: Session) -> Task {
        UtilitiesApplog.logDefault("Task", logtype: .EnterExit, message: "createInMOC(name=\(name), session=\(session.name))")
        
        let n = UtilitiesString.getWithoutProperties(name)
        let p = UtilitiesString.getProperties(name)
        return Task.createInMOC(moc, name: n, properties: p, session: session)
    }


    class func createInMOC(moc: NSManagedObjectContext, 
            name: String, properties: [String: String], session: Session) -> Task {
        UtilitiesApplog.logDefault("Task", logtype: .EnterExit, message: "createInMOC(name=\(name), session=\(session.name), props...)")

        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Task", inManagedObjectContext: moc) as! Task

        let date = NSDate()
        let deviceName = UIDevice.currentDevice().name
        newItem.id = "T:\(name)/\(date.timeIntervalSince1970)/\(deviceName)"
        newItem.name = name
        newItem.created = date
        newItem.properties = properties

        // Maintain relations
        session.addTask(newItem)

        let s = UtilitiesString.dumpProperties(properties)
        UtilitiesApplog.logDefault("Task properties", logtype: .Debug, message: s)

        return newItem
    }

    //---------------------------------------------
    // Task - delete
    //---------------------------------------------

    class func deleteObjectOnly(task: Task) {
        UtilitiesApplog.logDefault("Task", logtype: .EnterExit, message: "deleteObjectOnly(name=\(task.name))")
        guard let moc = task.managedObjectContext else { return }
        moc.deleteObject(task)
    }

    class func deleteObject(task: Task) {
        UtilitiesApplog.logDefault("Task", logtype: .EnterExit, message: "deleteObject(name=\(task.name))")
        guard let moc = task.managedObjectContext else { return }
        let worklist = task.work
        moc.deleteObject(task)
        UtilitiesApplog.logDefault("Task", logtype: .Debug, message: "Delete all work")
        for work in worklist {
            if let w = work as? Work {
                Work.deleteObject(w)
            }
        }
    }

    //---------------------------------------------
    // Task - purge
    //---------------------------------------------

    class func purgeIfEmpty(task: Task) {
        UtilitiesApplog.logDefault("Task", logtype: .EnterExit, message: "purgeIfEmpty(name=\(task.name))")
        if task.sessions.count==0 && task.work.count==0 {
            Task.deleteObjectOnly(task)
            UtilitiesApplog.logDefault("Task", logtype: .EnterExit, message: "Task deleted because no sessions and no work left.")
        } else {
            UtilitiesApplog.logDefault("Task", logtype: .EnterExit, message: "Task not deleted, \(task.sessions.count) sessions left, \(task.work.count) work left.")
        }
    }

    class func purgeIfEmpty(task: Task, exceptSession session: Session) {
        UtilitiesApplog.logDefault("Task", logtype: .EnterExit, message: "purgeIfEmpty(name=\(task.name),session=\(session.name))")
        if (task.sessions.count==0 || (task.sessions.count==1 && task.sessions.containsObject(session))) && task.work.count==0 {
            Task.deleteObjectOnly(task)
            UtilitiesApplog.logDefault("Task", logtype: .EnterExit, message: "Task deleted because none or only 1 specific session left, and no work left.")
        } else {
            UtilitiesApplog.logDefault("Task", logtype: .EnterExit, message: "Task not deleted, \(task.sessions.count) sessions left, \(task.work.count) work left.")
        }
    }

    class func purgeIfEmpty(task: Task, exceptWork work: Work) {
        UtilitiesApplog.logDefault("Task", logtype: .EnterExit, message: "purgeIfEmpty(name=\(task.name),work=\(work.name))")
        if (task.work.count==0 || (task.work.count==1 && task.work.containsObject(work))) && task.sessions.count==0 {
            Task.deleteObjectOnly(task)
            UtilitiesApplog.logDefault("Task", logtype: .EnterExit, message: "Task deleted because none or only 1 specific work left, and no sessions left.")
        } else {
            UtilitiesApplog.logDefault("Task", logtype: .EnterExit, message: "Task not deleted, \(task.sessions.count) sessions left, \(task.work.count) work left.")
        }
    }

    //---------------------------------------------
    // Task - getProperty
    //---------------------------------------------
    
    func getProperty(key: String) -> String? {
        // UtilitiesApplog.logDefault("Task", logtype: .EnterExit, message: "getProperty(key=\(key))")
        guard let p = properties as? [String: String] else {
            UtilitiesApplog.logDefault("Task", logtype: .Guard, message: "guard fail getProperty")
            return nil
        }
        return p[key]
    }

    
    //---------------------------------------------
    // Task - addWork
    //---------------------------------------------
    
    func addWork(work: Work) {
        UtilitiesApplog.logDefault("Task", logtype: .EnterExit, message: "addWork(work=\(work.name))")
        let sw = self.work.mutableCopy() as! NSMutableOrderedSet
        sw.addObject(work)
        self.work = sw
    }
    
    //---------------------------------------------
    // Task - addSession
    //---------------------------------------------
    
    func addSession(session: Session) {
        UtilitiesApplog.logDefault("Task", logtype: .EnterExit, message: "addSession(session=\(session.name))")
        let ss = self.sessions.mutableCopy() as! NSMutableSet
        ss.addObject(session)
        self.sessions = ss
    }

    //---------------------------------------------
    // Task - deleteSession
    //---------------------------------------------
    
    func deleteSession(session: Session) {
        UtilitiesApplog.logDefault("Task", logtype: .EnterExit, message: "deleteSession(session=\(session.name))")
        let ss = self.sessions.mutableCopy() as! NSMutableSet
        ss.removeObject(session)
        self.sessions = ss
    }

}
