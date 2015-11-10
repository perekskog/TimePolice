//
//  Task.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-11-02.
//  Copyright © 2015 Per Ekskog. All rights reserved.
//

import Foundation
import CoreData


class Task: NSManagedObject {

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
        newItem.created = date


        newItem.properties = [String: String]()
        if let p = UtilitiesString.getProperties(name) {
            newItem.properties = p
            newItem.name = UtilitiesString.getWithoutProperties(name)
        }

        // Maintain relations
        session.addTask(newItem)

        if let props = UtilitiesString.getProperties(name) {
            let s = UtilitiesString.dumpProperties(props)
            UtilitiesApplog.logDefault("Task.createInMOC", logtype: .Debug, message: s)
        }


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
    // Task - getProperty
    //---------------------------------------------
    
    func getProperty(key: String) -> String? {
        guard let p = properties as? [String: String] else {
            return nil
        }
        return p[key]
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
