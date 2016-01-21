//
//  Project.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-11-02.
//  Copyright © 2015 Per Ekskog. All rights reserved.
//

import Foundation
import UIKit    
import CoreData


/**
The special project "Templates" contains templates for creating sessions.
 
Sessions created from a template session with name "X" will be put in a project named "X". The sessions created will inherit both name and version attributes form the template session.

*/
class Project: NSManagedObject {

    //---------------------------------------------
    // Project - createInMOC
    //---------------------------------------------

    class func createInMOC(moc: NSManagedObjectContext, 
            name: String) -> Project {
        UtilitiesApplog.logDefault("Project", logtype: .EnterExit, message: "createInMOC(name=\(name))")

        let n = UtilitiesString.getWithoutProperties(name)
        let p = UtilitiesString.getProperties(name)
        return Project.createInMOC(moc, name: n, properties: p)
    }

    class func createInMOC(moc: NSManagedObjectContext, 
            name: String, properties: [String: String]) -> Project {
        UtilitiesApplog.logDefault("Project", logtype: .EnterExit, message: "createInMOC(name=\(name), props...)")

        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Project", inManagedObjectContext: moc) as! Project

        let date = NSDate()
        let deviceName = UIDevice.currentDevice().name
        newItem.id = "P:\(name)/\(date.timeIntervalSince1970)/\(deviceName)"
        newItem.name = name
        newItem.created = date
        newItem.properties = properties

        let s = UtilitiesString.dumpProperties(properties)
        UtilitiesApplog.logDefault("Project properties", logtype: .Debug, message: s)

        return newItem
    }

    //---------------------------------------------
    // Project - findInMOC
    //---------------------------------------------

    class func findInMOC(moc: NSManagedObjectContext, name: String) -> [Project]? {
        UtilitiesApplog.logDefault("Project", logtype: .EnterExit, message: "findInMOC(name=\(name))")

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
        UtilitiesApplog.logDefault("Project", logtype: .EnterExit, message: "findInMOC()")

        let fetchRequest = NSFetchRequest(entityName: "Project")

        do {
            let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Project]

            return fetchResults
        } catch {
            return nil
        }
    }

    //---------------------------------------------
    // Project - delete
    //---------------------------------------------

    class func deleteObjectOnly(project: Project) {
        UtilitiesApplog.logDefault("Project", logtype: .EnterExit, message: "deleteObjectOnly(name=\(project.name))")
        guard let moc = project.managedObjectContext else { return }
        moc.deleteObject(project)
    }

    class func deleteObject(project: Project) {
        UtilitiesApplog.logDefault("Project", logtype: .EnterExit, message: "deleteObject(name=\(project.name))")
        guard let moc = project.managedObjectContext else { return }
        let sessions = project.sessions
        moc.deleteObject(project)
        UtilitiesApplog.logDefault("Project", logtype: .Debug, message: "Delete all sessions")
        for session in sessions {
            if let s = session as? Session {
                Session.deleteObject(s)
            }
        }
    }

    //---------------------------------------------
    // Project - purge
    //---------------------------------------------
/*
    class func purgeIfEmpty(project: Project) {
        UtilitiesApplog.logDefault("Project", logtype: .EnterExit, message: "purgeIfEmpty(name=\(project.name))")
        if project.sessions.count==0 {
            Project.deleteObjectOnly(project)
            UtilitiesApplog.logDefault("Project", logtype: .EnterExit, message: "Project deleted because no sessions left.")
        }
        UtilitiesApplog.logDefault("Project", logtype: .EnterExit, message: "Project not deleted, \(project.sessions.count) sessions left.")
    }
*/
    class func purgeIfEmpty(project: Project, exceptSession session:Session) {
        UtilitiesApplog.logDefault("Project", logtype: .EnterExit, message: "purgeIfEmpty(name=\(project.name))")
        if project.sessions.count==0 || (project.sessions.count==1 && project.sessions.containsObject(session)) {
            Project.deleteObjectOnly(project)
            UtilitiesApplog.logDefault("Project", logtype: .EnterExit, message: "Project deleted because none or only 1 specific session left.")
        } else {
            UtilitiesApplog.logDefault("Project", logtype: .EnterExit, message: "Project not deleted, \(project.sessions.count) sessions left.")
        }
    }

    //---------------------------------------------
    // Project - addSession (internal use only)
    //---------------------------------------------

    func addSession(session: Session) {
        UtilitiesApplog.logDefault("Project", logtype: .EnterExit, message: "addSession(name=\(name), session=\(session.name))")
        let s = self.sessions.mutableCopy() as! NSMutableOrderedSet
        s.addObject(session)
        self.sessions = s
    }


}
