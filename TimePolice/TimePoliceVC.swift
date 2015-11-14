//
//  TimePoliceVC.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-02-03.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

/*

TODO

*/


import UIKit
import CoreData

class TimePoliceVC: UIViewController, 
    UITableViewDataSource, 
    UITableViewDelegate,
    AppLoggerDataSource,
    TaskEntryCreatorManagerDataSource,
    TaskEntryCreatorManagerDelegate {

    @IBOutlet var appLogSize: UILabel!
    
    var logTableView = UITableView(frame: CGRectZero, style: .Plain)

    var sessions: [Session]?
    var selectedSession: Session?
    var selectedSessionIndex: Int?
    
    var taskEntryCreatorManagers: [UIViewController]?

    //---------------------------------------
    // TimePoliceVC - Lazy properties
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
    // TimePoliceVC - AppLoggerDataSource
    //---------------------------------------------

    func getLogDomain() -> String {
        return "TimePoliceVC"
    }



    //---------------------------------------------
    // TimePoliceVC - View lifecycle
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

        var viewFrame = self.view.frame
        viewFrame.origin.y += 150
        viewFrame.size.height -= 150
        logTableView.frame = viewFrame
        self.view.addSubview(logTableView)
        
        logTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "TimePoliceSessionCell")
        logTableView.dataSource = self
        logTableView.delegate = self
        logTableView.rowHeight = 30
        
        redrawAll(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        appLog.log(logger, logtype: .ViewLifecycle, message: "didReceiveMemoryWarning")
    }

    //---------------------------------------------
    // TimePoliceVC - Data and GUI updates
    //---------------------------------------------

    func getSessions() -> [Session] {
        appLog.log(logger, logtype: .EnterExit, message: "getSessions")

        do {
            let fetchRequest = NSFetchRequest(entityName: "Session")
            var nonTemplateSessions: [Session] = []
            if let tmpSessions = try moc.executeFetchRequest(fetchRequest) as? [Session] {
                for session in tmpSessions {
                    if session.project.name != "Templates" {
                        nonTemplateSessions.append(session)
                    }
                }
            }
            return nonTemplateSessions

        } catch {
            return []
        }
    }
    
    func redrawAll(refreshCoreData: Bool) {
        if refreshCoreData==true {
            self.sessions = getSessions()
        }
        appLogSize.text = "\(appLog.logString.characters.count)"
        logTableView.reloadData()
    }
    
    //---------------------------------------------
    // TimePoliceVC - Segue handling
    //---------------------------------------------

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        appLog.log(logger, logtype: .EnterExit, message: "prepareForSegue")

        if segue.identifier == "TaskEntryCreatorManagers" {
            if let tbvc = segue.destinationViewController as? UITabBarController {
                if let vcs = tbvc.viewControllers,
                    i = selectedSessionIndex {
                        taskEntryCreatorManagers = vcs
                        for vc in vcs {
                            if var tecm = vc as? TaskEntryCreatorManager {
                                tecm.dataSource = self
                                tecm.delegate = self
                                tecm.currentSessionIndex = i
                            }
                        }
                }
            }
        }
    }

    @IBAction func exitVC(unwindSegue: UIStoryboardSegue ) {
        appLog.log(logger, logtype: .EnterExit, message: "exitVC")

        taskEntryCreatorManagers = nil
        
        redrawAll(false)
    }


    //----------------------------------------
    // TimePoliceVC - Buttons
    //----------------------------------------
    
    @IBAction func loadDataPrivate(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "loadDataPrivate")

        TestData.addSessionToPrivate(moc)
        TimePoliceModelUtils.save(moc)
        moc.reset()

        redrawAll(true)
    }
    
    @IBAction func loadDataWork(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "loadDataWork")

        TestData.addSessionToWork(moc)
        TimePoliceModelUtils.save(moc)
        moc.reset()

        redrawAll(true)
    }
    
    @IBAction func loadDataDaytime(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "loadDataDaytime")

        TestData.addSessionToDaytime(moc)
        TimePoliceModelUtils.save(moc)
        moc.reset()

        redrawAll(true)
    }
    
    @IBAction func loadDataCost(sender: AnyObject) {
        appLog.log(logger, logtype: .EnterExit, message: "loadDataCost")
        
        TestData.addSessionToCost(moc)
        TimePoliceModelUtils.save(moc)
        moc.reset()
        
        redrawAll(true)
    }

    @IBAction func loadDataTest(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "loadDataTest")

        TestData.addSessionToTest(moc)
        TimePoliceModelUtils.save(moc)
        moc.reset()

        redrawAll(true)
    }
    
    @IBAction func loadDataTest2(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "loadDataTest2")

        TestData.addSessionToTest2(moc)
        TimePoliceModelUtils.save(moc)
        moc.reset()

        redrawAll(true)
    }
    
    @IBAction func loadDataTest3(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "loadDataTest2")

        TestData.addSessionToTest3(moc)
        TimePoliceModelUtils.save(moc)
        moc.reset()

        redrawAll(true)
    }
    
    @IBAction func clearCoreData(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "clearAllData")

        TimePoliceModelUtils.clearAllData(moc)
        TimePoliceModelUtils.save(moc)
        moc.reset()

        redrawAll(true)
    }

    @IBAction func clearApplog(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "clearApplog")
        appLog.logString = ""
        appLogSize.text = "\(appLog.logString.characters.count))"
    }

    @IBAction func dumpCoreData(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "dumpAllCoreData")

        let s = TimePoliceModelUtils.dumpAllData(moc)
        print(s)
        UIPasteboard.generalPasteboard().string = s
    }

    @IBAction func dumpApplog(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "dumpApplog")

        let s = appLog.logString
        print(s)
        UIPasteboard.generalPasteboard().string = s
    }

    @IBAction func dumpSessionSummary(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "dumpSessionSummary")

        /*
        for each project p {
            projectSummary = [session: [Task:NSTimeInterval] ]
            setOfTasks = []
            for each session in p {
                get sessionSummary -> [Task: NSTieInterval]
                for each task in sessionSummary {
                    setOfTasks.add(task)
                }
                projectSummary[session] = sessionSummary
            }
            for each session in projectSummary {
                print session heading
            }
            for each task in setOfTasks {
                print task heading
                for each session in projectSummary {
                    print time for task
                }
            }
        }
        */

        guard let projects = Project.findInMOC(moc) else {
            return
        }

        var s = ""
        for project in projects.sort({ $0.created.compare($1.created) == .OrderedAscending }) {
            if project.name == "Templates" {
                continue
            }
            var projectSummary: [Session: [Task: (Int, NSTimeInterval)]] = [:]
            var setOfTasks = Set<Task>()
            for session in project.sessions {
                let sessionSummary = (session as! Session).getSessionTaskSummary()
                for (task, _) in sessionSummary {
                    setOfTasks.insert(task)
                }
                projectSummary[session as! Session] = sessionSummary
            }
            var heading = "\t"
            for session in projectSummary.keys.sort({ $0.created.compare($1.created) == .OrderedAscending }) {
                if let w = session.getLastWork() {
                    if w.isOngoing() {
                        heading += "* "
                    }
                }
                heading += "\(session.name)\t"
            }
            s += "\(heading)\n"

            var taskRow = ""
            var sessionTotal: [Session: NSTimeInterval] = [:]
            for task in setOfTasks.sort({ $0.name < $1.name }) {
                taskRow = "\(task.name)\t"
                for session in projectSummary.keys.sort({ $0.created.compare($1.created) == .OrderedAscending }) {
                    if let sessionSummary = projectSummary[session] {
                        if let (_, time) = sessionSummary[task] {
                            taskRow += "\(UtilitiesDate.getString(time))\t"
                            var total: NSTimeInterval = 0
                            if let t = sessionTotal[session] {
                                total = t
                            }
                            total += time
                            sessionTotal[session] = total
                        } else {
                            taskRow += "---\t"
                        }
                    }
                }
                s += "\(taskRow)\n"
            }
            var summaryRow = "Total\t"
            for session in projectSummary.keys.sort({ $0.created.compare($1.created) == .OrderedAscending }) {
                if let total = sessionTotal[session] {
                    summaryRow += "\(UtilitiesDate.getString(total))\t"
                } else {
                    summaryRow += "0\t"
                }
            }
            s += summaryRow
            s += "\n"
        }
        print(s)
        UIPasteboard.generalPasteboard().string = s
    }

    //-----------------------------------------
    // TimePoliceVC- UITableView
    //-----------------------------------------

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let s = sessions {
            return s.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TimePoliceSessionCell")!
        if let session = sessions?[indexPath.row] {
            if let work = session.getLastWork() {
                if work.isOngoing() {
                    let taskName = work.task.name
                    cell.textLabel?.text = "\(session.name) (\(taskName))"
                } else {
                    cell.textLabel?.text = "\(session.name) (---)"
                }
            } else {
                cell.textLabel?.text = "\(session.name) (empty)"                
            }
        }
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let session = sessions?[indexPath.row] {
            selectedSessionIndex = indexPath.row
            selectedSession = session
        }

        performSegueWithIdentifier("TaskEntryCreatorManagers", sender: self)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            if let session = sessions?[indexPath.row] {
                appLog.log(logger, logtype: .Debug, message: "Delete row \(indexPath.row)")
                Session.deleteInMOC(moc, session: session)
                TimePoliceModelUtils.save(moc)
                moc.reset()

                redrawAll(true)
            }
        }
    }


    //-----------------------------------------
    // TimePoliceVC - TaskEntryCreatorManagerDataSource
    //-----------------------------------------


    func taskEntryCreatorManager(sessionManager: TaskEntryCreatorManager, willChangeActiveSessionTo: Int) {
        appLog.log(logger, logtype: .EnterExit, message: "willChangeActiveSession to \(willChangeActiveSessionTo)")

        guard let s = sessions,
                tecms =  taskEntryCreatorManagers else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in taskEntryCreatorManager willChangeActiveSessionTo(\(willChangeActiveSessionTo)")
            return
        }

        if willChangeActiveSessionTo >= 0 && willChangeActiveSessionTo < s.count {
            selectedSession = s[willChangeActiveSessionTo]
            selectedSessionIndex = willChangeActiveSessionTo

            for vc in tecms {
                if let tecm = vc as? TaskEntryCreatorManager {
                    appLog.log(logger, logtype: .Debug, message: "TimePoliceVC: switchTo(\(willChangeActiveSessionTo))")
                    tecm.switchTo(willChangeActiveSessionTo)
                }
            }
        }
    }

    func taskEntryCreatorManager(taskEntryCreatorManager: TaskEntryCreatorManager, sessionForIndex: Int) -> Session? {
        appLog.log(logger, logtype: .EnterExit, message: "sessionForIndex(\(sessionForIndex))")

        guard let s = sessions
            where sessionForIndex >= 0 && sessionForIndex < s.count else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in taskEntryCreatorManager sessionForIndex(\(sessionForIndex))")
            return nil
        }
        
        return s[sessionForIndex]
    }

}
