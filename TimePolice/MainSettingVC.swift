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


    @IBOutlet var sessionSelectionControl: UISegmentedControl!
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

        let (shouldPopupAlert, message) = TimePoliceModelUtils.verifyConstraints(moc)
        if shouldPopupAlert == true {
            let alertController = TimePoliceModelUtils.getConsistencyAlert(message, moc: moc)
            presentViewController(alertController, animated: true, completion: nil)
        }

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

        sessionSelectionControl.removeAllSegments()
        sessionSelectionControl.insertSegmentWithTitle("Active", atIndex: 0, animated: false)
        sessionSelectionControl.insertSegmentWithTitle("Archived", atIndex: 0, animated: false)
        sessionSelectionControl.insertSegmentWithTitle("All", atIndex: 0, animated: false)
        sessionSelectionControl.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        sessionSelectionControl.tintColor = UIColor(red:0.1, green:0.6, blue:0.1, alpha: 1.0)
        sessionSelectionControl.selectedSegmentIndex = 0

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
        appLog.log(logger, logtype: .GUIAction, message: "clearAllData")

        let alertContoller = UIAlertController(title: "Delete all data?", message: nil,
            preferredStyle: .Alert)
        
        let deleteAllDataAction = UIAlertAction(title: "Delete", style: .Default,
            handler: { action in
                MainSettingVC.clearAllData(self.moc)
                TimePoliceModelUtils.save(self.moc)
                self.moc.reset()
                self.appLog.log(self.logger, logtype: .Debug, message: "Did delete all data")
                self.redrawAll(false)
            })
        alertContoller.addAction(deleteAllDataAction)
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel,
            handler: nil)
        alertContoller.addAction(cancel)
        
        presentViewController(alertContoller, animated: true, completion: nil)
    }

    @IBAction func deleteSessions(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "deleteSessions")
        appLog.log(logger, logtype: .GUIAction, message: "deleteSessions")

        var prompt: String
        var active = false
        var archived = false
        
        switch sessionSelectionControl.selectedSegmentIndex {
        case 0:
            prompt = "Delete all sessions"
            archived = true
            active = true
        case 1:
            prompt = "Delete all archived sessions"
            archived = true
        case 2:
            prompt = "Delete all active sessions"
            active = true
        default: return
        }
        
        let alertContoller = UIAlertController(title: "\(prompt)?", message: nil,
            preferredStyle: .Alert)
        
        let deleteSessionsAction = UIAlertAction(title: "Delete", style: .Default,
            handler: { action in
                MainSettingVC.clearSessionsKeepTemplates(self.moc, archived: archived, active: active)
                TimePoliceModelUtils.save(self.moc)
                self.moc.reset()
                self.appLog.log(self.logger, logtype: .Debug, message: "Did: \(prompt)")
                self.redrawAll(false)
            })
        alertContoller.addAction(deleteSessionsAction)
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel,
            handler: nil)
        alertContoller.addAction(cancel)
        
        presentViewController(alertContoller, animated: true, completion: nil)
    }


    @IBAction func clearApplog(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "clearApplog")
        appLog.log(logger, logtype: .GUIAction, message: "clearApplog")
        
        let alertContoller = UIAlertController(title: "Reset applog?", message: nil,
            preferredStyle: .Alert)
        
        let clearApplogAction = UIAlertAction(title: "Reset", style: .Default,
            handler: { action in
                self.appLog.logString = ""
                self.appLog.log(self.logger, logtype: .Debug, message: "Did reset applog")
                self.redrawAll(false)
            }
        )
        alertContoller.addAction(clearApplogAction)
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel,
            handler: nil)
        alertContoller.addAction(cancel)
        
        presentViewController(alertContoller, animated: true, completion: nil)
    }

    @IBAction func applogActions(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "applogActions")
        appLog.log(logger, logtype: .GUIAction, message: "applogActions")

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let alertController = UIAlertController(title: "Applog actions", message: nil,
            preferredStyle: .Alert)


        var toggleString = "Enable applog"
        if appDelegate.enabled == true {
            toggleString = "Disable applog"
        }
        let toggleApplogAction = UIAlertAction(title: toggleString, style: .Default,
            handler: { action in
                appDelegate.enabled = !appDelegate.enabled
                self.appLog.log(self.logger, logtype: .Debug, message: "Did: \(toggleString)")
            }
        )
        alertController.addAction(toggleApplogAction)




        let noTracesSetting = UIAlertAction(title: "No traces", style: .Default,
            handler: { action in
                self.appLog.log(self.logger, logtype: .Debug, message: "Set to no traces")
                appDelegate.included = noTraces
            }
        )
        alertController.addAction(noTracesSetting)
        



        var toggleGUIActionTitle = "+ GUIAction"
        if appDelegate.included.contains(.GUIAction) {
            toggleGUIActionTitle = "- GUIAction"
        }
        let toggleGUIAction = UIAlertAction(title: toggleGUIActionTitle, style: .Default,
            handler: { action in
                if appDelegate.included.contains(.GUIAction) {
                    appDelegate.included.remove(.GUIAction)
                } else {
                    appDelegate.included.insert(.GUIAction)
                }
                self.appLog.log(self.logger, logtype: .Debug, message: "Did: \(toggleGUIActionTitle)")
            }
        )
        alertController.addAction(toggleGUIAction)



        var toggleViewLifecycleTitle = "+ ViewLifecycle"
        if appDelegate.included.contains(.ViewLifecycle) {
            toggleViewLifecycleTitle = "- ViewLifecycle"
        }
        let toggleViewLifecycle = UIAlertAction(title: toggleViewLifecycleTitle, style: .Default,
            handler: { action in
                if appDelegate.included.contains(.ViewLifecycle) {
                    appDelegate.included.remove(.ViewLifecycle)
                } else {
                    appDelegate.included.insert(.ViewLifecycle)
                }
                self.appLog.log(self.logger, logtype: .Debug, message: "Did: \(toggleViewLifecycleTitle)")
            }
        )
        alertController.addAction(toggleViewLifecycle)





        let defaultTracesSetting = UIAlertAction(title: "Default traces", style: .Default,
            handler: { action in
                self.appLog.log(self.logger, logtype: .Debug, message: "Set to default traces")
                appDelegate.included = defaultTraces
            }
        )
        alertController.addAction(defaultTracesSetting)
        



        var togglePeriodicCallbackTitle = "+ PeriodicCallback"
        if appDelegate.included.contains(.PeriodicCallback) {
            togglePeriodicCallbackTitle = "- PeriodicCallback"
        }
        let togglePeriodicCallback = UIAlertAction(title: togglePeriodicCallbackTitle, style: .Default,
            handler: { action in
                if appDelegate.included.contains(.PeriodicCallback) {
                    appDelegate.included.remove(.PeriodicCallback)
                } else {
                    appDelegate.included.insert(.PeriodicCallback)
                }
                self.appLog.log(self.logger, logtype: .Debug, message: "Did: \(togglePeriodicCallbackTitle)")
            }
        )
        alertController.addAction(togglePeriodicCallback)




        let resetApplog = UIAlertAction(title: "Reset applog", style: .Default,
            handler: { action in
                self.appLog.logString = ""
                self.appLog.log(self.logger, logtype: .Debug, message: "Did reset applog")
                self.redrawAll(false)

            }
        )
        alertController.addAction(resetApplog)


        let cancel = UIAlertAction(title: "Cancel", style: .Cancel,
            handler: nil)
        alertController.addAction(cancel)

        presentViewController(alertController, animated: true, completion: nil)
    }

    //---------------------------------------------
    // MainSettingsVC - Data and GUI updates
    //---------------------------------------------

    func redrawAll(refreshCoreData: Bool) {
        if refreshCoreData==true {
        }
        applogSize.text = "\(self.appLog.logString.characters.count)" 
    }

    //---------------------------------------------
    // MainSettingsVC - GUI actions
    //---------------------------------------------

    @IBAction func exit(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "exit")
        appLog.log(logger, logtype: .GUIAction, message: "exit")

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

        coreDataIsConsistent = true
    }

    //---------------------------------------------
    // MainSettingsVC - clearAllDataKeepTemplates
    //---------------------------------------------

    class func clearSessionsKeepTemplates(moc: NSManagedObjectContext, archived: Bool, active: Bool) {
        var fetchRequest: NSFetchRequest

        do {
            fetchRequest = NSFetchRequest(entityName: "Session")
            if let fetchResults = try moc.executeFetchRequest(fetchRequest) as? [Session] {
                for session in fetchResults {
                    if session.project.name != "Templates" {
                        if session.archived == archived || session.archived != active {
                            Session.deleteObject(session)
                            TimePoliceModelUtils.save(moc)
                        }
                    }
                }
            }
        } catch {
            print("Can't fetch sessions for deletion")
        }

    }


}
