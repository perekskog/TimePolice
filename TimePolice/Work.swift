//
//  Work.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-11-02.
//  Copyright © 2015 Per Ekskog. All rights reserved.
//

import Foundation
import CoreData
import UIKit

/*
    // Readonly attribute
    @NSManaged var startTime: NSDate
    // Readonly attribute. Valid if isOngoing retirns true.
    @NSManaged var stopTime: NSDate
*/

class Work: NSManagedObject {

    let stoptimeOngoing = NSDate(timeIntervalSince1970: 0)

    //---------------------------------------------
    // Work - createInMOC
    //---------------------------------------------

    class func createInMOC(moc: NSManagedObjectContext,
            name: String, session: Session, task: Task) -> Work {
        UtilitiesApplog.logDefault("Work", logtype: .EnterExit, message: "createInMOC(name=\(name), session=\(session.name), task=\(task.name))")
   
        let n = UtilitiesString.getWithoutProperties(name)
        let p = UtilitiesString.getProperties(name)
        return Work.createInMOC(moc, name: n, properties: p, session: session, task: task)
    }
    
    class func createInMOC(moc: NSManagedObjectContext,
        name: String, properties: [String: String], session: Session, task: Task) -> Work {
        UtilitiesApplog.logDefault("Work", logtype: .EnterExit, message: "createInMOC(name=\(name), session=\(session.name), task=\(task.name), props...)")
            
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Work", inManagedObjectContext: moc) as! Work
        
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
        
        task.addWork(newItem)
        session.addWork(newItem)
        
        let s = UtilitiesString.dumpProperties(properties)
        UtilitiesApplog.logDefault("Work properties", logtype: .Debug, message: s)
        
        return newItem
    }


    class func createInMOCBeforeIndex(moc: NSManagedObjectContext, 
            session: Session, index: Int) -> Work? {
        UtilitiesApplog.logDefault("Work", logtype: .EnterExit, message: "createInMOCBeforeIndex(name=\(session.name), index=\(index)")

        guard let templateItem = session.getWork(index) else {
            UtilitiesApplog.logDefault("Work", logtype: .Guard, message: "guard fail createInMOCBeforeIndex")
            return nil
        }

        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Work", inManagedObjectContext: moc) as! Work

        let date = NSDate()
        let deviceName = UIDevice.currentDevice().name
        newItem.id = "W:(no name)/\(date.timeIntervalSince1970)/\(deviceName)"
        newItem.name = templateItem.name
        newItem.created = date
        newItem.properties = templateItem.properties
        newItem.startTime = templateItem.startTime
        newItem.stopTime = templateItem.startTime

        templateItem.task.addWork(newItem)
        templateItem.session.insertWorkBefore(newItem, index: index)

        // Maintain relations
        newItem.task = templateItem.task
        newItem.session = templateItem.session
                
        if let p = templateItem.properties as? [String: String] {
            let s = UtilitiesString.dumpProperties(p)
            UtilitiesApplog.logDefault("Work.createInMOC", logtype: .Debug, message: s)
        }

        return newItem
    }

    class func createInMOCAfterIndex(moc: NSManagedObjectContext, 
            session: Session, index: Int) -> Work? {
        UtilitiesApplog.logDefault("Work", logtype: .EnterExit, message: "createInMOCAfterIndex(name=\(session.name), index=\(index)")

        guard let templateItem = session.getWork(index) else {
            UtilitiesApplog.logDefault("Work", logtype: .Guard, message: "guard fail createInMOCAfterIndex")
            return nil
        }

        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Work", inManagedObjectContext: moc) as! Work

        let date = NSDate()
        let deviceName = UIDevice.currentDevice().name
        newItem.id = "W:(no name)/\(date.timeIntervalSince1970)/\(deviceName)"
        newItem.name = templateItem.name
        newItem.created = date
        newItem.properties = templateItem.properties
        newItem.startTime = templateItem.stopTime
        newItem.stopTime = templateItem.stopTime

        templateItem.task.addWork(newItem)
        templateItem.session.insertWorkAfter(newItem, index: index)

        // Maintain relations
        newItem.task = templateItem.task
        newItem.session = templateItem.session
                
        if let p = templateItem.properties as? [String: String] {
            let s = UtilitiesString.dumpProperties(p)
            UtilitiesApplog.logDefault("Work.createInMOC", logtype: .Debug, message: s)
        }

        return newItem
    }


    //---------------------------------------------
    // Work - delete
    //---------------------------------------------

    class func deleteObject(work: Work) {
        UtilitiesApplog.logDefault("Work", logtype: .EnterExit, message: "deleteObject(name=\(work.name))")
        guard let moc = work.managedObjectContext else { return }
        let task = work.task
        moc.deleteObject(work)
        UtilitiesApplog.logDefault("Work", logtype: .EnterExit, message: "Purge task if orhpaned")
        Task.purgeIfEmpty(task, exceptWork: work)
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
        UtilitiesApplog.logDefault("Work", logtype: .EnterExit, message: "setStartedAt(\(UtilitiesDate.getString(time))")

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
        UtilitiesApplog.logDefault("Work", logtype: .EnterExit, message: "setStoppedAt(\(UtilitiesDate.getString(time))")

        if time.compare(self.startTime) == .OrderedAscending {
            // Don't set an item's stoptime < starttime
            return
        }
        self.stopTime = time            
    }

    func setAsOngoing() {
        UtilitiesApplog.logDefault("Work", logtype: .EnterExit, message: "setAsOngoing()")

        self.stopTime = stoptimeOngoing
    }

}
