//
//  TimePoliceModel.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-02-03.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

import Foundation
import CoreData
import UIKit

/*  
TODO:

*/




//=======================================================================================
//=======================================================================================
//  TimePoliceModelUtils
//=======================================================================================

class TimePoliceModelUtils {

    //---------------------------------------------
    // TimePoliceModelUtils - save
    //---------------------------------------------

    class func save(moc: NSManagedObjectContext) {
        do {
            try moc.save()
            print("Save: ok")
        } catch {
            print("Save: error")
            // Swift 2: Where to get the error?
        }

    }


    //---------------------------------------------
    // TimePoliceModelUtils - getSessionTasks
    //---------------------------------------------

    class func getSessionTasks(session: Session) -> String {
        var s = "\(session.name)-\(UtilitiesDate.getString(session.created))\n"
        let summary = session.getSessionTaskSummary(false)
        for task in session.tasks.array as! [Task] {
            if task.name != spacerName {
                var time: NSTimeInterval = 0
                if let (_, t) = summary[task] {
                    time = t
                }
                s += "\(task.name)\t\(UtilitiesDate.getString(time))\n"
            }
        }
        return s
    }


    //---------------------------------------------
    // TimePoliceModelUtils - getSessionWork
    //---------------------------------------------

    class func getSessionWork(session: Session) -> String {

        var s: String

        s = "Current Session:\n"
        s += "S: \(session.name) @ \(UtilitiesDate.getString(session.created))\n"
        s += "    P: \(session.project.name) @ \(UtilitiesDate.getString(session.project.created))\n"
        session.work.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
            let work = elem as! Work
            if work.isStopped() {
                let timeForWork = work.stopTime.timeIntervalSinceDate(work.startTime)
                s += "    W: \(work.task.name) \(UtilitiesDate.getString(work.startTime))->\(UtilitiesDate.getStringNoDate(work.stopTime)) = \(UtilitiesDate.getString(timeForWork))\n"
            } else {
                s += "    W: \(work.task.name) \(UtilitiesDate.getString(work.startTime))->(ongoing) = ------\n"
            }
        }

