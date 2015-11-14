//
//  TestData.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-11-12.
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
//  TestData
//=======================================================================================

class TestData {

    //---------------------------------------------
    // TestData - storeTemplate
    //---------------------------------------------

    class func storeTemplate(moc: NSManagedObjectContext, project: String, session: (String, [String: String]), tasks: [(String, [String: String])]) {

        // Find template project, or create it if it does not already exist
        var templateProject: Project
        guard let projects = Project.findInMOC(moc, name: "Templates") else {
            UtilitiesApplog.logDefault("TestData", logtype: .Guard, message: "storeTemplate(Templates)")
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
            if s.name == "T-\(sessionName)" {
                oldTemplateSession = s as? Session
            }
        }
        
        let newTemplateSession = Session.createInMOC(moc, name: "T-\(sessionName)", properties: sessionProps, project: templateProject)

        var defaultProperties = [String: String]()

        for (newTaskName, newTaskProperties) in tasks {
            if newTaskName == "=" {
                defaultProperties = newTaskProperties
            } else {
                var properties = defaultProperties
                for (key,value) in newTaskProperties {
                    properties[key] = value
                }
                if newTaskName == "" {
                    Task.createInMOC(moc, name: newTaskName, properties: properties, session: newTemplateSession)
                } else {
                    // Retain old task, otherwise create new task
                    var found = false

                    // First, search among the tasks in the old template
                    if oldTemplateSession != nil {
                        for task in (oldTemplateSession?.tasks)! {
                            if !found && task.name == newTaskName {
                                found = true
                                newTemplateSession.addTask(task as! Task)
                            }
                        }
                    }
                    // Second, search in project
                    // (A task might have been used some time ago)

                    if let projects = Project.findInMOC(moc, name: project) {
                        if projects.count > 0 {
                            let project = projects[0]

                            for session in project.sessions {
                                for task in (session as! Session).tasks {
                                    if !found && task.name == newTaskName {
                                        found = true
                                        newTemplateSession.addTask(task as! Task)
                                    }
                                }
                            }
                        }
                    }
                    // Only create task if it could not be reused
                    if !found {
                        Task.createInMOC(moc, name: newTaskName, properties: properties, session: newTemplateSession)
                    }
                }
            }
        }

        // Delete old template session
        if oldTemplateSession != nil {
            Session.deleteInMOC(moc, session: oldTemplateSession!)
        }
        
    }
    
    //---------------------------------------------
    // TestData - cloneSession
    //---------------------------------------------

    class func cloneSession(moc: NSManagedObjectContext, projectName: String, sessionName: String) {

        // Find template project (must exist)
        guard let templateProjects = Project.findInMOC(moc, name: "Templates") else {
            UtilitiesApplog.logDefault("TestData", logtype: .Guard, message: "cloneSession(Templates)")
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
            if s.name == "T-\(sessionName)" {
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
            UtilitiesApplog.logDefault("TestData", logtype: .Guard, message: "cloneSession(Project)")
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
                name: sessionName, properties: p, project: project)

            // Add tasks from template to new session
            if let t = templateSession.tasks.array as? [Task] {
                session.addTasks(t)
            }
        }
    }


    //---------------------------------------------
    // TestData - addSessionToHome
    //---------------------------------------------

    class func addSessionToPrivate(moc: NSManagedObjectContext) {
        
        var s = "Privat#columns=3\n"
        s += "=#color=4c4\n"
        s += "RC\n"
        s += "Dev\n"
        s += "Media\n"
        s += "Läsa/titta\n"
        s += "Div hemma\n"
        s += "Div borta\n"
        s += "Fysiskt\n"
        s += "Time in\n"
        s += "Relationer\n"
        s += "Lek\n"
        s += "Down\n"
        s += "Pers. utv\n"
        s += "=#color=44f\n"
        s += "Person\n"
        s += "Hem\n"
        s += "Hus/tomt\n"
        s += "Bil\n"
        s += "Behöver div\n"
        s += "\n"
        s += "=#color=bbb\n"
        s += "Oaktivitet\n"
        s += "\n"
        s += "\n"
        s += "=#color=b84\n"
        s += "Slöläs/titta\n"
        s += "\n"
        s += "\n"
        s += "=#color=b44\n"
        s += "Blockerad\n"
        s += "Avbrott\n"
        s += "\n"
        s += "Brand\n"
        s += "Fokusskift\n"

        let st = SessionTemplate()
        st.parseTemplate(s)
        let (sessionName, _) = st.session
        storeTemplate(moc, project: sessionName, session: st.session, tasks: st.tasks)
        cloneSession(moc, projectName: sessionName, sessionName: sessionName)

    }

    //---------------------------------------------
    // TestData - addSessionToWork
    //---------------------------------------------

    class func addSessionToWork(moc: NSManagedObjectContext) {

