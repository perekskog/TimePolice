//
//  MainExportVC.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-11-16.
//  Copyright © 2015 Per Ekskog. All rights reserved.
//

import UIKit
import CoreData

class MainExportVC: UIViewController,
    AppLoggerDataSource {

    //---------------------------------------
    // MainExportVC - Lazy properties
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
    // MainExportVC - AppLoggerDataSource
    //---------------------------------------------

    func getLogDomain() -> String {
        return "MainExportVC"
    }



    //---------------------------------------------
    // MainExportVC - View lifecycle
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

    //---------------------------------------------
    // MainSessionsVC - GUI actions
    //---------------------------------------------

    @IBAction func exit(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "exit")

        performSegueWithIdentifier("Exit", sender: self)
    }



    //----------------------------------------
    // MainSessionsVC - Buttons
    //----------------------------------------
    
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


}