        return s
    }

    //---------------------------------------------
    // TimePoliceModelUtils - storeTemplate
    //---------------------------------------------

    class func storeTemplate(moc: NSManagedObjectContext, reuseTasksFromProject: String, session: (String, String, [String: String]), tasks: [(String, [String: String])], src: String) {

        UtilitiesApplog.logDefault("TimePoliceModelUtils", logtype: .EnterExit, message: "storeTemplate(reuseTasksFromProject=\(reuseTasksFromProject),src=\(src))")

        defer {
            TimePoliceModelUtils.save(moc)
        }
        // Find template project, or create it if it does not already exist
        var templateProject: Project
        guard let projects = Project.findInMOC(moc, name: templateProjectName) else {
            UtilitiesApplog.logDefault("TimePoliceModelUtils", logtype: .Guard, message: "storeTemplate(Templates)")
            return
        }
        if projects.count > 0 {
            templateProject = projects[0]
        } else {
            templateProject = Project.createInMOC(moc, name: templateProjectName)
        }
        
        // Find session template to replace, or create it if it does not already exist in template project
        var oldTemplateSession: Session?
        let (sessionName, sessionVersion, sessionProps) = session
        let oldSessionVersion = sessionVersion
        for item in templateProject.sessions {
            if let s = item as? Session {
                let version = s.version
                if s.name == "\(sessionName)" && oldSessionVersion == version {
                    oldTemplateSession = s
                }
            }
        }
        
        let newTemplateSession = Session.createInMOC(moc, name: "\(sessionName)", version: sessionVersion, properties: sessionProps, project: templateProject, src: src)

        var defaultProperties = [String: String]()

        for (newTaskName, newTaskProperties) in tasks {
            if newTaskName == "=" {
                defaultProperties = newTaskProperties
            } else {
                var mergedProperties = defaultProperties
                for (key,value) in newTaskProperties {
                    mergedProperties[key] = value
                }

                // Always create new spacers
                if newTaskName == spacerName {
                    Task.createInMOC(moc, name: newTaskName, properties: mergedProperties, session: newTemplateSession)
                } else {

                    // Retain old task, otherwise create new task
                    var found = false

/*
                    // First, search among the tasks in the old template
                    if oldTemplateSession != nil {
                        for task in (oldTemplateSession?.tasks)! {
                            if !found && task.name == newTaskName {
                                found = true
                                if let t = task as? Task {
                                    t.properties = mergedProperties
                                    newTemplateSession.addTask(t)
                                }
                            }
                        }
                    }
*/
                    // First, search among all versions of this project

                    if let projects = Project.findInMOC(moc, name: templateProjectName) {
                        if projects.count > 0 {
                            let project = projects[0]

                            for session in project.sessions {
                                // Search among tasks in all existing versions
                                if session.name == sessionName {
                                    for task in (session as! Session).tasks {
                                        if !found && task.name == newTaskName {
                                            found = true
                                            if let t = task as? Task {
                                                t.properties = mergedProperties
                                                newTemplateSession.addTask(t)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }


                    // Second, search in project
                    // (A task might have been used some time ago)

                    if let projects = Project.findInMOC(moc, name: reuseTasksFromProject) {
                        if projects.count > 0 {
                            let project = projects[0]

                            for session in project.sessions {
                                // First, search among tasks
                                for task in (session as! Session).tasks {
                                    if !found && task.name == newTaskName {
                                        found = true
                                        if let t = task as? Task {
                                            t.properties = mergedProperties
                                            newTemplateSession.addTask(t)
                                        }
                                    }
                                }
                                // Second, search among TaskEntries
                                // It might be that there is a TaskEntry since long before
                                // but the corresponding Task is not part of the session.
                                for work in (session as! Session).work {
                                    if !found && work.task.name == newTaskName {
                                        found = true
                                        if let w = work as? Work {
                                            w.task.properties = mergedProperties
                                            newTemplateSession.addTask(w.task)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    // Only create task if it could not be reused
                    if !found {
                        Task.createInMOC(moc, name: newTaskName, properties: mergedProperties, session: newTemplateSession)
                    }
                }
            }
        }

        // Delete old template session
        if oldTemplateSession != nil {
            Session.deleteObject(oldTemplateSession!)
        }
        
    }
    
    //---------------------------------------------
    // TimePoliceModelUtils - cloneSession
    //---------------------------------------------

    class func cloneSession(moc: NSManagedObjectContext, projectName: String, sessionName: String, sessionVersion: String) {

        UtilitiesApplog.logDefault("TimePoliceModelUtils", logtype: .EnterExit, 
            message: "cloneSession(projectName=\(projectName), sessionName=\(sessionName), sessionVersion=\(sessionVersion))")
        defer {
            TimePoliceModelUtils.save(moc)
        }
        // Find template project (must exist)
        guard let templateProjects = Project.findInMOC(moc, name: templateProjectName) else {
            UtilitiesApplog.logDefault("TimePoliceModelUtils", logtype: .Guard, message: "cloneSession(Templates)")
            return
        }
        guard templateProjects.count > 0 else {
            return
        } 
        let templateProject = templateProjects[0]

        // Find template session (must exist)
        // Create session template if it does not already exist in template project
        var templateSession: Session!
        var found = false
        for s in templateProject.sessions {
            if s.name == sessionName && s.version == sessionVersion {
                templateSession = s as! Session
                found = true
            }
        }
        if !found {
           return
        }

        // Find project, or create it if it does not already exist
        var project: Project
        guard let projects = Project.findInMOC(moc, name: projectName) else {
            UtilitiesApplog.logDefault("TimePoliceModelUtils", logtype: .Guard, message: "cloneSession(Project)")
            return
        }
        if projects.count > 0 {
            project = projects[0]
        } else {
            project = Project.createInMOC(moc, name: projectName)
        }

        if let p = templateSession.properties as? [String: String] {
            // Create new session
            let session = Session.createInMOC(moc,
    name: sessionName, version: sessionVersion, properties: p, project: project, src: templateSession.src)

            // Add tasks from template to new session
            if let t = templateSession.tasks.array as? [Task] {
                session.addTasks(t)
            }
        }
    }

    class func getGap2Work(workList: [Work]) -> [Int] {
        if workList.count == 0 {
            return []
        }
        // First entry is never a gap
        var gap2Work: [Int] = [0]

        // If there are more than one element: Go through entire list
        if workList.count > 1 {
            var previousTaskEntry = workList[0]
            for i in 1...workList.count-1 {
                let te = workList[i]
//                UtilitiesApplog.logDefault("TimePoliceModelUtils", logtype: .Debug, message: "Prev=\(previousTaskEntry.id), stop=\(previousTaskEntry.stopTime)")
//                UtilitiesApplog.logDefault("TimePoliceModelUtils", logtype: .Debug, message: "Curr=\(te.id), start=\(te.startTime)")
//                if te.startTime.isEqualToDate(previousTaskEntry.stopTime) {
                if te.startTime.timeIntervalSinceDate(previousTaskEntry.stopTime) < 0.5 {
                    // No gap
                } else {
                    let diff = te.startTime.timeIntervalSinceDate(previousTaskEntry.stopTime)
                    UtilitiesApplog.logDefault("TimePoliceModelUtils", logtype: .Debug, message: "(gap=\(diff))")
                    gap2Work.append(-1)
                }
                previousTaskEntry = te
                gap2Work.append(i)
            }
        }

        return gap2Work
    }



    //---------------------------------------------
    // TimePoliceModelUtils - verifyConstraints
    //---------------------------------------------

    class func verifyConstraints(moc: NSManagedObjectContext) -> (Bool, String) {
        if coreDataIsConsistent == false {
            UtilitiesApplog.logDefault("TimePoliceModelUtils", logtype: .Debug, message: "Core Data is inconsistent - no more checks until restart")
            return (false, "")
        }

        UtilitiesApplog.logDefault("TimePoliceModelUtils", logtype: .Debug, message: "Check for Core Data consistency")

        var fetchRequest: NSFetchRequest

        do {
            fetchRequest = NSFetchRequest(entityName: "Project")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Project] {
                for project in fetchResults {
                    if project.sessions.count==0 {
                        coreDataIsConsistent = false
                        return (true, "Project \(project.id) has no session")
                    }
                }
            }
        } catch {
            print("Can't fetch projects")
        }

        do {
            fetchRequest = NSFetchRequest(entityName: "Task")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Task] {
                for task in fetchResults {
                    if task.sessions.count==0 && task.work.count==0 {
                        coreDataIsConsistent = false
                        return (true, "Task \(task.id) has no work and no session")
                    }
                }
            }
        
        } catch {
            print("Can't fetch tasks")
        }

        return (false, "")
    }

    class func getConsistencyAlert(alertMessage: String, moc: NSManagedObjectContext) -> UIAlertController {

        let alertContoller = UIAlertController(title: "Consistency check failed", message: alertMessage,
            preferredStyle: .Alert)
        
        let dumpCoreDataAction = UIAlertAction(title: "Export data structures", style: .Default,
            handler: { action in
                let s = MainExportVC.dumpAllData(moc)
                print(s)
                UIPasteboard.generalPasteboard().string = s
            })
        alertContoller.addAction(dumpCoreDataAction)
        
        let repairCoreDataAction = UIAlertAction(title: "Repair data structures", style: .Default,
            handler: { action in
                self.repairDataStructures(moc)
                TimePoliceModelUtils.save(moc)
            })
        alertContoller.addAction(repairCoreDataAction)
        
        let dumpAndRepairCoreDataAction = UIAlertAction(title: "Export and repair", style: .Default,
            handler: { action in
                let s = MainExportVC.dumpAllData(moc)
                print(s)
                UIPasteboard.generalPasteboard().string = s
                self.repairDataStructures(moc)
                TimePoliceModelUtils.save(moc)
            })
        alertContoller.addAction(dumpAndRepairCoreDataAction)
        
        let okAction = UIAlertAction(title: "Just continue", style: .Default,
            handler: nil)
        alertContoller.addAction(okAction)
        
        return alertContoller

    }

    class func repairDataStructures(moc: NSManagedObjectContext) {
        UtilitiesApplog.logDefault("TimePoliceModelUtils", logtype: .Debug, message: "Repair data structures")

        var fetchRequest: NSFetchRequest

        do {
            fetchRequest = NSFetchRequest(entityName: "Project")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Project] {
                for project in fetchResults {
                    if project.sessions.count==0 {
                        Project.deleteObjectOnly(project)
                    }
                }
            }
        } catch {
            print("Can't fetch projects")
        }

        do {
            fetchRequest = NSFetchRequest(entityName: "Task")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Task] {
                for task in fetchResults {
                    if task.sessions.count==0 && task.work.count==0 {
                        Task.deleteObjectOnly(task)
                    }
                }
            }
        
        } catch {
            print("Can't fetch tasks")
        }

        coreDataIsConsistent = true

    }

}



