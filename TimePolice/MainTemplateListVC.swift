//
//  MainTemplateListVC.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-11-16.
//  Copyright © 2015 Per Ekskog. All rights reserved.
//

/*

TODO

*/

import UIKit
import CoreData

class MainTemplateListVC: UIViewController,
    AppLoggerDataSource,
    ToolbarInfoDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    UIGestureRecognizerDelegate {

    // Input data
    var templateProjectName: String?

    // Internal data
    var templateSessions: [Session]?
    var selectedTemplateIndex: Int?

    // GUI
    var templateTableView = UITableView(frame: CGRectZero, style: .Plain)
    let exitButton = UIButton(type: UIButtonType.System)
    let sessionNameView = WorkListToolView()
    let templateListBGView = WorkListBGView()
    let addView = WorkListToolView()
    let theme = BlackGreenTheme()



    //---------------------------------------
    // MainTemplateListVC - Lazy properties
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
    // MainTemplateListVC - AppLoggerDataSource
    //---------------------------------------------

    func getLogDomain() -> String {
        return "MainTemplateListVC"
    }



    //---------------------------------------------
    // MainTemplateListVC - View lifecycle
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

        self.edgesForExtendedLayout = .None

        exitButton.backgroundColor = UIColor(red: 0.0, green: 0.4, blue: 0.0, alpha: 1.0)
        exitButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        exitButton.setTitle("EXIT", forState: UIControlState.Normal)
        exitButton.addTarget(self, action: "exit:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(exitButton)

        sessionNameView.theme = theme
        sessionNameView.tool = .SessionName
        sessionNameView.toolbarInfoDelegate = self
        self.view.addSubview(sessionNameView)

        templateListBGView.theme = theme
        self.view.addSubview(templateListBGView)

        templateTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "TemplateList")
        templateTableView.dataSource = self
        templateTableView.delegate = self
        templateTableView.rowHeight = 25
        templateTableView.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
        templateTableView.separatorColor = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
        templateListBGView.addSubview(templateTableView)                

        addView.theme = theme
        addView.toolbarInfoDelegate = self
        addView.tool = .Add
        let recognizer = UITapGestureRecognizer(target:self, action:Selector("addTemplate:"))
        recognizer.delegate = self
        addView.addGestureRecognizer(recognizer)
        templateListBGView.addSubview(addView)

        redrawAll(true)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewWillAppear")

        if let indexPath = templateTableView.indexPathForSelectedRow {
            templateTableView.deselectRowAtIndexPath(indexPath, animated: true)
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

        templateListBGView.frame = CGRectMake(0, 55, width, height - 55)
        lastview = templateListBGView

        width = CGRectGetWidth(templateListBGView.frame)
        height = CGRectGetHeight(templateListBGView.frame)
        let padding = 1

        templateTableView.frame = CGRectMake(CGFloat(padding), CGFloat(padding), width - 2*CGFloat(padding), height - 30 - CGFloat(padding))
        lastview = templateTableView

        addView.frame = CGRectMake(CGFloat(padding), CGRectGetMaxY(lastview.frame) + CGFloat(padding), width - 2*CGFloat(padding), 30 - 2*CGFloat(padding))
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
    // MainTemplateListVC - Data and GUI updates
    //---------------------------------------------

    func redrawAll(refreshCoreData: Bool) {
        if refreshCoreData==true {
            templateSessions = getTemplates()
        }
        templateTableView.reloadData()
    }

    func getTemplates() -> [Session] {
        appLog.log(logger, logtype: .EnterExit, message: "getTemplates")

        do {
            let fetchRequest = NSFetchRequest(entityName: "Session")
            var templateSessions: [Session] = []
            if let tmpSessions = try moc.executeFetchRequest(fetchRequest) as? [Session] {
                for session in tmpSessions {
                    if session.project.name == templateProjectName {
                        templateSessions.append(session)
                    }
                }
            }
            return templateSessions

        } catch {
            return []
        }
    }


    //---------------------------------------------
    // MainTemplateListVC - GUI actions
    //---------------------------------------------

    @IBAction func exit(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "exit")
        appLog.log(logger, logtype: .GUIAction, message: "exit")

        performSegueWithIdentifier("Exit", sender: self)
    }

    @IBAction func addTemplate(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "addTemplate")
        appLog.log(logger, logtype: .GUIAction, message: "addTemplate")

        performSegueWithIdentifier("AddTemplate", sender: self)
    }


    //----------------------------------------------
    //  MainTemplateListVC - Segue handling
    //----------------------------------------------

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        appLog.log(logger, logtype: .EnterExit) { "prepareForSegue(\(segue.identifier))" }

        if segue.identifier == "AddTemplate" {
            if let nvc = segue.destinationViewController as? UINavigationController,
                    vc = nvc.topViewController as? MainTemplatePropVC {
                vc.segue = "AddTemplate"
                var s = "Name#extension=DD hhmmss\n"
                s += "Task 1\n"
                s += "Task 2#color=f44"
                vc.template = s
            }
        }
        if segue.identifier == "EditTemplate" {
            if let nvc = segue.destinationViewController as? UINavigationController,
                    vc = nvc.topViewController as? MainTemplatePropVC,
                    i = selectedTemplateIndex,
                    s = templateSessions?[i] {
                vc.segue = "EditTemplate"
                vc.template = s.src
            }
        }
    }

    @IBAction func exitTemplateProp(unwindSegue: UIStoryboardSegue ) {
        appLog.log(logger, logtype: .EnterExit, message: "exitTemplateProp(unwindsegue=\(unwindSegue.identifier))")

        if unwindSegue.identifier == "CancelTemplateProp" {
            redrawAll(true)
        }
        if unwindSegue.identifier == "SaveTemplateProp" {
            // Update template
            if let vc = unwindSegue.sourceViewController as? MainTemplatePropVC,
                newSrc = vc.updatedTemplate {
                    let st = SessionTemplate()
                    st.parseTemplate(newSrc)
                    appLog.log(logger, logtype: .CoreData, message: st.getString(st.session, tasks: st.tasks))
                    let (reuseTasksFromProject, _) = st.session
                    TimePoliceModelUtils.storeTemplate(moc, reuseTasksFromProject: reuseTasksFromProject, session: st.session, tasks: st.tasks, src: newSrc)
            }
            redrawAll(true)
        }
    }

    //---------------------------------------------
    // MainTemplateListVC - UITableViewDataSource
    //---------------------------------------------
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let s = templateSessions {
            return s.count
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = templateTableView.dequeueReusableCellWithIdentifier("TemplateList", forIndexPath: indexPath)

        if let s = templateSessions
        where indexPath.row >= 0 && indexPath.row <= s.count {
            let session = s[indexPath.row]
            cell.textLabel?.text = session.name
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
    // MainTemplateListVC - UITableViewDelegate
    //-----------------------------------------

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        appLog.log(logger, logtype: .EnterExit, message: "tableView.didSelectRowAtIndexPath")
        appLog.log(logger, logtype: .GUIAction, message: "tableView.didSelectRowAtIndexPath")

        if let s = templateSessions
        where indexPath.row >= 0 && indexPath.row < s.count {
            selectedTemplateIndex = indexPath.row
            performSegueWithIdentifier("EditTemplate", sender: self)
        }
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        appLog.log(logger, logtype: .EnterExit, message: "tableView.commitEditingStyle")
        appLog.log(logger, logtype: .GUIAction, message: "tableView.commitEditingStyle")

        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            if let session = templateSessions?[indexPath.row] {
                appLog.log(logger, logtype: .Debug, message: "Delete row \(indexPath.row)")
                Session.deleteObject(session)
                TimePoliceModelUtils.save(moc)
                moc.reset()

                redrawAll(true)
            }
        }
    }

    //----------------------------------------------
    //  MainTemplateListVC - ToolbarInfoDelegate
    //----------------------------------------------
    
    func getToolbarInfo() -> ToolbarInfo {
        appLog.log(logger, logtype: .PeriodicCallback, message: "getToolbarInfo")
        
        let toolbarInfo = ToolbarInfo(
            signedIn: false,
            totalTimesActivatedForSession: 0,
            totalTimeActiveForSession: 0,
            sessionName: "Templates")
        
        return toolbarInfo
    }

}
