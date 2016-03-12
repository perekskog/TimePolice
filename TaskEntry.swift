//
//  TaskEntry.swift
//  TimePolice
//
//  Created by Per Ekskog on 2016-01-25.
//  Copyright © 2016 Per Ekskog. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class TaskEntry: NSManagedObject {

    let stoptimeOngoing = NSDate(timeIntervalSince1970: 0)
    
    //---------------------------------------------
    // TaskEntry - createInMOC
    //---------------------------------------------
    
    class func createInMOC(moc: NSManagedObjectContext,
        name: String, session: Session, task: Task) -> TaskEntry {
            UtilitiesApplog.logDefault("TaskEntry", logtype: .EnterExit, message: "createInMOC(name=\(name), session=\(session.name), task=\(task.name))")
            
            let n = UtilitiesString.getWithoutProperties(name)
            let p = UtilitiesString.getProperties(name)
            return TaskEntry.createInMOC(moc, name: n, properties: p, session: session, task: task)
    }
    
    class func createInMOC(moc: NSManagedObjectContext,
        name: String, properties: [String: String], session: Session, task: Task) -> TaskEntry {
            UtilitiesApplog.logDefault("TaskEntry", logtype: .EnterExit, message: "createInMOC(name=\(name), session=\(session.name), task=\(task.name), props...)")
            
            let newItem = NSEntityDescription.insertNewObjectForEntityForName("TaskEntry", inManagedObjectContext: moc) as! TaskEntry
            
            let date = NSDate()
            let deviceName = UIDevice.currentDevice().name
            newItem.id = "W:(no name)/\(date.timeIntervalSince1970)/\(deviceName)"
            newItem.name = name
            newItem.created = date
            newItem.properties = properties
            newItem.startTime = date
            newItem.stopTime = NSDate(timeIntervalSince1970: 0) // stoptimeOngoing
            
            // Maintain relations
            newItem.task = task
            newItem.session = session
            
            task.addTaskEntry(newItem)
            session.addTaskEntry(newItem)
            
            let s = UtilitiesString.dumpProperties(properties)
            UtilitiesApplog.logDefault("TaskEntry properties", logtype: .Debug, message: s)
            
            return newItem
    }
    
    
    class func createInMOCBeforeIndex(moc: NSManagedObjectContext,
        session: Session, index: Int) -> TaskEntry? {
            UtilitiesApplog.logDefault("TaskEntry", logtype: .EnterExit, message: "createInMOCBeforeIndex(name=\(session.name), index=\(index)")
            
            guard let templateItem = session.getTaskEntry(index) else {
                UtilitiesApplog.logDefault("TaskEntry", logtype: .Guard, message: "guard fail createInMOCBeforeIndex")
                return nil
            }
            
            let newItem = NSEntityDescription.insertNewObjectForEntityForName("TaskEntry", inManagedObjectContext: moc) as! TaskEntry
            
            let date = NSDate()
            let deviceName = UIDevice.currentDevice().name
            newItem.id = "W:(no name)/\(date.timeIntervalSince1970)/\(deviceName)"
            newItem.name = templateItem.name
            newItem.created = date
            newItem.properties = templateItem.properties
            newItem.startTime = templateItem.startTime
            newItem.stopTime = templateItem.startTime
            
            templateItem.task.addTaskEntry(newItem)
            templateItem.session.insertTaskEntryBefore(newItem, index: index)
            
            // Maintain relations
            newItem.task = templateItem.task
            newItem.session = templateItem.session
            
            if let p = templateItem.properties as? [String: String] {
                let s = UtilitiesString.dumpProperties(p)
                UtilitiesApplog.logDefault("TaskEntry.createInMOC", logtype: .Debug, message: s)
            }
            
            return newItem
    }
    
    class func createInMOCAfterIndex(moc: NSManagedObjectContext,
        session: Session, index: Int) -> TaskEntry? {
            UtilitiesApplog.logDefault("TaskEntry", logtype: .EnterExit, message: "createInMOCAfterIndex(name=\(session.name), index=\(index)")
            
            guard let templateItem = session.getTaskEntry(index) else {
                UtilitiesApplog.logDefault("TaskEntry", logtype: .Guard, message: "guard fail createInMOCAfterIndex")
                return nil
            }
            
            let newItem = NSEntityDescription.insertNewObjectForEntityForName("TaskEntry", inManagedObjectContext: moc) as! TaskEntry
            
            let date = NSDate()
            let deviceName = UIDevice.currentDevice().name
            newItem.id = "W:(no name)/\(date.timeIntervalSince1970)/\(deviceName)"
            newItem.name = templateItem.name
            newItem.created = date
            newItem.properties = templateItem.properties
            newItem.startTime = templateItem.stopTime
            newItem.stopTime = templateItem.stopTime
            
            templateItem.task.addTaskEntry(newItem)
            templateItem.session.insertTaskEntryAfter(newItem, index: index)
            
            // Maintain relations
            newItem.task = templateItem.task
            newItem.session = templateItem.session
            
            if let p = templateItem.properties as? [String: String] {
                let s = UtilitiesString.dumpProperties(p)
                UtilitiesApplog.logDefault("TaskEntry.createInMOC", logtype: .Debug, message: s)
            }
            
            return newItem
    }
    
    
    //---------------------------------------------
    // TaskEntry - Core Data manipulation
    //---------------------------------------------
    
    class func deleteObject(taskEntry: TaskEntry) {
        UtilitiesApplog.logDefault("TaskEntry", logtype: .EnterExit, message: "deleteObject(name=\(taskEntry.name))")
        guard let moc = taskEntry.managedObjectContext else { return }
        let task = taskEntry.task
        moc.deleteObject(taskEntry)
        UtilitiesApplog.logDefault("TaskEntry", logtype: .EnterExit, message: "Purge task if orhpaned")
        Task.purgeIfEmpty(task, exceptTaskEntry: taskEntry)
    }
    
    func changeTaskTo(newTask: Task) {
        UtilitiesApplog.logDefault("TaskEntry", logtype: .EnterExit, message: "changeTaskTo(name=\(newTask.name))")
        let oldTask = self.task
        self.task = newTask
        UtilitiesApplog.logDefault("TaskEntry", logtype: .EnterExit, message: "Purge task if orhpaned")
        Task.purgeIfEmpty(oldTask, exceptTaskEntry: self)
    }
    
    //---------------------------------------------
    // TaskEntry - isOngoing
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
        UtilitiesApplog.logDefault("TaskEntry", logtype: .EnterExit, message: "setStartedAt(\(UtilitiesDate.getString(time))")
        
        if isStopped() && time.compare(self.stopTime) == .OrderedDescending {
            // Don't set a stopped item's starttime > stoptime
            return
        }
        if isOngoing() {
            // Keep taskentry as ongoing if it already is ongoing
            self.stopTime = stoptimeOngoing
        }
        self.startTime = time
    }
    
    func setStoppedAt(time: NSDate) {
        UtilitiesApplog.logDefault("TaskEntry", logtype: .EnterExit, message: "setStoppedAt(\(UtilitiesDate.getString(time))")
        
        if time.compare(self.startTime) == .OrderedAscending {
            // Don't set an item's stoptime < starttime
            return
        }
        self.stopTime = time            
    }
    
    func setAsOngoing() {
        UtilitiesApplog.logDefault("TaskEntry", logtype: .EnterExit, message: "setAsOngoing()")
        
        self.stopTime = stoptimeOngoing
    }

}
