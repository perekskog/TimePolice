//
//  MainSessionsVC.swift
//  MainSessions
//
//  Created by Per Ekskog on 2015-02-03.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

/*

TODO

*/


import UIKit
import CoreData

class MainSessionListVC: UIViewController,
    UITableViewDataSource, 
    UITableViewDelegate,
    UIGestureRecognizerDelegate,
    AppLoggerDataSource,
    ToolbarInfoDelegate,
    TaskEntryCreatorManagerDataSource,
    TaskEntryCreatorManagerDelegate {

    // Input data
    var templateProjectName: String?

    // Internal data
    var selectedSessionIndex: Int?
    var taskEntryCreatorManagers: [UIViewController]?
    var nonTemplateSessions: [Session]?
    var templateSessions: [Session]?

    // GUI
    var sessionTableView = UITableView(frame: CGRectZero, style: .Plain)
    let exitButton = UIButton(type: UIButtonType.System)
    let sessionNameView = WorkListToolView()
    let sessionSelectionControl = UISegmentedControl(frame: CGRectZero)
    let sessionListBGView = WorkListBGView()
    let addView = WorkListToolView()
    let theme = BlackGreenTheme()


    //---------------------------------------
    // MainSessionListVC - Lazy properties
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
    // MainSessionListVC - AppLoggerDataSource
    //---------------------------------------------

    func getLogDomain() -> String {
        return "MainSessionListVC"
    }



    //---------------------------------------------
    // MainSessionListVC - View lifecycle
    //---------------------------------------------

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

    override func viewDidLoad() {
        super.viewDidLoad()
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewDidLoad")

        (self.view as! TimePoliceBGView).theme = theme

        exitButton.backgroundColor = UIColor(red: 0.0, green: 0.4, blue: 0.0, alpha: 1.0)
        exitButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        exitButton.setTitle("EXIT", forState: UIControlState.Normal)
        exitButton.addTarget(self, action: "exit:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(exitButton)

        sessionNameView.theme = theme
        sessionNameView.tool = .SessionName
        sessionNameView.toolbarInfoDelegate = self
        self.view.addSubview(sessionNameView)

        sessionListBGView.theme = theme
        self.view.addSubview(sessionListBGView)

        sessionTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "SessionList")
        sessionTableView.dataSource = self
        sessionTableView.delegate = self
        sessionTableView.rowHeight = 25
        sessionTableView.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
        sessionTableView.separatorColor = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPressTableView:"))
        sessionTableView.addGestureRecognizer(longPressRecognizer)
        sessionListBGView.addSubview(sessionTableView)

        sessionSelectionControl.insertSegmentWithTitle("Active", atIndex: 0, animated: false)
        sessionSelectionControl.insertSegmentWithTitle("Archived", atIndex: 0, animated: false)
        sessionSelectionControl.insertSegmentWithTitle("All", atIndex: 0, animated: false)
        sessionSelectionControl.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        sessionSelectionControl.tintColor = UIColor(red:0.1, green:0.7, blue:0.1, alpha: 1.0)
        sessionSelectionControl.addTarget(self, action: "selectSessions:", forControlEvents: .ValueChanged)
        sessionSelectionControl.selectedSegmentIndex = 2
        sessionListBGView.addSubview(sessionSelectionControl)

        addView.theme = theme
        addView.toolbarInfoDelegate = self
        addView.tool = .Add
        let recognizer = UITapGestureRecognizer(target:self, action:Selector("addSession:"))
        recognizer.delegate = self
        addView.addGestureRecognizer(recognizer)
        sessionListBGView.addSubview(addView)
        
        redrawAll(true)
    }


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewWillAppear")

        if let indexPath = sessionTableView.indexPathForSelectedRow {
            sessionTableView.deselectRowAtIndexPath(indexPath, animated: true)
        }

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewWillLayoutSubviews")

        var width = CGRectGetWidth(self.view.frame)
        var height = CGRectGetHeight(self.view.frame)

        var lastview: UIView

        exitButton.frame = CGRectMake(0, 25, 70, 30)
        lastview = exitButton

        sessionNameView.frame = CGRectMake(70, 25, width-70, 30)
        lastview = sessionNameView

        sessionListBGView.frame = CGRectMake(0, 55, width, height - 55)
        lastview = sessionListBGView

        width = CGRectGetWidth(sessionListBGView.frame)
        height = CGRectGetHeight(sessionListBGView.frame)
        let padding = 1

        sessionSelectionControl.frame = CGRectMake(0, 0, width, 25)

        sessionTableView.frame = CGRectMake(CGFloat(padding), 25, width - 2*CGFloat(padding), height - 25 - 30 - CGFloat(padding))
        lastview = sessionTableView

        addView.frame = CGRectMake(CGFloat(padding), CGRectGetMaxY(lastview.frame) + CGFloat(padding), width - 2*CGFloat(padding), 30 - CGFloat(padding))
        lastview = addView
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewDidLayoutSubviews")
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        appLog.log(logger, logtype: .ViewLifecycle, message: "didReceiveMemoryWarning")
    }

    //---------------------------------------------
    // MainSessionListVC - Data and GUI updates
    //---------------------------------------------

    func redrawAll(refreshCoreData: Bool) {
        if refreshCoreData==true {
            var s1, s2: [Session]
            let x = sessionSelectionControl.selectedSegmentIndex
            switch  x {
            case 0: (s1, s2) = getSessions(true, archived: true)
            case 1: (s1, s2) = getSessions(false, archived: true)
            case 2: (s1, s2) = getSessions(true, archived: false)
            default: (s1, s2) = getSessions(false, archived: false)
            }
            self.nonTemplateSessions = s1
            self.templateSessions = s2
        }
        sessionTableView.reloadData()
    }
    
    func getSessions(active: Bool, archived: Bool) -> ([Session], [Session]) {
        appLog.log(logger, logtype: .EnterExit, message: "getSessions")

        do {
            let fetchRequest = NSFetchRequest(entityName: "Session")

            var nonTemplateSessions: [Session] = []
            var templateSessions: [Session] = []
            
            if let tmpSessions = try moc.executeFetchRequest(fetchRequest) as? [Session] {
                for session in tmpSessions {
                    if session.project.name != templateProjectName {
                        if active==true && session.archived==false {
                            nonTemplateSessions.append(session)
                        }
                        if archived==true && session.archived==true {
                            nonTemplateSessions.append(session)
                        }
                    } else {
                        templateSessions.append(session)
                    }
                }
            }
            return (nonTemplateSessions, templateSessions)

        } catch {
            return ([], [])
        }
    }
    
    func selectSessions(sender: UISegmentedControl) {
        appLog.log(logger, logtype: .EnterExit, message: "selectSessions")
        redrawAll(true)
    }
    
    //---------------------------------------------
    // MainSessionListVC - GUI actions
    //---------------------------------------------

    @IBAction func exit(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "exit")

        performSegueWithIdentifier("Exit", sender: self)
    }

    @IBAction func addSession(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "addSession")

        performSegueWithIdentifier("AddSession", sender: self)
    }

    func handleLongPressTableView(sender: UILongPressGestureRecognizer) {
        appLog.log(logger, logtype: .EnterExit, message: "handleLongPressTableView")

        if sender.state != UIGestureRecognizerState.Began {
            return
        }

        let locationInView = sender.locationInView(sessionTableView)
        let indexPath = sessionTableView.indexPathForRowAtPoint(locationInView)

        guard let s = nonTemplateSessions?[(indexPath?.row)!] else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in nonTemplateSessions[indexPath.row]")
            return
        }

        var title = "Archive session?"
        if s.archived==true {
            title = "Unarchive session?"
        }

        let alertContoller = UIAlertController(title: title, message: nil,
            preferredStyle: .Alert)
        
        let actionYes = UIAlertAction(title: "Yes", style: .Default,
            handler: { action in
                if s.archived==true {
                    s.archived=false
                } else {
                    s.archived=true
                }
                self.appLog.log(self.logger, logtype: .Debug, message: "Did \(title)")
                self.redrawAll(true)
            })
        alertContoller.addAction(actionYes)
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel,
            handler: nil)
        alertContoller.addAction(cancel)
        
        presentViewController(alertContoller, animated: true, completion: nil)

    }

    //---------------------------------------------
    // MainSessionListVC - Segue handling
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
        if segue.identifier == "Exit" {
            // Nothing to prepare
        }
        if segue.identifier == "AddSession" {
            if let nvc = segue.destinationViewController as? UINavigationController,
                    vc = nvc.topViewController as? MainTemplateSelectVC {
                vc.templates = templateSessions
            }
        }
    }

    @IBAction func exitVC(unwindSegue: UIStoryboardSegue ) {
        appLog.log(logger, logtype: .EnterExit, message: "exitVC")

        taskEntryCreatorManagers = nil
        
        redrawAll(false)
    }

    @IBAction func exitSelectTemplate(unwindSegue: UIStoryboardSegue ) {
        appLog.log(logger, logtype: .EnterExit, message: "exitSelectTemplate(unwindsegue=\(unwindSegue.identifier))")

        if unwindSegue.identifier == "DoneTemplateSelect" {
            if let vc = unwindSegue.sourceViewController as? MainTemplateSelectVC,
                i = vc.templateIndexSelected,
                s = templateSessions?[i] {
                TimePoliceModelUtils.cloneSession(moc, projectName: s.name, sessionName: s.name)
                TimePoliceModelUtils.save(moc)
                moc.reset()
                redrawAll(true)
            }
        }
        if unwindSegue.identifier == "CancelTemplateSelect" {
            // Do nothing
        }
    }


    //-----------------------------------------
    // MainSessionListVC - UITableViewDataSource
    //-----------------------------------------

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let s = nonTemplateSessions {
            return s.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SessionList", forIndexPath: indexPath)

        if let s = nonTemplateSessions
        where indexPath.row >= 0 && indexPath.row <= s.count {
            let session = s[indexPath.row]

            let sessionName = session.name

            var nameSuffix = ""
            if let e = session.getProperty("extension") {
                nameSuffix = UtilitiesDate.getStringWithFormat(session.created, format: e)
            }
            
            var taskName = "(empty)"
            if let work = session.getLastWork() {
                if work.isOngoing() {
                    taskName = work.task.name
                } else {
                    taskName = "(---)"
                }
            }
            cell.textLabel?.text = "\(sessionName) \(nameSuffix) \(taskName)"
        }

        cell.backgroundColor = UIColor(white:0.3, alpha:1.0)
        cell.textLabel?.textColor = UIColor(white: 1.0, alpha: 1.0)
        cell.textLabel?.adjustsFontSizeToFitWidth = true

        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero

        cell.textLabel?.adjustsFontSizeToFitWidth = true

        return cell
    }
    

    //-----------------------------------------
    // MainSessionListVC - UITableViewDelegate
    //-----------------------------------------

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let s = nonTemplateSessions
        where indexPath.row >= 0 && indexPath.row < s.count {
            selectedSessionIndex = indexPath.row
            performSegueWithIdentifier("TaskEntryCreatorManagers", sender: self)
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            if let session = nonTemplateSessions?[indexPath.row] {
                appLog.log(logger, logtype: .Debug, message: "Delete row \(indexPath.row)")
                Session.deleteObject(session)
                TimePoliceModelUtils.save(moc)
                moc.reset()

                redrawAll(true)
            }
        }
    }


    //----------------------------------------------
    //  MainSessionListVC - ToolbarInfoDelegate
    //----------------------------------------------
    
    func getToolbarInfo() -> ToolbarInfo {
        appLog.log(logger, logtype: .PeriodicCallback, message: "getToolbarInfo")
        
        let toolbarInfo = ToolbarInfo(
            signedIn: false,
            totalTimesActivatedForSession: 0,
            totalTimeActiveForSession: 0,
            sessionName: "Sessions")
        
        return toolbarInfo
    }


    //-----------------------------------------
    // MainSessionListVC - TaskEntryCreatorManagerDataSource
    //-----------------------------------------


    func taskEntryCreatorManager(sessionManager: TaskEntryCreatorManager, willChangeActiveSessionTo: Int) {
        appLog.log(logger, logtype: .EnterExit, message: "willChangeActiveSession to \(willChangeActiveSessionTo)")

        guard let s = nonTemplateSessions,
                tecms =  taskEntryCreatorManagers else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in taskEntryCreatorManager willChangeActiveSessionTo(\(willChangeActiveSessionTo)")
            return
        }

        if willChangeActiveSessionTo >= 0 && willChangeActiveSessionTo < s.count {
            selectedSessionIndex = willChangeActiveSessionTo

            for vc in tecms {
                if let tecm = vc as? TaskEntryCreatorManager {
                    appLog.log(logger, logtype: .Debug, message: "MainSessionsVC: switchTo(\(willChangeActiveSessionTo))")
                    tecm.switchTo(willChangeActiveSessionTo)
                }
            }
        }
    }

    func taskEntryCreatorManager(taskEntryCreatorManager: TaskEntryCreatorManager, sessionForIndex: Int) -> Session? {
        appLog.log(logger, logtype: .EnterExit, message: "sessionForIndex(\(sessionForIndex))")

        guard let s = nonTemplateSessions
            where sessionForIndex >= 0 && sessionForIndex < s.count else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in taskEntryCreatorManager sessionForIndex(\(sessionForIndex))")
            return nil
        }
        
        return s[sessionForIndex]
    }

/*
        let alertContoller = UIAlertController(title: "Modify session", message: nil,
            preferredStyle: .ActionSheet)
        
        let fillWithPreviousAction = UIAlertAction(title: "...update with new template", style: .Default,
            handler: { action in
            })
        alertContoller.addAction(fillWithPreviousAction)
        
        if let s = session {
            if s.archived == true {
                let toggleActive = UIAlertAction(title: "...move to active", style: .Default,
                    handler: { action in
                        s.archived = false
                        self.redrawAll(true)
                    })
                    alertContoller.addAction(toggleActive)
            } else {
                let toggleActive = UIAlertAction(title: "...move to archive", style: .Default,
                    handler: { action in
                        s.archived = true
                        self.redrawAll(true)
                    })
                    alertContoller.addAction(toggleActive)                
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel,
            handler: { action in
                if let indexPath = self.workListTableView.indexPathForSelectedRow {
                    self.workListTableView.deselectRowAtIndexPath(indexPath, animated: true)
                }
            })
        alertContoller.addAction(cancel)
        
        presentViewController(alertContoller, animated: true, completion: nil)
        
*/

}
