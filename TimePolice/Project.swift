//
//  Project.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-11-02.
//  Copyright © 2015 Per Ekskog. All rights reserved.
//

import Foundation
import CoreData


class Project: NSManagedObject {

    //---------------------------------------------
    // Project - createInMOC
    //---------------------------------------------

    class func createInMOC(moc: NSManagedObjectContext, name: String) -> Project {

        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Project", inManagedObjectContext: moc) as! Project

        let date = NSDate()
        let dateAndTime = NSDateFormatter.localizedStringFromDate(date,
                    dateStyle: NSDateFormatterStyle.ShortStyle,
                    timeStyle: NSDateFormatterStyle.MediumStyle)
        newItem.id = "[Project] \(dateAndTime) - \(date.timeIntervalSince1970)"
        newItem.name = name
        newItem.created = date

        newItem.properties = [String: String]()
        if let p = UtilitiesString.getProperties(name) {
            newItem.properties = p
            newItem.name = UtilitiesString.getWithoutProperties(name)
        }

        return newItem
    }

    //---------------------------------------------
    // Project - delete
    //---------------------------------------------

    class func deleteInMOC(moc: NSManagedObjectContext, project: Project) {
    
        for session in project.sessions {
            Session.deleteInMOC(moc, session: session as! Session)
        }
        moc.deleteObject(project)
    }


    //---------------------------------------------
    // Project - addSession (internal use only)
    //---------------------------------------------

    func addSession(session: Session) {
        let s = self.sessions.mutableCopy() as! NSMutableSet
        s.addObject(session)
        self.sessions = s
    }


    //---------------------------------------------
    // Project - findInMOC
    //---------------------------------------------

    class func findInMOC(moc: NSManagedObjectContext, name: String) -> [Project]? {

        let fetchRequest = NSFetchRequest(entityName: "Project")
        let predicate = NSPredicate(format: "name == %@", name) 
        fetchRequest.predicate = predicate

        do {
            let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Project]

            return fetchResults
        } catch {
            return nil
        }
    }

    class func findInMOC(moc: NSManagedObjectContext) -> [Project]? {

        let fetchRequest = NSFetchRequest(entityName: "Project")

        do {
            let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Project]

            return fetchResults
        } catch {
            return nil
        }
    }
}
