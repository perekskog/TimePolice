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

    class func storeTemplate(moc: NSManagedObjectContext, reuseTasksFromProject: String, session: (String, [String: String]), tasks: [(String, [String: String])], src: String) {

        defer {
            TimePoliceModelUtils.save(moc)
        }
        // Find template project, or create it if it does not already exist
        var templateProject: Project
        guard let projects = Project.findInMOC(moc, name: "Templates") else {
            UtilitiesApplog.logDefault("TimePoliceModelUtils", logtype: .Guard, message: "storeTemplate(Templates)")
            return
        }
        if projects.count > 0 {
            templateProject = projects[0]
        } else {
            templateProject = Project.createInMOC(moc, name: "Templates")
        }
        
        // Find session template, or create it if it does not already exist in template project
        var oldTemplateSession: Session?
        let (sessionName, sessionProps) = session
        for s in templateProject.sessions {
            if s.name == "\(sessionName)" {
                oldTemplateSession = s as? Session
            }
        }
        
        let newTemplateSession = Session.createInMOC(moc, name: "\(sessionName)", properties: sessionProps, project: templateProject, src: src)

        var defaultProperties = [String: String]()

        for (newTaskName, newTaskProperties) in tasks {
            if newTaskName == "=" {
                defaultProperties = newTaskProperties
            } else {
                var mergedProperties = defaultProperties
                for (key,value) in newTaskProperties {
                    mergedProperties[key] = value
                }
                if newTaskName == spacerName {
                    Task.createInMOC(moc, name: newTaskName, properties: mergedProperties, session: newTemplateSession)
                } else {
                    // Retain old task, otherwise create new task
                    var found = false

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
                    // Second, search in project
                    // (A task might have been used some time ago)

                    if let projects = Project.findInMOC(moc, name: reuseTasksFromProject) {
                        if projects.count > 0 {
                            let project = projects[0]

                            for session in project.sessions {
                                // Forst, search among tasks
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

    class func cloneSession(moc: NSManagedObjectContext, projectName: String, sessionName: String) {

        defer {
            TimePoliceModelUtils.save(moc)
        }
        // Find template project (must exist)
        guard let templateProjects = Project.findInMOC(moc, name: "Templates") else {
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
            if s.name == "\(sessionName)" {
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
                name: sessionName, properties: p, project: project, src: templateSession.src)

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



}



