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

    @IBOutlet var exitButton: UIButton!
    @IBOutlet var settingsLabel: UILabel!
    @IBOutlet var sessionSelectionControl: UISegmentedControl!
    @IBOutlet var deleteSessionsButton: UIButton!
    @IBOutlet var applogSizeKeyLabel: UILabel!
    @IBOutlet var applogSizeValueLabel: UILabel!
    @IBOutlet var manageApplogButton: UIButton!
    @IBOutlet var deleteAllDataButton: UIButton!
    
    let theme = BlackGreenTheme()

    let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)


    //---------------------------------------
    // MainSettingsVC - Lazy properties
    //---------------------------------------

    lazy var mainQueueMOC : NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
        }()

    lazy var appLog : AppLog = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.appLog
    }()

    lazy var logger: AppLogger = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewWillAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewWillDisappear")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidAppear")

        let (shouldPopupAlert, message) = TimePoliceModelUtils.verifyConstraints(mainQueueMOC)
        if shouldPopupAlert == true {
            let alertController = TimePoliceModelUtils.getConsistencyAlert(message, moc: mainQueueMOC)
            present(alertController, animated: true, completion: nil)
        }

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidDisappear")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        appLog.log(logger, logtype: .viewLifecycle, message: "viewWillLayoutSubviews")

        let width = self.view.frame.width
        let height = self.view.frame.height

        exitButton.frame.size.height = CGFloat(minimumComponentHeight)

        var textRect = CGRect(x: 0, y: height/4, width: width, height: 50)
        settingsLabel.frame = textRect

        textRect.origin.y += height/5
        sessionSelectionControl.frame.origin.y = textRect.origin.y
        sessionSelectionControl.frame.origin.x = width*0.15
        sessionSelectionControl.frame.size.width = width*0.7
        sessionSelectionControl.frame.size.height = CGFloat(segmentControlHeight)
        textRect.origin.y += max(height/15, CGFloat(minimumComponentSpacing))
        deleteSessionsButton.frame = textRect

        textRect.origin.y += height/10
        textRect.size.width = width/2

        textRect.origin.x = 0
        applogSizeKeyLabel.frame = textRect
        textRect.origin.x = width/2
        textRect.size.width = width/4
        applogSizeValueLabel.frame = textRect

        textRect.origin.x = 0
        textRect.origin.y += max(height/15, CGFloat(minimumComponentSpacing))
        textRect.size.width = width
        manageApplogButton.frame = textRect

        deleteAllDataButton.frame.origin.y = height - deleteAllDataButton.frame.size.height
        deleteAllDataButton.frame.origin.x = width*0.05
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidLayoutSubviews")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidLoad")

        (self.view as! TimePoliceBGView).theme = theme

        exitButton.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(themeBigTextSize))

        settingsLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(textTitleSize))

        sessionSelectionControl.removeAllSegments()
        sessionSelectionControl.insertSegment(withTitle: "Active", at: 0, animated: false)
        sessionSelectionControl.insertSegment(withTitle: "Archived", at: 0, animated: false)
        sessionSelectionControl.insertSegment(withTitle: "All", at: 0, animated: false)
        sessionSelectionControl.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        sessionSelectionControl.tintColor = UIColor(red:0.1, green:0.6, blue:0.1, alpha: 1.0)
        sessionSelectionControl.selectedSegmentIndex = 0
        
        let r = UILongPressGestureRecognizer(target: self, action: #selector(MainSettingVC.fakeCrash(_:)))
        deleteAllDataButton.addGestureRecognizer(r)
        
        activityIndicator.frame = self.view.frame
        self.activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)

        redrawAll(false)
    }
    
     @objc func fakeCrash(_ sender: UILongPressGestureRecognizer) {
         guard sender.state == .began else {
             return
         }
        
         appLog.log(logger, logtype: .guiAction, message: "fakeCrash")
        
         let alertContoller = UIAlertController(title: "Crash?", message: nil,
             preferredStyle: .alert)
         let cancel = UIAlertAction(title: "Cancel", style: .cancel,
             handler: { action in
                 self.appLog.log(self.logger, logtype: .guiAction, message: "fakeCrash(cancel)")
         })
         alertContoller.addAction(cancel)
         let ok = UIAlertAction(title: "OK", style: .default,
             handler: { action in
                 self.appLog.log(self.logger, logtype: .guiAction, message: "fakeCrash(ok)")
                 // This code is supposed to force a crash that can be seen on the device page in XCode.
                 // In Swift 2.3, this produced a build error
                 //let vc: UIViewController?
                 //let _ = vc!.isViewLoaded()
         })
         alertContoller.addAction(ok)

         present(alertContoller, animated: true, completion: nil)
     }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        appLog.log(logger, logtype: .viewLifecycle, message: "didReceiveMemoryWarning")
    }

    //----------------------------------------
    // MainSettingsVC - Buttons
    //----------------------------------------
    
    @IBAction func clearCoreData(_ sender: UIButton) {
        appLog.log(logger, logtype: .enterExit, message: "clearCoreData")
        appLog.log(logger, logtype: .guiAction, message: "clearCoreData")

        let alertContoller = UIAlertController(title: "Delete all data?", message: nil,
            preferredStyle: .alert)
        
        let deleteAllDataAction = UIAlertAction(title: "Delete", style: .default,
            handler: { action in

            // Dispatch long running job on its own queue
            self.activityIndicator.startAnimating()
            self.appLog.log(self.logger, logtype: .debug, message: "Dispatching job")


            let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            privateMOC.parent = self.mainQueueMOC


            privateMOC.perform({
                self.appLog.log(self.logger, logtype: .debug, message: "Dispatched job started")

                MainSettingVC.clearAllData(privateMOC)

                do {
                    try privateMOC.save()
                } catch {
                    fatalError("Failure to save context: \(error)")
                }

                self.appLog.log(self.logger, logtype: .debug, message: "Did delete all data")

                // Hide activity indicator
                // Must e done on main queue so it is hidden immediatly
                DispatchQueue.main.async(execute: {
                    self.appLog.log(self.logger, logtype: .debug, message: "Hide activity indicator")
                    self.activityIndicator.stopAnimating()
                    self.redrawAll(false)
                })
            })

        })

        alertContoller.addAction(deleteAllDataAction)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel,
            handler: nil)
        alertContoller.addAction(cancel)
        
        present(alertContoller, animated: true, completion: nil)
    }

    @IBAction func deleteSessions(_ sender: UIButton) {
        appLog.log(logger, logtype: .enterExit, message: "deleteSessions")
        appLog.log(logger, logtype: .guiAction, message: "deleteSessions")

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
            preferredStyle: .alert)

        let deleteSessionsAction = UIAlertAction(title: "Delete", style: .default,
            handler: { action in
                
                // Dispatch long running job on its own queue
                self.activityIndicator.startAnimating()
                self.appLog.log(self.logger, logtype: .debug, message: "Dispatching job")

                let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                privateMOC.parent = self.mainQueueMOC


                privateMOC.perform({
                    self.appLog.log(self.logger, logtype: .debug, message: "Dispatched job started")
                    
                    MainSettingVC.clearSessionsKeepTemplates(privateMOC, archived: archived, active: active)

                    do {
                        try privateMOC.save()
                    } catch {
                        fatalError("Failure to save context: \(error)")
                    }

                    self.appLog.log(self.logger, logtype: .debug, message: "Did: \(prompt)")
                    
                    // Hide activity indicator
                    // Must e done on main queue so it is hidden immediatly
                    DispatchQueue.main.async(execute: {
                        self.appLog.log(self.logger, logtype: .debug, message: "Hide activity indicator")
                        self.activityIndicator.stopAnimating()
                        self.redrawAll(false)
                    })
                })
            })

        alertContoller.addAction(deleteSessionsAction)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel,
            handler: nil)
        alertContoller.addAction(cancel)
        
        present(alertContoller, animated: true, completion: nil)
    }

    @IBAction func applogActions(_ sender: UIButton) {
        appLog.log(logger, logtype: .enterExit, message: "applogActions")
        appLog.log(logger, logtype: .guiAction, message: "applogActions")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let alertController = UIAlertController(title: "Applog actions", message: nil,
            preferredStyle: .alert)


        var toggleString = "Enable applog"
        if appDelegate.enabled == true {
            toggleString = "Disable applog"
        }
        let toggleApplogAction = UIAlertAction(title: toggleString, style: .default,
            handler: { action in
                appDelegate.enabled = !appDelegate.enabled
                self.appLog.log(self.logger, logtype: .debug, message: "Did: \(toggleString)")
            }
        )
        alertController.addAction(toggleApplogAction)




        let noTracesSetting = UIAlertAction(title: "No traces", style: .default,
            handler: { action in
                self.appLog.log(self.logger, logtype: .debug, message: "Set to no traces")
                appDelegate.included = noTraces
            }
        )
        alertController.addAction(noTracesSetting)
        



        var toggleGUIActionTitle = "+ GUIAction"
        if appDelegate.included.contains(.guiAction) {
            toggleGUIActionTitle = "- GUIAction"
        }
        let toggleGUIAction = UIAlertAction(title: toggleGUIActionTitle, style: .default,
            handler: { action in
                if appDelegate.included.contains(.guiAction) {
                    appDelegate.included.remove(.guiAction)
                } else {
                    appDelegate.included.insert(.guiAction)
                }
                self.appLog.log(self.logger, logtype: .debug, message: "Did: \(toggleGUIActionTitle)")
            }
        )
        alertController.addAction(toggleGUIAction)



        var toggleViewLifecycleTitle = "+ ViewLifecycle"
        if appDelegate.included.contains(.viewLifecycle) {
            toggleViewLifecycleTitle = "- ViewLifecycle"
        }
        let toggleViewLifecycle = UIAlertAction(title: toggleViewLifecycleTitle, style: .default,
            handler: { action in
                if appDelegate.included.contains(.viewLifecycle) {
                    appDelegate.included.remove(.viewLifecycle)
                } else {
                    appDelegate.included.insert(.viewLifecycle)
                }
                self.appLog.log(self.logger, logtype: .debug, message: "Did: \(toggleViewLifecycleTitle)")
            }
        )
        alertController.addAction(toggleViewLifecycle)





        let defaultTracesSetting = UIAlertAction(title: "Default traces", style: .default,
            handler: { action in
                self.appLog.log(self.logger, logtype: .debug, message: "Set to default traces")
                appDelegate.included = defaultTraces
            }
        )
        alertController.addAction(defaultTracesSetting)
        



        var togglePeriodicCallbackTitle = "+ PeriodicCallback"
        if appDelegate.included.contains(.periodicCallback) {
            togglePeriodicCallbackTitle = "- PeriodicCallback"
        }
        let togglePeriodicCallback = UIAlertAction(title: togglePeriodicCallbackTitle, style: .default,
            handler: { action in
                if appDelegate.included.contains(.periodicCallback) {
                    appDelegate.included.remove(.periodicCallback)
                } else {
                    appDelegate.included.insert(.periodicCallback)
                }
                self.appLog.log(self.logger, logtype: .debug, message: "Did: \(togglePeriodicCallbackTitle)")
            }
        )
        alertController.addAction(togglePeriodicCallback)




        let resetApplog = UIAlertAction(title: "Reset applog", style: .default,
            handler: { action in
                self.appLog.logString = ""
                self.appLog.log(self.logger, logtype: .debug, message: "Did reset applog")
                self.redrawAll(false)

            }
        )
        alertController.addAction(resetApplog)


        let cancel = UIAlertAction(title: "Cancel", style: .cancel,
            handler: nil)
        alertController.addAction(cancel)

        present(alertController, animated: true, completion: nil)
    }

    //---------------------------------------------
    // MainSettingsVC - Data and GUI updates
    //---------------------------------------------

    func redrawAll(_ refreshCoreData: Bool) {
        if refreshCoreData==true {
        }
        applogSizeValueLabel.text = "\(self.appLog.logString.count)"
    }

    //---------------------------------------------
    // MainSettingsVC - GUI actions
    //---------------------------------------------

    @IBAction func exit(_ sender: UIButton) {
        appLog.log(logger, logtype: .enterExit, message: "exit")
        appLog.log(logger, logtype: .guiAction, message: "exit")

        performSegue(withIdentifier: "Exit", sender: self)
    }

    //---------------------------------------------
    // MainSettingsVC - clearAllData
    //---------------------------------------------

    class func clearAllData(_ moc: NSManagedObjectContext) {
        var fetchRequest: NSFetchRequest<NSFetchRequestResult>
        
        do {
            // Delete all task entries
            fetchRequest = NSFetchRequest(entityName: "TaskEntry")
            if let fetchResults = try moc.fetch(fetchRequest) as? [TaskEntry] {
                for taskEntry in fetchResults {
                    moc.delete(taskEntry)
                }
            }
        } catch {
            print("Can't fetch task entries for deletion")
        }
        
        do {
            // Delete all tasks
            fetchRequest = NSFetchRequest(entityName: "Task")
            if let fetchResults = try moc.fetch(fetchRequest) as? [Task] {
                for task in fetchResults {
                    moc.delete(task)
                }
            }
        } catch {
            print("Can't fetch tasks for deletion")
        }
        
        do {
            // Delete all sessions
            fetchRequest = NSFetchRequest(entityName: "Session")
            if let fetchResults = try moc.fetch(fetchRequest) as? [Session] {
                for session in fetchResults {
                    moc.delete(session)
                }
            }
        } catch {
            print("Can't fetch sessions for deletion")
        }
        
        do {
            // Delete all projects
            fetchRequest = NSFetchRequest(entityName: "Project")
            if let fetchResults = try moc.fetch(fetchRequest) as? [Project] {
                for project in fetchResults {
                    moc.delete(project)
                }
            }
        } catch {
            print("Can't fetch projects for deletion")
        }
        
        coreDataIsConsistent = true
    }

    //---------------------------------------------
    // MainSettingsVC - clearSessionsKeepTemplates
    //---------------------------------------------

    class func clearSessionsKeepTemplates(_ moc: NSManagedObjectContext, archived: Bool, active: Bool) {
        var fetchRequest: NSFetchRequest<NSFetchRequestResult>

        
        do {
            fetchRequest = NSFetchRequest(entityName: "Session")
            if let fetchResults = try moc.fetch(fetchRequest) as? [Session] {
                for session in fetchResults {
                    if session.project.name != templateProjectName {
                        if session.archived == NSNumber(value:archived) || session.archived != NSNumber(value:active) {
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
