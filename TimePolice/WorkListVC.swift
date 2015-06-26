//
//  WorkListViewController.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-04-21.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

/* 

TODO

- Custom table cell with 2 labels? 1 = name, 2 = start/stop

- Height of each cell in tableview (set for prototype cell?)

*/

import UIKit
import CoreData

class WorkListVC: UIViewController, UITableViewDataSource, UITableViewDelegate, ToolbarInfoDelegate {

    var session: Session?
    var sourceController: TimePoliceVC?

    var workListTableView = UITableView(frame: CGRectZero, style: .Plain)

//    var statusView: UITextView?
    var sessionLabel: UILabel?

    var selectedWork: Work?
    var selectedWorkIndex: Int?

    //--------------------------------------------------------
    // WorkListVC - Lazy properties
    //--------------------------------------------------------
    
    lazy var managedObjectContext : NSManagedObjectContext? = {

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
        }()

    lazy var appLog : AppLog = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.appLog        
    }()
    
    lazy var logger: AppLogger = {
        let logger = MultiLog()
        //      logger.logger1 = TextViewLog(textview: statusView!, locator: "WorkListVC")
        logger.logger2 = StringLog(locator: "WorkListVC")
        logger.logger3 = ApplogLog(locator: "WorkListVC")
        
        return logger
    }()

    //---------------------------------------------
    // WorkListVC - View lifecycle
    //---------------------------------------------

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger, logtype: .iOS, message: "viewWillAppear")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        appLog.log(logger, logtype: .iOS, message: "viewWillDisappear")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        appLog.log(logger, logtype: .iOS, message: "viewDidAppear")
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        appLog.log(logger, logtype: .iOS, message: "viewDidDisappear")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        appLog.log(logger, logtype: .iOS, message: "viewWillLayoutSubviews")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appLog.log(logger, logtype: .iOS, message: "viewDidLayoutSubviews")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
        appLog.log(logger, logtype: .iOS, message: "viewDidLoad")

        let padding = 1
        
        let theme = BlackGreenTheme()
