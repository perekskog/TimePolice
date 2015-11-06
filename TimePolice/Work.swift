//
//  Work.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-11-02.
//  Copyright © 2015 Per Ekskog. All rights reserved.
//

import Foundation
import CoreData

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

    class func createInMOC(moc: NSManagedObjectContext, name: String, session: Session, task: Task) -> Work {
        
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Work", inManagedObjectContext: moc) as! Work

        let date = NSDate()
        let dateAndTime = NSDateFormatter.localizedStringFromDate(date,
                    dateStyle: NSDateFormatterStyle.ShortStyle,
                    timeStyle: NSDateFormatterStyle.MediumStyle)
        newItem.id = "[Work] \(dateAndTime) - \(date.timeIntervalSince1970)"
        newItem.name = name
        newItem.created = date
        newItem.properties = [String: String]()
        
        newItem.startTime = date
        newItem.stopTime = NSDate(timeIntervalSince1970: 0) // stoptimeOngoing

        // Maintain relations
        newItem.task = task
        newItem.session = session
        
        task.addWork(newItem)
        session.addWork(newItem)

        return newItem
    }
    
    class func createInMOCBeforeIndex(moc: NSManagedObjectContext, session: Session, index: Int) -> Work? {
        
        guard let templateItem = session.getWork(index) else {
            UtilitiesApplog.logDefault("Work", logtype: .Guard, message: "createInMOCBeforeIndex")
            return nil
        }

        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Work", inManagedObjectContext: moc) as! Work

        let date = NSDate()
        let dateAndTime = NSDateFormatter.localizedStringFromDate(date,
                dateStyle: NSDateFormatterStyle.ShortStyle,
                timeStyle: NSDateFormatterStyle.MediumStyle)
        newItem.id = "[Work] \(dateAndTime) - \(date.timeIntervalSince1970)"
        newItem.name = templateItem.name
        newItem.created = date
        newItem.properties = [String: String]()

        newItem.startTime = templateItem.startTime
        newItem.stopTime = templateItem.startTime

        templateItem.task.addWork(newItem)
        templateItem.session.insertWorkBefore(newItem, index: index)

        // Maintain relations
        newItem.task = templateItem.task
        newItem.session = templateItem.session

        return newItem
    }

    class func createInMOCAfterIndex(moc: NSManagedObjectContext, session: Session, index: Int) -> Work? {
        
        guard let templateItem = session.getWork(index) else {
            UtilitiesApplog.logDefault("Work", logtype: .Guard, message: "createInMOCAfterIndex")
            return nil
        }

        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Work", inManagedObjectContext: moc) as! Work

        let date = NSDate()
        let dateAndTime = NSDateFormatter.localizedStringFromDate(date,
                dateStyle: NSDateFormatterStyle.ShortStyle,
                timeStyle: NSDateFormatterStyle.MediumStyle)
        newItem.id = "[Work] \(dateAndTime) - \(date.timeIntervalSince1970)"
        newItem.name = templateItem.name
        newItem.created = date

        newItem.startTime = templateItem.stopTime
        newItem.stopTime = templateItem.stopTime

        templateItem.task.addWork(newItem)
        templateItem.session.insertWorkAfter(newItem, index: index)

        // Maintain relations
        newItem.task = templateItem.task
        newItem.session = templateItem.session

        return newItem
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
