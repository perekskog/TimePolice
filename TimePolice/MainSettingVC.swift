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


    @IBOutlet var applogSize: UILabel!

    let theme = BlackGreenTheme()


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

        (self.view as! TimePoliceBGView).theme = theme

        redrawAll(false)
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

        let alertContoller = UIAlertController(title: "Delete all data?", message: nil,
            preferredStyle: .Alert)
        
        let fillWithPreviousAction = UIAlertAction(title: "Delete", style: .Default,
            handler: { action in
                MainSettingVC.clearAllData(self.moc)
                TimePoliceModelUtils.save(self.moc)
                self.moc.reset()
                self.appLog.log(self.logger, logtype: .Debug, message: "Did delete all data")
                self.redrawAll(false)
            })
        alertContoller.addAction(fillWithPreviousAction)
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel,
            handler: nil)
        alertContoller.addAction(cancel)
        
        presentViewController(alertContoller, animated: true, completion: nil)
    }

    @IBAction func clearSessions(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "clearSessions")

        let alertContoller = UIAlertController(title: "Delete all sessions?", message: nil,
            preferredStyle: .Alert)
        
        let fillWithPreviousAction = UIAlertAction(title: "Delete", style: .Default,
            handler: { action in
                MainSettingVC.clearAllDataKeepTemplates(self.moc)
                TimePoliceModelUtils.save(self.moc)
                self.moc.reset()
                self.appLog.log(self.logger, logtype: .Debug, message: "Did delete all sessions")
                self.redrawAll(false)
            })
        alertContoller.addAction(fillWithPreviousAction)
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel,
            handler: nil)
        alertContoller.addAction(cancel)
        
        presentViewController(alertContoller, animated: true, completion: nil)
    }

    @IBAction func clearApplog(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "clearApplog")
        
        let alertContoller = UIAlertController(title: "Reset applog?", message: nil,
            preferredStyle: .Alert)
        
        let fillWithPreviousAction = UIAlertAction(title: "Reset", style: .Default,
            handler: { action in
                self.appLog.logString = ""
                self.appLog.log(self.logger, logtype: .Debug, message: "Did reset applog")
                self.redrawAll(false)
        })
        alertContoller.addAction(fillWithPreviousAction)
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel,
            handler: nil)
        alertContoller.addAction(cancel)
        
        presentViewController(alertContoller, animated: true, completion: nil)
    }

    //---------------------------------------------
    // MainSettingsVC - Data and GUI updates
    //---------------------------------------------

    func redrawAll(refreshCoreData: Bool) {
        if refreshCoreData==true {
        }
        applogSize.text = "current size = \(self.appLog.logString.characters.count)" 
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
    // MainSettingsVC - clearAllDataKeepTemplates
    //---------------------------------------------

    class func clearAllDataKeepTemplates(moc: NSManagedObjectContext) {
        var fetchRequest: NSFetchRequest

        do {
            // Delete all projects
            fetchRequest = NSFetchRequest(entityName: "Project")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Project] {
                for project in fetchResults {
                    if project.name != "Templates" {
                        Project.deleteObject(project)
                        //moc.deleteObject(project)
                    }
                }
            }
        } catch {
            print("Can't fetch projects for deletion")
        }

    }


}