//        let theme = BasicTheme()

        (self.view as! TimePoliceBGView).theme = theme

        var lastview: UIView

        let width = CGRectGetWidth(self.view.frame)
        let height = CGRectGetHeight(self.view.frame)

        let exitButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        exitButton.frame = CGRectMake(0, 25, 70, 30)
        exitButton.backgroundColor = UIColor(red: 0.0, green: 0.4, blue: 0.0, alpha: 1.0)
        exitButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        exitButton.setTitle("EXIT", forState: UIControlState.Normal)
        exitButton.addTarget(self, action: "exit:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(exitButton)
        lastview = exitButton

        var viewRect = CGRectMake(70, 25, width-70, 30)
        let sessionNameView = WorkListToolView(frame: viewRect)
        sessionNameView.theme = theme
        sessionNameView.tool = SessionName
        sessionNameView.toolbarInfoDelegate = self
        self.view.addSubview(sessionNameView)
        lastview = sessionNameView

        

        let workListBGView = WorkListBGView()
        workListBGView.frame = CGRectMake(0, 55, width, height - 55)
        workListBGView.theme = theme
        self.view.addSubview(workListBGView)
        lastview = workListBGView

        workListTableView.frame = CGRectMake(1, 1, width - 2*CGFloat(padding), self.view.frame.height - 190 - 2*CGFloat(padding))
        workListTableView.backgroundColor = UIColor(white: 0.4, alpha: 1.0)
        workListTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "WorkListWorkCell")
        workListTableView.dataSource = self
        workListTableView.delegate = self
        workListTableView.rowHeight = 25
        workListTableView.backgroundColor = UIColor(white: 0.0, alpha: 1.0)
        workListBGView.addSubview(workListTableView)
        scrollToEnd(workListTableView)
        lastview = workListTableView

        let addButton = UIButton.buttonWithType(.System) as! UIButton
        addButton.frame = CGRectMake(0, CGRectGetMaxY(lastview.frame) + 10, width, 30)
        addButton.backgroundColor = UIColor(red: 0.7, green: 0.0, blue: 0.0, alpha: 1.0)
        addButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        addButton.setTitle("Add/duplicate work", forState: UIControlState.Normal)
        addButton.addTarget(self, action: "addWork:", forControlEvents: UIControlEvents.TouchUpInside)
        workListBGView.addSubview(addButton)
        lastview = addButton
        
        let switchOngoingFinishedButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        switchOngoingFinishedButton.frame = CGRectMake(0, CGRectGetMaxY(lastview.frame) + 10, width, 30)
        switchOngoingFinishedButton.backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 0.0, alpha: 1.0)
        switchOngoingFinishedButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        switchOngoingFinishedButton.setTitle("Stop/continue", forState: UIControlState.Normal)
        switchOngoingFinishedButton.addTarget(self, action: "switchOngoingFinished:", forControlEvents: UIControlEvents.TouchUpInside)
        workListBGView.addSubview(switchOngoingFinishedButton)
        lastview = switchOngoingFinishedButton
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        appLog.log(logger, logtype: .iOS, message: "didReceiveMemoryWarning")
    }
    

    //-----------------------------------------
    // WorkListVC - VC button actions
    //-----------------------------------------


    func exit(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "exit")
        
        performSegueWithIdentifier("Exit", sender: self)
    }

    func switchOngoingFinished(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "switchOngoingFinished")

        if let w = session?.getLastWork() {
            if w.isOngoing() {
                w.setStoppedAt(NSDate())
            } else {
                w.setAsOngoing()
            }
            workListTableView.reloadData()
            scrollToEnd(workListTableView)
        }

    }
    
    func addWork(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "addWork")

        if let moc = managedObjectContext,
                 s = session {
            let now = NSDate()
            var task = s.tasks[0] as! Task
            if let lastWork = s.getLastWork() {
                task = lastWork.task
                if lastWork.isOngoing() {
                    lastWork.setStoppedAt(now)
                }
            }
            Work.createInMOC(moc, name: "", session: s, task: task)
            TimePoliceModelUtils.save(moc)

            workListTableView.reloadData()
            scrollToEnd(workListTableView)
        }
    }

    
    //-----------------------------------------
    // WorkListVC - UITableView
    //-----------------------------------------

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let w = session?.work {
            return w.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkListWorkCell") as! UITableViewCell
        if let w = session?.work[indexPath.row] as? Work {
            if w.isStopped() {
                let timeForWork = w.stopTime.timeIntervalSinceDate(w.startTime)
                cell.textLabel?.text = "W: \(w.task.name) \(getStringNoDate(w.startTime))->\(getStringNoDate(w.stopTime)) = \(getString(timeForWork))\n"
            } else {
                cell.textLabel?.text = "W: \(w.task.name) \(getStringNoDate(w.startTime))->(ongoing) = ------\n"
            }            
        }
        cell.backgroundColor = UIColor(white:0.25, alpha:1.0)
        cell.textLabel?.textColor = UIColor(white: 1.0, alpha: 1.0)
//        cell.textLabel?.textColor = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let w = session?.work[indexPath.row] as? Work {
            selectedWork = w
            selectedWorkIndex = indexPath.row
            
            appLog.log(logger, logtype: .Debug) { "selected(row=\(indexPath.row), work=\(w.task.name))" }

            performSegueWithIdentifier("EditWork", sender: self)
        }
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            if let moc = self.managedObjectContext,
                     s = session {
                appLog.log(logger, logtype: .Debug, message: "Delete row \(indexPath.row)")

                s.deleteWork(moc, workIndex: indexPath.row)
                TimePoliceModelUtils.save(moc)
                
                appLog.log(logger, logtype: .Debug) { TimePoliceModelUtils.getSessionWork(s) }

                workListTableView.reloadData()
            }
        }
    }



    func scrollToEnd(tableView: UITableView) {
        let numberOfSections = tableView.numberOfSections()
        let numberOfRows = tableView.numberOfRowsInSection(numberOfSections-1)
        
        if numberOfRows > 0 {
            let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
        
    }


    //---------------------------------------------
    // WorkListVC - Segue handling
    //---------------------------------------------


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        appLog.log(logger, logtype: .EnterExit) { "prepareForSegue(\(segue.identifier))" }

        if segue.identifier == "EditWork" {
            let vc = segue.destinationViewController as! EditWorkVC
            if let s = session {
                appLog.log(logger, logtype: .EnterExit) { TimePoliceModelUtils.getSessionWork(s) }

                vc.taskList = s.tasks.array as? [Task]

                // Never set any time into the future
                vc.maximumDate = NSDate()
                if let wl = s.work.array as? [Work],
                        i = selectedWorkIndex {
                    vc.work = wl[i]
                    if i > 0 {
                        // Limit to starttime of previous item, if any
                        vc.minimumDate = wl[i-1].startTime
                    }
                    if i < wl.count-1 && !wl[i+1].isOngoing() {
                        // Limit to stoptime of next item, if any
                        vc.maximumDate = wl[i+1].stopTime
                    }
                    if vc.work.isOngoing() {
                        vc.isOngoing = true
                    } else {
                        vc.isOngoing = false
                    }
                }

            }
        }

        if segue.identifier == "ExitVC" {
            // Nothing to prepare
        }

    }

    @IBAction func exitEditWork(unwindSegue: UIStoryboardSegue ) {
        appLog.log(logger, logtype: .EnterExit, message: "exitEditWork(unwindsegue=\(unwindSegue.identifier))")

        let vc = unwindSegue.sourceViewController as! EditWorkVC

        if unwindSegue.identifier == "CancelEditWork" {
            appLog.log(logger, logtype: .Debug, message: "Handle CancelEditWork... Do nothing")
            // Do nothing
        }

        if unwindSegue.identifier == "OkEditWork" {
            appLog.log(logger, logtype: .Debug, message: "Handle OkEditWork")

            if let moc = managedObjectContext,
                     s = session,
                     i = selectedWorkIndex {

                if let t = vc.taskToUse {
                    // Change task if this attribute was set
                    appLog.log(logger, logtype: .Debug, message: "EditWork selected task=\(t.name)")
                    s.getWork(i)!.task = t
                } else {
                    appLog.log(logger, logtype: .Debug, message: "EditWork no task selected")
                }
                
                if let initialDate = vc.initialStartDate,
                   datepickerStart = vc.datepickerStart {
                    appLog.log(logger, logtype: .Debug, message: "EditWork initial start date=\(getString(initialDate))")
                    appLog.log(logger, logtype: .Debug, message: "EditWork selected start date=\(getString(datepickerStart.date))")

                    if initialDate != datepickerStart.date {
                        // The initial starttime was changed
                        appLog.log(logger, logtype: .Debug, message: "Selected starttime != initial starttime, setting starttime")
                        s.setStartTime(moc, workIndex: i, desiredStartTime: datepickerStart.date)
                    } else {
                        appLog.log(logger, logtype: .Debug, message: "Selected starttime = initial starttime, don't set starttime")
                    }
                }

                if let initialDate = vc.initialStopDate,
                    datepickerStop = vc.datepickerStop {
                    appLog.log(logger, logtype: .Debug, message: "EditWork initial stop date=\(getString(initialDate))")
                    appLog.log(logger, logtype: .Debug, message: "EditWork selected stop date=\(getString(datepickerStop.date))")

                    if initialDate != datepickerStop.date {
                        // The initial stoptime was changed
                        appLog.log(logger, logtype: .Debug, message: "Selected stoptime != initial stoptime, setting stoptime")
                        s.setStopTime(moc, workIndex: i, desiredStopTime: datepickerStop.date)
                    } else {
                        appLog.log(logger, logtype: .Debug, message: "Selected stoptime = initial stoptime, don't set stoptime")
                    }
                }

                TimePoliceModelUtils.save(moc)

                appLog.log(logger, logtype: .Debug) { TimePoliceModelUtils.getSessionWork(s) }
            }
            
            workListTableView.reloadData()
        }


        if unwindSegue.identifier == "DeleteWork" {
            appLog.log(logger, logtype: .Debug, message: "Handle DeleteWork")

            if let moc = managedObjectContext,
                     s = session,
                     i = selectedWorkIndex {

                if let fillEmptySpaceWith = vc.fillEmptySpaceWith?.selectedSegmentIndex {
                    switch fillEmptySpaceWith {
                    case 0: // Nothing, deleteWork
                        appLog.log(logger, logtype: .Debug, message: "Fill with nothing")
                        s.deleteWork(moc, workIndex: i)
                    case 1: // Previous item, deleteNextWorkAndAlignStop
                        appLog.log(logger, logtype: .Debug, message: "Fill with previous")
                        s.deleteNextWorkAndAlignStop(moc, workIndex: i-1)
                    case 2: // Next item, deletePreviousWorkAndAlignStart
                        appLog.log(logger, logtype: .Debug, message: "Fill with next")
                        s.deletePreviousWorkAndAlignStart(moc, workIndex: i+1)
                    default: // Not handled
                        appLog.log(logger, logtype: .Debug, message: "Not handled")
                    }
                }

                TimePoliceModelUtils.save(moc)
                appLog.log(logger, logtype: .Debug) { TimePoliceModelUtils.getSessionWork(s) }

                workListTableView.reloadData()
            }

        }
        
    }

    //----------------------------------------------
    //  WorkListVC - Button info
    //----------------------------------------------

    // ToolbarInfoDelegate

    func getToolbarInfo() -> ToolbarInfo {
        appLog.log(logger, logtype: .EnterExit, message: "getToolbarInfo")

        var totalActivations: Int = 1 // The first task is active when first selected
        var totalTime: NSTimeInterval = 0

/*        
        for (task, (activations, time)) in sessionSummary {
            totalActivations += activations
            totalTime += time
        }
*/

        var signedIn = false

/*
        if let work = session.getLastWork() {
            if work.isOngoing() {
                signedIn = true

                let now = NSDate()
                if(now.compare(work.startTime) == .OrderedDescending) {
                    let timeForActiveTask = NSDate().timeIntervalSinceDate(work.startTime)
                    totalTime += timeForActiveTask
                }
            }
        }
*/

        var sessionName = "---"
        if let s = session {
            sessionName = s.name
        }
        let toolbarInfo = ToolbarInfo(
            signedIn: signedIn,
            totalTimesActivatedForSession: totalActivations,
            totalTimeActiveForSession: totalTime,
            sessionName: sessionName)

        return toolbarInfo
    }

}

