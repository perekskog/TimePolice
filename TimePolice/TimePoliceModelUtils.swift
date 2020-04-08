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

    class func save(_ moc: NSManagedObjectContext) {
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

    class func getSessionTasks(_ session: Session) -> String {
        var s = "\(session.name)-\(UtilitiesDate.getString(session.created))\n"
        let summary = session.getSessionTaskSummary(false)
        for task in session.tasks.array as! [Task] {
            if task.name != spacerName {
                var time: TimeInterval = 0
                if let (_, t) = summary[task] {
                    time = t
                }
                s += "\(task.name)\t\(UtilitiesDate.getString(time))\n"
            }
        }
        return s
    }


    //---------------------------------------------
    // TimePoliceModelUtils - getSessionTaskEntry
    //---------------------------------------------

    class func getSessionTaskEntries(_ session: Session) -> String {

        var s: String

        s = "Current Session:\n"
        s += "S: \(session.name) @ \(UtilitiesDate.getString(session.created))\n"
        s += "    P: \(session.project.name) @ \(UtilitiesDate.getString(session.project.created))\n"
        session.taskEntries.enumerateObjects({ (elem, idx, stop) -> Void in
            let taskEntry = elem as! TaskEntry
            if taskEntry.isStopped() {
                let timeForTaskEntry = taskEntry.stopTime.timeIntervalSince(taskEntry.startTime)
                s += "    TE: \(taskEntry.task.name) \(UtilitiesDate.getString(taskEntry.startTime))->\(UtilitiesDate.getStringNoDate(taskEntry.stopTime)) = \(UtilitiesDate.getString(timeForTaskEntry))\n"
            } else {
                s += "    TE: \(taskEntry.task.name) \(UtilitiesDate.getString(taskEntry.startTime))->(ongoing) = ------\n"
            }
        })

        return s
    }

    //---------------------------------------------
    // TimePoliceModelUtils - storeTemplate
    //---------------------------------------------

    class func storeTemplate(_ moc: NSManagedObjectContext, reuseTasksFromProject: String, session: (String, String, [String: String]), tasks: [(String, [String: String])], src: String) {

        UtilitiesApplog.logDefault("TimePoliceModelUtils", logtype: .enterExit, message: "storeTemplate(reuseTasksFromProject=\(reuseTasksFromProject),src=\(src))")

        defer {
            TimePoliceModelUtils.save(moc)
        }
        // Find template project, or create it if it does not already exist
        var templateProject: Project
        guard let projects = Project.findInMOC(moc, name: templateProjectName) else {
            UtilitiesApplog.logDefault("TimePoliceModelUtils", logtype: .guard, message: "storeTemplate(Templates)")
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
                    _ = Task.createInMOC(moc, name: newTaskName, properties: mergedProperties, session: newTemplateSession)
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
                                if (session as AnyObject).name == sessionName {
                                    for task in (session as! Session).tasks {
                                        if !found && (task as AnyObject).name == newTaskName {
                                            found = true
                                            if let t = task as? Task {
                                                t.properties = mergedProperties as NSObject
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
                                    if !found && (task as AnyObject).name == newTaskName {
                                        found = true
                                        if let t = task as? Task {
                                            t.properties = mergedProperties as NSObject
                                            newTemplateSession.addTask(t)
                                        }
                                    }
                                }
                                // Second, search among TaskEntries
                                // It might be that there is a TaskEntry since long before
                                // but the corresponding Task is not part of the session.
                                for taskEntry in (session as! Session).taskEntries {
                                    if !found && (taskEntry as AnyObject).task.name == newTaskName {
                                        found = true
                                        if let te = taskEntry as? TaskEntry {
                                            te.task.properties = mergedProperties as NSObject
                                            newTemplateSession.addTask(te.task)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    // Only create task if it could not be reused
                    if !found {
                        _ = Task.createInMOC(moc, name: newTaskName, properties: mergedProperties, session: newTemplateSession)
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

    class func cloneSession(_ moc: NSManagedObjectContext, projectName: String, sessionName: String, sessionVersion: String) {

        UtilitiesApplog.logDefault("TimePoliceModelUtils", logtype: .enterExit, 
            message: "cloneSession(projectName=\(projectName), sessionName=\(sessionName), sessionVersion=\(sessionVersion))")
        defer {
            TimePoliceModelUtils.save(moc)
        }
        // Find template project (must exist)
        guard let templateProjects = Project.findInMOC(moc, name: templateProjectName) else {
            UtilitiesApplog.logDefault("TimePoliceModelUtils", logtype: .guard, message: "cloneSession(Templates)")
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
            if (s as AnyObject).name == sessionName && (s as AnyObject).version == sessionVersion {
                templateSession = (s as! Session)
                found = true
            }
        }
        if !found {
           return
        }

        // Find project, or create it if it does not already exist
        var project: Project
        guard let projects = Project.findInMOC(moc, name: projectName) else {
            UtilitiesApplog.logDefault("TimePoliceModelUtils", logtype: .guard, message: "cloneSession(Project)")
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

    class func getGap2TaskEntry(_ taskEntryList: [TaskEntry]) -> [Int] {
        if taskEntryList.count == 0 {
            return []
        }
        // First entry is never a gap
        var gap2TaskEntry: [Int] = [0]

        // If there are more than one element: Go through entire list
        if taskEntryList.count > 1 {
            var previousTaskEntry = taskEntryList[0]
            for i in 1...taskEntryList.count-1 {
                let te = taskEntryList[i]
//                UtilitiesApplog.logDefault("TimePoliceModelUtils", logtype: .Debug, message: "Prev=\(previousTaskEntry.id), stop=\(previousTaskEntry.stopTime)")
//                UtilitiesApplog.logDefault("TimePoliceModelUtils", logtype: .Debug, message: "Curr=\(te.id), start=\(te.startTime)")
//                if te.startTime.isEqualToDate(previousTaskEntry.stopTime) {
                if te.startTime.timeIntervalSince(previousTaskEntry.stopTime) < 0.5 {
                    // No gap
                } else {
                    let diff = te.startTime.timeIntervalSince(previousTaskEntry.stopTime)
                    UtilitiesApplog.logDefault("TimePoliceModelUtils", logtype: .debug, message: "(gap=\(diff))")
                    gap2TaskEntry.append(-1)
                }
                previousTaskEntry = te
                gap2TaskEntry.append(i)
            }
        }

        return gap2TaskEntry
    }



    //---------------------------------------------
    // TimePoliceModelUtils - verifyConstraints
    //---------------------------------------------

    class func verifyConstraints(_ moc: NSManagedObjectContext) -> (Bool, String) {
        if coreDataIsConsistent == false {
            UtilitiesApplog.logDefault("TimePoliceModelUtils", logtype: .debug, message: "Core Data is inconsistent - no more checks until restart")
            return (false, "")
        }

        UtilitiesApplog.logDefault("TimePoliceModelUtils", logtype: .debug, message: "Check for Core Data consistency")

        var fetchRequest: NSFetchRequest<NSFetchRequestResult>

        do {
            fetchRequest = NSFetchRequest(entityName: "Project")
            if let fetchResults = try moc.fetch(fetchRequest) as? [Project] {
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
            if let fetchResults = try moc.fetch(fetchRequest) as? [Task] {
                for task in fetchResults {
                    if task.sessions.count==0 && task.taskEntries.count==0 {
                        coreDataIsConsistent = false
                        return (true, "Task \(task.id) has no taskentry and no session")
                    }
                }
            }
        
        } catch {
            print("Can't fetch tasks")
        }

        return (false, "")
    }

    class func getConsistencyAlert(_ alertMessage: String, moc: NSManagedObjectContext) -> UIAlertController {

        let alertContoller = UIAlertController(title: "Consistency check failed", message: alertMessage,
            preferredStyle: .alert)
        
        let dumpCoreDataAction = UIAlertAction(title: "Export data structures", style: .default,
            handler: { action in
                let s = MainExportVC.dumpAllData(moc)
                print(s)
                UIPasteboard.general.string = s
            })
        alertContoller.addAction(dumpCoreDataAction)
        
        let repairCoreDataAction = UIAlertAction(title: "Repair data structures", style: .default,
            handler: { action in
                self.repairDataStructures(moc)
                TimePoliceModelUtils.save(moc)
            })
        alertContoller.addAction(repairCoreDataAction)
        
        let dumpAndRepairCoreDataAction = UIAlertAction(title: "Export and repair", style: .default,
            handler: { action in
                let s = MainExportVC.dumpAllData(moc)
                print(s)
                UIPasteboard.general.string = s
                self.repairDataStructures(moc)
                TimePoliceModelUtils.save(moc)
            })
        alertContoller.addAction(dumpAndRepairCoreDataAction)
        
        let okAction = UIAlertAction(title: "Just continue", style: .default,
            handler: nil)
        alertContoller.addAction(okAction)
        
        return alertContoller

    }

    class func repairDataStructures(_ moc: NSManagedObjectContext) {
        UtilitiesApplog.logDefault("TimePoliceModelUtils", logtype: .debug, message: "Repair data structures")

        var fetchRequest: NSFetchRequest<NSFetchRequestResult>

        do {
            fetchRequest = NSFetchRequest(entityName: "Project")
            if let fetchResults = try moc.fetch(fetchRequest) as? [Project] {
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
            if let fetchResults = try moc.fetch(fetchRequest) as? [Task] {
                for task in fetchResults {
                    if task.sessions.count==0 && task.taskEntries.count==0 {
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



