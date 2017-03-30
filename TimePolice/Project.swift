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

    class func createInMOC(_ moc: NSManagedObjectContext, 
            name: String) -> Project {
        UtilitiesApplog.logDefault("Project", logtype: .enterExit, message: "createInMOC(name=\(name))")

        let n = UtilitiesString.getWithoutProperties(name)
        let p = UtilitiesString.getProperties(name)
        return Project.createInMOC(moc, name: n, properties: p)
    }

    class func createInMOC(_ moc: NSManagedObjectContext, 
            name: String, properties: [String: String]) -> Project {
        UtilitiesApplog.logDefault("Project", logtype: .enterExit, message: "createInMOC(name=\(name), props...)")

        let newItem = NSEntityDescription.insertNewObject(forEntityName: "Project", into: moc) as! Project

        let date = Date()
        let deviceName = UIDevice.current.name
        newItem.id = "P:\(name)/\(date.timeIntervalSince1970)/\(deviceName)"
        newItem.name = name
        newItem.created = date
        newItem.properties = properties as NSObject

        let s = UtilitiesString.dumpProperties(properties)
        UtilitiesApplog.logDefault("Project properties", logtype: .debug, message: s)

        return newItem
    }

    //---------------------------------------------
    // Project - findInMOC
    //---------------------------------------------

    class func findInMOC(_ moc: NSManagedObjectContext, name: String) -> [Project]? {
        UtilitiesApplog.logDefault("Project", logtype: .enterExit, message: "findInMOC(name=\(name))")

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        let predicate = NSPredicate(format: "name == %@", name) 
        fetchRequest.predicate = predicate

        do {
            let fetchResults = try moc.fetch(fetchRequest) as? [Project]

            return fetchResults
        } catch {
            return nil
        }
    }

    class func findInMOC(_ moc: NSManagedObjectContext) -> [Project]? {
        UtilitiesApplog.logDefault("Project", logtype: .enterExit, message: "findInMOC()")

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")

        do {
            let fetchResults = try moc.fetch(fetchRequest) as? [Project]

            return fetchResults
        } catch {
            return nil
        }
    }

    //---------------------------------------------
    // Project - delete
    //---------------------------------------------

    class func deleteObjectOnly(_ project: Project) {
        UtilitiesApplog.logDefault("Project", logtype: .enterExit, message: "deleteObjectOnly(name=\(project.name))")
        guard let moc = project.managedObjectContext else { return }
        moc.delete(project)
    }

    class func deleteObject(_ project: Project) {
        UtilitiesApplog.logDefault("Project", logtype: .enterExit, message: "deleteObject(name=\(project.name))")
        guard let moc = project.managedObjectContext else { return }
        let sessions = project.sessions
        moc.delete(project)
        UtilitiesApplog.logDefault("Project", logtype: .debug, message: "Delete all sessions")
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
    class func purgeIfEmpty(_ project: Project, exceptSession session:Session) {
        UtilitiesApplog.logDefault("Project", logtype: .enterExit, message: "purgeIfEmpty(name=\(project.name))")
        if project.sessions.count==0 || (project.sessions.count==1 && project.sessions.contains(session)) {
            Project.deleteObjectOnly(project)
            UtilitiesApplog.logDefault("Project", logtype: .enterExit, message: "Project deleted because none or only 1 specific session left.")
        } else {
            UtilitiesApplog.logDefault("Project", logtype: .enterExit, message: "Project not deleted, \(project.sessions.count) sessions left.")
        }
    }

    //---------------------------------------------
    // Project - addSession (internal use only)
    //---------------------------------------------

    func addSession(_ session: Session) {
        UtilitiesApplog.logDefault("Project", logtype: .enterExit, message: "addSession(name=\(name), session=\(session.name))")
        let s = self.sessions.mutableCopy() as! NSMutableOrderedSet
        s.add(session)
        self.sessions = s
    }


}
