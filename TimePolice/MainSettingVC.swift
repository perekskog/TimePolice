//
//  MainSettingVC.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-11-16.
//  Copyright © 2015 Per Ekskog. All rights reserved.
//

import UIKit
import CoreData

class MainSettingVC: UIViewController,
    AppLoggerDataSource {

    //---------------------------------------
    // MainSettingsVC - Lazy properties
    //---------------------------------------

    lazy var moc : NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
        }()

    lazy var appLog : AppLog = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.appLog
    }()

    lazy var logger: AppLogger = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var defaultLogger = appDelegate.getDefaultLogger()
        defaultLogger.datasource = self
        return defaultLogger
    }()

    //---------------------------------------------
    // MainSettingsVC - AppLoggerDataSource
    //---------------------------------------------

    func getLogDomain() -> String {
        return "MainSettingsVC"
    }



    //---------------------------------------------
    // MainSettingsVC - View lifecycle
    //---------------------------------------------

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewWillAppear")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewWillDisappear")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewDidAppear")
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewDidDisappear")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewWillLayoutSubviews")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewDidLayoutSubviews")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewDidLoad")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        appLog.log(logger, logtype: .ViewLifecycle, message: "didReceiveMemoryWarning")
    }

    //----------------------------------------
    // MainSettingsVC - Buttons
    //----------------------------------------
    
    @IBAction func clearCoreData(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "clearAllData")

        MainSettingVC.clearAllData(moc)
        TimePoliceModelUtils.save(moc)
        moc.reset()
    }

    @IBAction func clearApplog(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "clearApplog")
        appLog.logString = ""
    }

        @IBAction func settings(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "settings")
        performSegueWithIdentifier("Settings", sender: self)
    }


    //---------------------------------------------
    // MainSettingsVC - GUI actions
    //---------------------------------------------

    @IBAction func exit(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "exit")

        performSegueWithIdentifier("Exit", sender: self)
    }

    //---------------------------------------------
    // MainSettingsVC - clearAllData
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
    // MainSettingsVC - Restore templates
    //---------------------------------------------

    @IBAction func restorePrivate(sender: UIButton) {
        
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
        TimePoliceModelUtils.storeTemplate(moc, project: sessionName, session: st.session, tasks: st.tasks, src: s)

        TimePoliceModelUtils.save(moc)
        moc.reset()
    }

    @IBAction func restoreJobb(sender: UIButton) {

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
        TimePoliceModelUtils.storeTemplate(moc, project: sessionName, session: st.session, tasks: st.tasks, src: s)
    }

    @IBAction func restoreDygn(sender: UIButton) {

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
        TimePoliceModelUtils.storeTemplate(moc, project: sessionName, session: st.session, tasks: st.tasks, src: s)
    }

    @IBAction func restoreKostnad(sender: UIButton) {

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
        TimePoliceModelUtils.storeTemplate(moc, project: sessionName, session: st.session, tasks: st.tasks, src: s)
    }

    @IBAction func restoreTest1(sender: UIButton) {
        var s = "Test#columns=1\n"
        s += "Adam#color=8f8\n"
        s += "Bertil#color=88f\n"
        s += "Ceasar"

        let st = SessionTemplate()
        st.parseTemplate(s)
        let (sessionName, _) = st.session
        TimePoliceModelUtils.storeTemplate(moc, project: sessionName, session: st.session, tasks: st.tasks, src: s)
    }

    @IBAction func restoreTest2(sender: UIButton) {
        var s = "Test#columns=2\n"
        s += "\n"
        s += "Bertil#color=88f\n"
        s += "Ceasar#cat=hemma,color=ff0"

        let st = SessionTemplate()
        st.parseTemplate(s)
        let (sessionName, _) = st.session
        TimePoliceModelUtils.storeTemplate(moc, project: sessionName, session: st.session, tasks: st.tasks, src: s)
    }

    @IBAction func restoreTest3(sender: UIButton) {
        var s = "Test#columns=3\n"
        s += "\n"
        s += "\n"
        s += "Ceasar#color=88f\n"
        s += "David#cat=hemma,color=ff0"

        let st = SessionTemplate()
        st.parseTemplate(s)
        let (sessionName, _) = st.session
        TimePoliceModelUtils.storeTemplate(moc, project: sessionName, session: st.session, tasks: st.tasks, src: s)
    }

}
