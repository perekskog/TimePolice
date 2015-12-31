//
//  MainVC.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-11-16.
//  Copyright © 2015 Per Ekskog. All rights reserved.
//

import UIKit
import CoreData

class MainVC: UIViewController,
    AppLoggerDataSource {

    let theme = BlackGreenTheme()


    //---------------------------------------
    // MainVC - Lazy properties
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
    // MainVC - AppLoggerDataSource
    //---------------------------------------------

    func getLogDomain() -> String {
        return "MainVC"
    }


    //---------------------------------------------
    // MainVC - View lifecycle
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

        verifyConstraints(moc)
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

        (self.view as! TimePoliceBGView).theme = theme
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        appLog.log(logger, logtype: .ViewLifecycle, message: "didReceiveMemoryWarning")
    }



    //---------------------------------------------
    // MainVC - Segue handling
    //---------------------------------------------

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        appLog.log(logger, logtype: .EnterExit, message: "prepareForSegue")

        if segue.identifier == "Exit" {
            // Nothing to prepare
        }
        if segue.identifier == "Templates" {
            if let vc = segue.destinationViewController as? MainTemplateListVC {
                vc.templateProjectName = "Templates"
            }
        }
        if segue.identifier == "Sessions" {
            if let vc = segue.destinationViewController as? MainSessionListVC {
                vc.templateProjectName = "Templates"
            }
        }
    }


    @IBAction func mainVC(unwindSegue: UIStoryboardSegue ) {
        appLog.log(logger, logtype: .EnterExit, message: "mainVC")

    }


    //---------------------------------------------
    // MainVC - verifyConstraints
    //---------------------------------------------

    func verifyConstraints(moc: NSManagedObjectContext) {
        if coreDataIsConsistent == false {
            appLog.log(logger, logtype: .Debug, message: "Core Data is inconsistent - no more checks until restart")
            return
        }

        appLog.log(logger, logtype: .Debug, message: "Check for Core Data consistency")

        var fetchRequest: NSFetchRequest

        do {
            fetchRequest = NSFetchRequest(entityName: "Project")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Project] {
                for project in fetchResults {
                    if project.sessions.count==0 {
                        coreDataIsConsistent = false
                        consistencyAlert("Project \(project.id) has no session", moc: moc)
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
                        consistencyAlert("Task \(task.id) has no work and no session", moc: moc)
                    }
                }
            }
        
        } catch {
            print("Can't fetch tasks")
        }
    }

    func consistencyAlert(alertMessage: String, moc: NSManagedObjectContext) {

        let alertContoller = UIAlertController(title: "Consistency check failed", message: alertMessage,
            preferredStyle: .Alert)
        
        let dumpCoreDataAction = UIAlertAction(title: "Data structures -> pasteboard", style: .Default,
            handler: { action in
                let s = MainExportVC.dumpAllData(moc)
                print(s)
                UIPasteboard.generalPasteboard().string = s
            })
        alertContoller.addAction(dumpCoreDataAction)
        
        let okAction = UIAlertAction(title: "OK", style: .Default,
            handler: nil)
        alertContoller.addAction(okAction)
        
        presentViewController(alertContoller, animated: true, completion: nil)

    }


}