        var s = "Jobb#columns=3\n"
        s += "=#color=4c4\n"
        s += "Dev\n"
        s += "SM\n"
        s += "Stage 7\n"
        s += "Fysiskt\n"
        s += "Time in\n"
        s += "Relationer\n"
        s += "Lek\n"
        s += "Down\n"
        s += "Pers. utv\n"
        s += "=#color=44f\n"
        s += "Inbox\n"
        s += "Pågående\n"
        s += "Städa upp\n"
        s += "Team\n"
        s += "Adm\n"
        s += "Annat\n"
        s += "=#color=bbb\n"
        s += "Oaktivitet\n"
        s += "\n"
        s += "\n"
        s += "=#color=b84\n"
        s += "Läsa/titta\n"
        s += "\n"
        s += "\n"
        s += "=#color=b44\n"
        s += "Blockerad\n"
        s += "Avbrott\n"
        s += "\n"
        s += "Brand\n"
        s += "Foskusskifte\n"

        let st = SessionTemplate()
        st.parseTemplate(s)
        let (sessionName, _) = st.session
        storeTemplate(moc, project: sessionName, session: st.session, tasks: st.tasks)
        cloneSession(moc, projectName: sessionName, sessionName: sessionName)
    }
    
    //---------------------------------------------
    // TestData - addSessionToDaytime
    //---------------------------------------------

    class func addSessionToDaytime(moc: NSManagedObjectContext) {

        var s = "Ett dygn#columns=3\n"
        s += "Hemma\n"
        s += "Hemma ute\n"
        s += "Sova\n"
        s += "Jobb\n"
        s += "Jobb ute\n"
        s += "Lunch\n"
        s += "Bil mrg\n"
        s += "Bil kv\n"
        s += "\n"
        s += "Pendel mrg\n"
        s += "Pendel kv\n"
        s += "\n"
        s += "Tbana mrg\n"
        s += "Tbana kv\n"
        s += "\n"
        s += "Buss mrg\n"
        s += "Buss kv\n"
        s += "\n"
        s += "Ärende\n"
        s += "F&S\n"
        s += "Annat"

        let st = SessionTemplate()
        st.parseTemplate(s)
        let (sessionName, _) = st.session
        storeTemplate(moc, project: sessionName, session: st.session, tasks: st.tasks)
        cloneSession(moc, projectName: sessionName, sessionName: sessionName)

    }

    //---------------------------------------------
    // TestData - addSessionToCost
    //---------------------------------------------
    
    class func addSessionToCost(moc: NSManagedObjectContext) {

        var s = "Kostnad#columns=4\n"
        s += "Comp 16A\n"
        s += "Comp 16B\n"
        s += "\n"
        s += "\n"
        s += "Main\n"
        s += "SM Yearly\n"
        s += "\n"
        s += "\n"
        s += "Alfa\n"
        s += "Bravo\n"
        s += "Charlie\n"
        s += "Delta\n"
        s += "Echo\n"
        s += "Foxtrot\n"
        s += "Golf\n"
        s += "Hotel\n"
        s += "India\n"
        s += "Juliet\n"
        s += "Kilo\n"
        s += "Lima\n"
        s += "Mike\n"
        s += "November\n"
        s += "Oskar\n"
        s += "Papa\n"
        s += "Quebeq\n"
        s += "Romeo\n"
        s += "Sierra\n"
        s += "Tango\n"
        s += "Uniform\n"
        s += "Viktor\n"
        s += "Whiskey\n"
        s += "X-ray\n"
        s += "Yankee\n"
        s += "Zulu"

        let st = SessionTemplate()
        st.parseTemplate(s)
        let (sessionName, _) = st.session
        storeTemplate(moc, project: sessionName, session: st.session, tasks: st.tasks)
        cloneSession(moc, projectName: sessionName, sessionName: sessionName)

    }

    //---------------------------------------------
    // TestData - addSessionToTest
    //---------------------------------------------


    class func addSessionToTest(moc: NSManagedObjectContext) {
        var s = "Test#columns=1\n"
        s += "Adam#color=8f8\n"
        s += "Bertil#color=88f\n"
        s += "Ceasar"

        let st = SessionTemplate()
        st.parseTemplate(s)
        let (sessionName, _) = st.session
        storeTemplate(moc, project: sessionName, session: st.session, tasks: st.tasks)
        cloneSession(moc, projectName: sessionName, sessionName: sessionName)
    }

    class func addSessionToTest2(moc: NSManagedObjectContext) {
        var s = "Test#columns=2\n"
        s += "\n"
        s += "Bertil#color=88f\n"
        s += "Ceasar#cat=hemma,color=ff0"

        let st = SessionTemplate()
        st.parseTemplate(s)
        let (sessionName, _) = st.session
        storeTemplate(moc, project: sessionName, session: st.session, tasks: st.tasks)
        cloneSession(moc, projectName: sessionName, sessionName: sessionName)
    }

    class func addSessionToTest3(moc: NSManagedObjectContext) {
        var s = "Test#columns=3\n"
        s += "\n"
        s += "\n"
        s += "Ceasar#color=88f\n"
        s += "David#cat=hemma,color=ff0"

        let st = SessionTemplate()
        st.parseTemplate(s)
        let (sessionName, _) = st.session
        storeTemplate(moc, project: sessionName, session: st.session, tasks: st.tasks)
        cloneSession(moc, projectName: sessionName, sessionName: sessionName)
    }


}
