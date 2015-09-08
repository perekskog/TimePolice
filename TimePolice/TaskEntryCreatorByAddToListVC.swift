//
//  TaskEntryCreatorByAddToListVC.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-04-21.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

/* 

TODO

- Vad är skillnaden mellan commitEditingStyle och canEditRowAtIndexPath? Behövs båda?

*/

import UIKit
import CoreData

class TaskEntryCreatorByAddToListVC:
        TaskEntryCreatorBase,
        UITableViewDataSource, 
        UITableViewDelegate, 
        UIGestureRecognizerDelegate, 
        ToolbarInfoDelegate {

    var sourceController: TimePoliceVC?

    var workListTableView = UITableView(frame: CGRectZero, style: .Plain)

    var sessionLabel: UILabel?

    var selectedWork: Work?


    // Cached values, calculated at startup
    var sessionSummary: (Int, NSTimeInterval)!

    var updateActiveActivityTimer: NSTimer?

    let exitButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    let sessionNameView = WorkListToolView()
    let workListBGView = WorkListBGView()
    let signInSignOutView = WorkListToolView()
    let addView = WorkListToolView()
    let infoAreaView = WorkListToolView()

    let theme = BlackGreenTheme()
//        let theme = BasicTheme()



    //--------------------------------------------------------
    // WorkListVC - Lazy properties
    //--------------------------------------------------------

    /*
    lazy var logger: AppLogger = {
        let logger = MultiLog()
        //      logger.logger1 = TextViewLog(textview: statusView!, locator: "WorkListVC")
        logger.logger2 = StringLog(locator: "WorkListVC")
        logger.logger3 = ApplogLog(locator: "WorkListVC")
        
        return logger
    }()
*/
    
    override func getLogDomain() -> String {
        return "TaskEntryCreatorTaskEntryList"
    }

    //---------------------------------------------
    // WorkListVC - View lifecycle
    //---------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()

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

        workListBGView.theme = theme
        self.view.addSubview(workListBGView)

        infoAreaView.theme = theme
        infoAreaView.toolbarInfoDelegate = self
        infoAreaView.tool = .InfoArea
        workListBGView.addSubview(infoAreaView)

        signInSignOutView.theme = theme
        signInSignOutView.toolbarInfoDelegate = self
        signInSignOutView.tool = .SignInSignOut
        var recognizer = UITapGestureRecognizer(target:self, action:Selector("switchOngoingFinished:"))
        recognizer.delegate = self
        signInSignOutView.addGestureRecognizer(recognizer)
        workListBGView.addSubview(signInSignOutView)


        workListTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "WorkListWorkCell")
        workListTableView.dataSource = self
        workListTableView.delegate = self
        workListTableView.rowHeight = 25
        workListTableView.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
        workListTableView.separatorColor = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
        workListBGView.addSubview(workListTableView)
        scrollToEnd(workListTableView)

        addView.theme = theme
        addView.toolbarInfoDelegate = self
        addView.tool = .Add
        recognizer = UITapGestureRecognizer(target:self, action:Selector("addWork:"))
        recognizer.delegate = self
        addView.addGestureRecognizer(recognizer)
        workListBGView.addSubview(addView)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.sessionSummary = (0,0)
        if let moc = managedObjectContext {
           self.sessionSummary = session?.getSessionSummary(moc)
        }

        updateActiveActivityTimer = NSTimer.scheduledTimerWithTimeInterval(1,
                target: self,
              selector: "updateActiveTask:",
              userInfo: nil,
               repeats: true)        


        if let indexPath = workListTableView.indexPathForSelectedRow() {
            workListTableView.deselectRowAtIndexPath(indexPath, animated: true)
        }

    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        appLog.log(logger, logtype: .iOS, message: "viewWillDisappear")

        updateActiveActivityTimer = nil
    }



    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        appLog.log(logger, logtype: .iOS, message: "viewWillLayoutSubviews")

        var width = CGRectGetWidth(self.view.frame)
        var height = CGRectGetHeight(self.view.frame)

        var lastview: UIView

        exitButton.frame = CGRectMake(0, 25, 70, 30)
        lastview = exitButton

        sessionNameView.frame = CGRectMake(70, 25, width-70, 30)
        lastview = sessionNameView

        workListBGView.frame = CGRectMake(0, 55, width, height - 55)
        lastview = workListBGView

        width = CGRectGetWidth(workListBGView.frame)
        height = CGRectGetHeight(workListBGView.frame)
        let padding = 1

        infoAreaView.frame = CGRectMake(CGFloat(padding), CGFloat(padding), width - 2*CGFloat(padding), 30)
        lastview = infoAreaView

        signInSignOutView.frame = CGRectMake(CGFloat(padding), CGRectGetMaxY(lastview.frame) + CGFloat(padding), width - 2*CGFloat(padding), 30)
        lastview = signInSignOutView

        workListTableView.frame = CGRectMake(CGFloat(padding), CGRectGetMaxY(lastview.frame) + CGFloat(padding), width - 2*CGFloat(padding), height - CGRectGetMaxY(lastview.frame) - 3*CGFloat(padding) - 30)
        lastview = workListTableView

        addView.frame = CGRectMake(CGFloat(padding), CGRectGetMaxY(lastview.frame) + CGFloat(padding), width - 2*CGFloat(padding), 30)
        lastview = addView

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Inset to left edge on cells with text
        workListTableView.separatorInset = UIEdgeInsetsZero

        // Inset to left edge on empty cells
        workListTableView.layoutMargins = UIEdgeInsetsZero
    }

    //-----------------------------------------
    // WorkListVC - GUI actions
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
                var (activations, totalTime) = sessionSummary
                activations++
                totalTime += w.stopTime.timeIntervalSinceDate(w.startTime)
                sessionSummary = (activations, totalTime)
            } else {
                var (activations, totalTime) = sessionSummary
                activations--
                totalTime -= w.stopTime.timeIntervalSinceDate(w.startTime)
                sessionSummary = (activations, totalTime)
                w.setAsOngoing()
            }
            workListTableView.reloadData()
            scrollToEnd(workListTableView)
        }
        
        signInSignOutView.setNeedsDisplay()
        infoAreaView.setNeedsDisplay()
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
                    var (activations, totalTime) = sessionSummary
                    activations++
                    totalTime += lastWork.stopTime.timeIntervalSinceDate(lastWork.startTime)
                    sessionSummary = (activations, totalTime)
                }
            }
            Work.createInMOC(moc, name: "", session: s, task: task)
            TimePoliceModelUtils.save(moc)

            workListTableView.reloadData()
            scrollToEnd(workListTableView)
        }

        signInSignOutView.setNeedsDisplay()
        infoAreaView.setNeedsDisplay()
    }

    //-----------------------------------------
    // WorkListVC - UITableViewDelegate
    //-----------------------------------------

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let w = session?.work[indexPath.row] as? Work {
            selectedWork = w
            selectedWorkIndex = indexPath.row
            
            appLog.log(logger, logtype: .Debug) { "selected(row=\(indexPath.row), work=\(w.task.name))" }

            performSegueWithIdentifier("EditTaskEntry", sender: self)
        }
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    

    
    //-----------------------------------------
    // WorkListVC - UITableViewDataSource
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
                cell.textLabel?.text = "\(ThemeUtilities.getWithoutComment(w.task.name)) \(getStringNoDate(w.startTime))->\(getStringNoDate(w.stopTime)) = \(getString(timeForWork))\n"
            } else {
                cell.textLabel?.text = "\(ThemeUtilities.getWithoutComment(w.task.name)) \(getStringNoDate(w.startTime))->(ongoing) = ------\n"
            }     
            if let comment = ThemeUtilities.getComment(w.task.name) {
                if let colorString = ThemeUtilities.getValue(comment, forTag: "color") {
                    let color = ThemeUtilities.string2color(colorString)

                    cell.imageView?.image = ThemeUtilities.getImageWithColor(color, width: 10.0, height: 10.0)
                }
            }

        }
        cell.backgroundColor = UIColor(white:0.3, alpha:1.0)
        cell.textLabel?.textColor = UIColor(white: 1.0, alpha: 1.0)
        cell.textLabel?.adjustsFontSizeToFitWidth = true

        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero

        return cell
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



    //----------------------------------------------
    //  WorkListVC - ToolbarInfoDelegate
    //----------------------------------------------

    func getToolbarInfo() -> ToolbarInfo {
        appLog.log(logger, logtype: .EnterExit, message: "getToolbarInfo")

        var (totalActivations, totalTime) = sessionSummary

        var signedIn = false
        var sessionName = "---"

        if let s = session {
            sessionName = s.name

            if let work = s.getLastWork() {
                if work.isOngoing() {
                    signedIn = true

                    let now = NSDate()
                    if(now.compare(work.startTime) == .OrderedDescending) {
                        let timeForActiveTask = NSDate().timeIntervalSinceDate(work.startTime)
                        totalTime += timeForActiveTask
                    }
                }
            }
        }

        let toolbarInfo = ToolbarInfo(
            signedIn: signedIn,
            totalTimesActivatedForSession: totalActivations,
            totalTimeActiveForSession: totalTime,
            sessionName: sessionName)

        return toolbarInfo
    }


    //---------------------------------------------
    // WorkListVC - Segue handling
    //---------------------------------------------
    
    // See base class

    override func redrawAfterSegue() {
        workListTableView.reloadData()
    }
        

    //--------------------------------------------------------------
    // WorkListVC - Periodic update of views, triggered by timeout
    //--------------------------------------------------------------

    var updateN = 0

    @objc
    func updateActiveTask(timer: NSTimer) {
        updateN++
        if updateN == 5 {
            updateN = 0
        }
        if updateN==0 {
            appLog.log(logger, logtype: .Debug, message: "updateActiveTask")
        }
        infoAreaView.setNeedsDisplay()
    }

    //---------------------------------------------
    // WorkListVC - Utility functions
    //---------------------------------------------


    func scrollToEnd(tableView: UITableView) {
        let numberOfSections = tableView.numberOfSections()
        let numberOfRows = tableView.numberOfRowsInSection(numberOfSections-1)
        
        if numberOfRows > 0 {
            let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
        
    }

}

