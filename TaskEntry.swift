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

    let stoptimeOngoing = Date(timeIntervalSince1970: 0)
    
    //---------------------------------------------
    // TaskEntry - createInMOC
    //---------------------------------------------
    
    class func createInMOC(_ moc: NSManagedObjectContext,
        name: String, session: Session, task: Task) -> TaskEntry {
            UtilitiesApplog.logDefault("TaskEntry", logtype: .enterExit, message: "createInMOC(name=\(name), session=\(session.name), task=\(task.name))")
            
            let n = UtilitiesString.getWithoutProperties(name)
            let p = UtilitiesString.getProperties(name)
            return TaskEntry.createInMOC(moc, name: n, properties: p, session: session, task: task)
    }
    
    class func createInMOC(_ moc: NSManagedObjectContext,
        name: String, properties: [String: String], session: Session, task: Task) -> TaskEntry {
            UtilitiesApplog.logDefault("TaskEntry", logtype: .enterExit, message: "createInMOC(name=\(name), session=\(session.name), task=\(task.name), props...)")
            
            let newItem = NSEntityDescription.insertNewObject(forEntityName: "TaskEntry", into: moc) as! TaskEntry
            
            let date = Date()
            let deviceName = UIDevice.current.name
            newItem.id = "W:(no name)/\(date.timeIntervalSince1970)/\(deviceName)"
            newItem.name = name
            newItem.created = date
            newItem.properties = properties as NSObject
            newItem.startTime = date
            newItem.stopTime = Date(timeIntervalSince1970: 0) // stoptimeOngoing
            
            // Maintain relations
            newItem.task = task
            newItem.session = session
            
            task.addTaskEntry(newItem)
            session.addTaskEntry(newItem)
            
            let s = UtilitiesString.dumpProperties(properties)
            UtilitiesApplog.logDefault("TaskEntry properties", logtype: .debug, message: s)
            
            return newItem
    }
    
    
    class func createInMOCBeforeIndex(_ moc: NSManagedObjectContext,
        session: Session, index: Int) -> TaskEntry? {
            UtilitiesApplog.logDefault("TaskEntry", logtype: .enterExit, message: "createInMOCBeforeIndex(name=\(session.name), index=\(index)")
            
            guard let templateItem = session.getTaskEntry(index) else {
                UtilitiesApplog.logDefault("TaskEntry", logtype: .guard, message: "guard fail createInMOCBeforeIndex")
                return nil
            }
            
            let newItem = NSEntityDescription.insertNewObject(forEntityName: "TaskEntry", into: moc) as! TaskEntry
            
            let date = Date()
            let deviceName = UIDevice.current.name
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
                UtilitiesApplog.logDefault("TaskEntry.createInMOC", logtype: .debug, message: s)
            }
            
            return newItem
    }
    
    class func createInMOCAfterIndex(_ moc: NSManagedObjectContext,
        session: Session, index: Int) -> TaskEntry? {
            UtilitiesApplog.logDefault("TaskEntry", logtype: .enterExit, message: "createInMOCAfterIndex(name=\(session.name), index=\(index)")
            
            guard let templateItem = session.getTaskEntry(index) else {
                UtilitiesApplog.logDefault("TaskEntry", logtype: .guard, message: "guard fail createInMOCAfterIndex")
                return nil
            }
            
            let newItem = NSEntityDescription.insertNewObject(forEntityName: "TaskEntry", into: moc) as! TaskEntry
            
            let date = Date()
            let deviceName = UIDevice.current.name
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
                UtilitiesApplog.logDefault("TaskEntry.createInMOC", logtype: .debug, message: s)
            }
            
            return newItem
    }
    
    
    //---------------------------------------------
    // TaskEntry - Core Data manipulation
    //---------------------------------------------
    
    class func deleteObject(_ taskEntry: TaskEntry) {
        UtilitiesApplog.logDefault("TaskEntry", logtype: .enterExit, message: "deleteObject(name=\(taskEntry.name))")
        guard let moc = taskEntry.managedObjectContext else { return }
        let task = taskEntry.task
        moc.delete(taskEntry)
        UtilitiesApplog.logDefault("TaskEntry", logtype: .enterExit, message: "Purge task if orhpaned")
        Task.purgeIfEmpty(task, exceptTaskEntry: taskEntry)
    }
    
    func changeTaskTo(_ newTask: Task) {
        UtilitiesApplog.logDefault("TaskEntry", logtype: .enterExit, message: "changeTaskTo(name=\(newTask.name))")
        let oldTask = self.task
        self.task = newTask
        UtilitiesApplog.logDefault("TaskEntry", logtype: .enterExit, message: "Purge task if orhpaned")
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
    
    func setStartedAt(_ time: Date) {
        UtilitiesApplog.logDefault("TaskEntry", logtype: .enterExit, message: "setStartedAt(\(UtilitiesDate.getString(time))")
        
        if isStopped() && time.compare(self.stopTime) == .orderedDescending {
            // Don't set a stopped item's starttime > stoptime
            return
        }
        if isOngoing() {
            // Keep taskentry as ongoing if it already is ongoing
            self.stopTime = stoptimeOngoing
        }
        self.startTime = time
    }
    
    func setStoppedAt(_ time: Date) {
        UtilitiesApplog.logDefault("TaskEntry", logtype: .enterExit, message: "setStoppedAt(\(UtilitiesDate.getString(time))")
        
        if time.compare(self.startTime) == .orderedAscending {
            // Don't set an item's stoptime < starttime
            return
        }
        self.stopTime = time            
    }
    
    func setAsOngoing() {
        UtilitiesApplog.logDefault("TaskEntry", logtype: .enterExit, message: "setAsOngoing()")
        
        self.stopTime = stoptimeOngoing
    }

}
