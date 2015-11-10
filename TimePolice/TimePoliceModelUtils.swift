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

/*  TODO

? TestData
    Update according to relation maintaining methods

- Missing: AppLog
  Or perhaps throw some errors?

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
    // TimePoliceModelUtils - clearAllData
    //---------------------------------------------

    class func clearAllData(moc: NSManagedObjectContext) {
        var fetchRequest: NSFetchRequest

        do {
            // Delete all work
            fetchRequest = NSFetchRequest(entityName: "Work")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Work] {
                for work in fetchResults {
                    moc.deleteObject(work)
                }
            }
        } catch {
            print("Can't fetch work for deletion")
        }
        
        do {
            // Delete all tasks
            fetchRequest = NSFetchRequest(entityName: "Task")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Task] {
                for task in fetchResults {
                    moc.deleteObject(task)
                }
            }
        } catch {
            print("Can't fetch tasks for deletion")
        }
        
        do {
            // Delete all sessions
            fetchRequest = NSFetchRequest(entityName: "Session")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Session] {
                for session in fetchResults {
                    moc.deleteObject(session)
                }
            }
        } catch {
            print("Can't fetch sessions for deletion")
        }
        
        do {
            // Delete all projects
            fetchRequest = NSFetchRequest(entityName: "Project")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Project] {
                for project in fetchResults {
                    moc.deleteObject(project)
                }
            }
        } catch {
            print("Can't fetch projects for deletion")
        }
    }

    //---------------------------------------------
    // TimePoliceModelUtils - dumpAllData
    //---------------------------------------------

    class func dumpAllData(moc: NSManagedObjectContext) -> String {
        var fetchRequest: NSFetchRequest
        var s: String
        
        do {
            s = ("---------------------------\n")
            s += ("----------Project----------\n\n")
            fetchRequest = NSFetchRequest(entityName: "Project")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Project] {
                s += "[Project container size=\(fetchResults.count)]\n"
                for project in fetchResults {
                    s += ("P: \(project.name) @ \(UtilitiesDate.getString(project.created))\n")
                    for (key, value) in project.properties as! [String: String] {
                        s += "[\(key)]=[\(value)]\n"
                    }
                    s += "    [Session container size=\(project.sessions.count)]\n"
                    for session in project.sessions {
                        s += "    S: \(session.name) @ \(UtilitiesDate.getString(session.created))\n"
                    }
                }
            }
        } catch {
            print("Can't fetch projects")
        }

        do {
            s += "\n"
            s += ("---------------------------\n")
            s += ("----------Session----------\n\n")
            fetchRequest = NSFetchRequest(entityName: "Session")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Session] {
                s += "[Session container size=\(fetchResults.count)]\n"
                for session in fetchResults {
                    s += ("S: \(session.name) @ \(UtilitiesDate.getString(session.created))\n")
                    for (key, value) in session.properties as! [String: String] {
                        s += "[\(key)]=[\(value)]\n"
                    }
                    s += ("    P: \(session.project.name) @ \(UtilitiesDate.getString(session.project.created))\n")
                    s += "    [Work container size=\(session.work.count)]\n"
                    session.work.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
                        let work = elem as! Work
                        if work.isStopped() {
                            let timeForWork = work.stopTime.timeIntervalSinceDate(work.startTime)
                            s += "    W: \(work.task.name) \(UtilitiesDate.getString(work.startTime))->\(UtilitiesDate.getStringNoDate(work.stopTime)) = \(UtilitiesDate.getString(timeForWork))\n"
                        } else {
                            s += "    W: \(work.task.name) \(UtilitiesDate.getString(work.startTime))->(ongoing) = ------\n"
                        }
                    }
                    s += "    [Task container size=\(session.tasks.count)]\n"
                    session.tasks.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
                        let task = elem as! Task
                        s += ("    T: \(task.name)\n")
                    }
                }
            }
        } catch {
            print("Can't fetch sessions")
        }
        
        
        do {
            s += "\n"
            s += ("------------------------\n")
            s += ("----------Work----------\n\n")
            fetchRequest = NSFetchRequest(entityName: "Work")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Work] {
                s += "[Work container size=\(fetchResults.count)]\n"
                for work in fetchResults {
                    if work.isStopped() {
                        let timeForWork = work.stopTime.timeIntervalSinceDate(work.startTime)
                        s += "W: \(work.task.name) \(UtilitiesDate.getString(work.startTime))->\(UtilitiesDate.getStringNoDate(work.stopTime)) = \(UtilitiesDate.getString(timeForWork))\n"
                    } else {
                        s += "W: \(work.task.name) \(UtilitiesDate.getString(work.startTime))->(ongoing) = ------\n"
                    }
                    for (key, value) in work.properties as! [String: String] {
                        s += "[\(key)]=[\(value)]\n"
                    }
                    s += "    S: \(work.session.name) @ \(UtilitiesDate.getString(work.session.created))\n"
                    s += "    T: \(work.task.name) @ \(UtilitiesDate.getString(work.task.created))\n"
                }
            }
        } catch {
            print("Can't fetch work")
        }
        
        do {
            s += "\n"
            s += ("------------------------\n")
            s += ("----------Task----------\n\n")
            fetchRequest = NSFetchRequest(entityName: "Task")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Task] {
                s += "[Task container size=\(fetchResults.count)]\n"
                for task in fetchResults {
                    s += ("T: \(task.name) @ \(UtilitiesDate.getString(task.created))\n")
                    for (key, value) in task.properties as! [String: String] {
                        s += "[\(key)]=[\(value)]\n"
                    }
                    s += "    [Session container size=\(task.sessions.count)]\n"
                    for session in task.sessions {
                        s += ("    S: \(session.name) @ \(UtilitiesDate.getString(session.created))\n")
                    }
                    s += "    [Work container size=\(task.work.count)]\n"
                    task.work.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
                        let work = elem as! Work
                        if work.isStopped() {
                            let timeForWork = work.stopTime.timeIntervalSinceDate(work.startTime)
                            s += "    W: \(work.task.name) \(UtilitiesDate.getString(work.startTime))->\(UtilitiesDate.getStringNoDate(work.stopTime)) = \(UtilitiesDate.getString(timeForWork))\n"
                        } else {
                            s += "    W: \(work.task.name) \(UtilitiesDate.getString(work.startTime))->(ongoing) = ------\n"
                        }
                    }
                }
            }
        
        } catch {
            print("Can't fetch tasks")
        }

        return s
    }

    //---------------------------------------------
    // TimePoliceModelUtils - getSessionTasks
    //---------------------------------------------

    class func getSessionTasks(session: Session) -> String {
        var s = "\(session.name)-\(UtilitiesDate.getString(session.created))\n"
        let summary = session.getSessionTaskSummary()
        for task in session.tasks.array as! [Task] {
            let withoutComment = task.name
            if withoutComment != "" {
                var time: NSTimeInterval = 0
                if let (_, t) = summary[task] {
                    time = t
                }
                s += "\(withoutComment)\t\(UtilitiesDate.getString(time))\n"
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

}

//=======================================================================================
//=======================================================================================
//  TestData
//=======================================================================================

class TestData {

    //---------------------------------------------
    // TestData - addSession
    //---------------------------------------------

    class func addSession(moc: NSManagedObjectContext, projectName: String, sessionTemplateName: String, sessionTemplateTasks: [String], sessionName: String) {
        var project: Project
        var projectTemplate: Project
        var session: Session
        var taskList: [Task] = []

        guard let projects1 = Project.findInMOC(moc, name: "Templates") else {
            UtilitiesApplog.logDefault("TestData", logtype: .Guard, message: "addSession(Templates)")
            return
        }
        if projects1.count > 0 {
                projectTemplate = projects1[0]
        } else {
                projectTemplate = Project.createInMOC(moc, name: "Templates")
        }

        guard let projects2 = Project.findInMOC(moc, name: projectName) else {
            UtilitiesApplog.logDefault("TestData", logtype: .Guard, message: "addSession(\(projectName))")
            return
        }
        if projects2.count > 0 {
            project = projects2[0]
        } else {
            project = Project.createInMOC(moc, name: projectName)
        }
        
        guard let sessions = Session.findInMOC(moc, name: sessionTemplateName) else {
            UtilitiesApplog.logDefault("TestData", logtype: .Guard, message: "addSession(\(sessionTemplateName))")
            return
        }
        if sessions.count > 0 {
            let sessionTemplate = sessions[0] as Session
            taskList = sessionTemplate.tasks.array as! [Task]
        } else {
            let sessionTemplate = Session.createInMOC(moc, name: sessionTemplateName, project: projectTemplate)
            for taskName in sessionTemplateTasks {
                let task = Task.createInMOC(moc, name: taskName, session: sessionTemplate)
                taskList.append(task)
            }
            taskList = sessionTemplate.tasks.array as! [Task]
        }

        session = Session.createInMOC(moc, name: "\(sessionName)", project: project)

        session.addTasks(taskList)
    }

    //---------------------------------------------
    // TestData - addSessionToHome
    //---------------------------------------------

    class func addSessionToPrivate(moc: NSManagedObjectContext) {
        // 24
        let taskList =  [
            "RC#color=4c4", "Dev#color=4c4", "Media#color=4c4",
            "Läsa/Titta#color=4c4", "Div hemma#color=4c4", "Div borta#color=4c4",
            "Fysiskt#color=4c4", "Time in#color=4c4", "Relationer#color=4c4",
            "Lek#color=4c4", "Down#color=4c4", "Pers. utv#color=4c4",
            
            "Person#color=44f", "Hem#color=44f", "Hus/tomt#color=44f",
            "Bil#color=44f", "Behöver div#color=44f", "",
                        
            "Oaktivitet#color=bbb", "", "",
            
            "Läsa/titta#color=b84", "", "",

            "Blockerad#color=b44", "Avbrott#color=b44", "",
            "Brand#color=b44", "Fokusskift#color=b44", ""
            
        ]

        let date = NSDate()
        addSession(moc, projectName: "Privat", 
            sessionTemplateName: "Template - Privat", 
            sessionTemplateTasks: taskList, 
            sessionName: "Privat \(UtilitiesDate.getStringOnlyDay(date))")
    }

    //---------------------------------------------
    // TestData - addSessionToWork
    //---------------------------------------------

    class func addSessionToWork(moc: NSManagedObjectContext) {
        // 27
        let taskList = [
            "Dev#color=4c4", "PPO#color=4c4", "Stage 7#color=4c4",

            "Fysiskt#color=4c4", "Time in#color=4c4", "Relationer#color=4c4",
            "Lek#color=4c4", "Down#color=4c4", "Pers. utv#color=4c4",
            
            "Inbox#color=44f", "Pågående#color=44f", "Städa upp#color=44f",
            "Team#color=44f", "Adm#color=44f", "Annat#color=44f",
            
            "Oaktivitet#color=bbb", "", "",

            "Läsa/titta#color=b84", "", "",

            "Blockerad#color=b44", "Avbrott#color=b44", "",
            "Brand#color=b44", "Fokusskift#color=b44", "",
        ]

        let date = NSDate()
        addSession(moc, projectName: "Jobb", 
            sessionTemplateName: "Template - Jobb", 
            sessionTemplateTasks: taskList, 
            sessionName: "Jobb \(UtilitiesDate.getStringOnlyDay(date))")
    }
    
    //---------------------------------------------
    // TestData - addSessionToDaytime
    //---------------------------------------------

    class func addSessionToDaytime(moc: NSManagedObjectContext) {
        // 21
        let taskList = [
            "Hemma", "Hemma ute", "Sova",
            
            "Jobb", "Jobb ute", "Lunch",
                
            "Bil morgon", "Bil kväll", "",
            "P morgon", "P kväll", "",
            "T morgon", "T kväll", "",
            "B morgon", "B kväll", "",

            "Ärende", "F&S", "Annat"
        ]

        let date = NSDate()
        addSession(moc, projectName: "Ett dygn", 
            sessionTemplateName: "Template - Ett dygn", 
            sessionTemplateTasks: taskList, 
            sessionName: "Ett dygn \(UtilitiesDate.getStringOnlyDay(date))")
    }

    //---------------------------------------------
    // TestData - addSessionToCost
    //---------------------------------------------
    
    class func addSessionToCost(moc: NSManagedObjectContext) {
        let taskList = [
            "Comp 16A", "Comp 16B", "", "",
            "Maint", "SM Yearly", "", "",
            
            "Alfa", "Bravo", "Charlie",
            "Delta", "Echo", "Foxtrot",
            "Golf", "Hotel", "India",
            "Juliet", "Kilo", "Lima",
            "Mike", "November", "Oscar",
            "Papa", "Quebeq", "Romeo",
            "Sierra", "Tango", "Uniform",
            "Victor", "Whiskey", "X-ray",
            "Yankee", "Zulu"
        ]
        
        let date = NSDate()
        addSession(moc, projectName: "Cost", 
            sessionTemplateName: "Template - Cost", 
            sessionTemplateTasks: taskList, 
            sessionName: "Cost \(UtilitiesDate.getStringOnlyDay(date))")
    }

    //---------------------------------------------
    // TestData - addSessionToTest
    //---------------------------------------------
    
    class func addSessionToTest(moc: NSManagedObjectContext) {
        // 6
        let taskList = [
            "", "Bertil#color=8f8,x=bertil", "Ceasar#color=88f,x=ceasar",
            
            "", "Tvåa#color=0f0", "Trea#color=00f"
        ]

        let date = NSDate()
        addSession(moc, projectName: "Test", 
            sessionTemplateName: "Template - Test", 
            sessionTemplateTasks: taskList, 
            sessionName: "Test \(UtilitiesDate.getStringWithFormat(date, format: "ddss"))")
    }

}


