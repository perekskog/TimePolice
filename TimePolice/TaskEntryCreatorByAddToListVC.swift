//
//  TaskEntryCreatorByAddToListVC.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-04-21.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

/* 

TODO

*/

import UIKit
import CoreData

class TaskEntryCreatorByAddToListVC:
        TaskEntryCreatorBase,
        UITableViewDataSource, 
        UITableViewDelegate, 
        UIGestureRecognizerDelegate,
        ToolbarInfoDelegate {

    
    var sourceController: MainSessionListVC?

    var taskEntriesTableView = UITableView(frame: CGRectZero, style: .Plain)

    var sessionLabel: UILabel?

    var selectedTaskEntry: TaskEntry?


    // Cached values, calculated at startup
    var sessionSummary: (Int, NSTimeInterval)!

    var updateActiveActivityTimer: NSTimer?

    let exitButton = UIButton(type: UIButtonType.System)
    let sessionNameView = TaskEntriesToolView()
    let taskEntriesBGView = TaskEntriesBGView()
    let signInSignOutView = TaskEntriesToolView()
    let addView = TaskEntriesToolView()
    let infoAreaView = TaskEntriesToolView()

    var gap2taskEntry: [Int] = []

    let theme = BlackGreenTheme()
//        let theme = BasicTheme()

    
    //---------------------------------------------
    // TaskEntryCreatorByAddToList - AppLoggerDataSource
    //---------------------------------------------

    override
    func getLogDomain() -> String {
        return "TaskEntryCreatorByAddToList"
    }

    //---------------------------------------------
    // TaskEntryCreatorByAddToList - View lifecycle
    //---------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logger.datasource = self
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewDidLoad")

        (self.view as! TimePoliceBGView).theme = theme

        //GAP: Update list of gaps
        gap2taskEntry = []
        if let s = session,
            wl = s.taskEntries.array as? [TaskEntry] {
            gap2taskEntry = TimePoliceModelUtils.getGap2TaskEntry(wl)
        }
        var s = ""
        for i in gap2taskEntry {
            s += "\(i)\t"
        }
        appLog.log(logger, logtype: .Debug, message: s)

        exitButton.backgroundColor = UIColor(red: 0.0, green: 0.4, blue: 0.0, alpha: 1.0)
        exitButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        exitButton.setTitle("EXIT", forState: UIControlState.Normal)
        exitButton.addTarget(self, action: "exit:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(exitButton)

        sessionNameView.theme = theme
        sessionNameView.tool = .SessionName
        sessionNameView.toolbarInfoDelegate = self
        var recognizer = UITapGestureRecognizer(target:self, action:Selector("useTemplate:"))
        recognizer.delegate = self
        sessionNameView.addGestureRecognizer(recognizer)
        self.view.addSubview(sessionNameView)

        taskEntriesBGView.theme = theme
        self.view.addSubview(taskEntriesBGView)

        infoAreaView.theme = theme
        infoAreaView.toolbarInfoDelegate = self
        infoAreaView.tool = .InfoArea
        taskEntriesBGView.addSubview(infoAreaView)

        signInSignOutView.theme = theme
        signInSignOutView.toolbarInfoDelegate = self
        signInSignOutView.tool = .SignInSignOut
        recognizer = UITapGestureRecognizer(target:self, action:Selector("switchOngoingFinished:"))
        recognizer.delegate = self
        signInSignOutView.addGestureRecognizer(recognizer)
        taskEntriesBGView.addSubview(signInSignOutView)


        taskEntriesTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "TaskEntriesCell")
        taskEntriesTableView.dataSource = self
        taskEntriesTableView.delegate = self
        taskEntriesTableView.rowHeight = CGFloat(selectItemTableRowHeight)
        taskEntriesTableView.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
        taskEntriesTableView.separatorColor = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
        taskEntriesBGView.addSubview(taskEntriesTableView)

        addView.theme = theme
        addView.toolbarInfoDelegate = self
        addView.tool = .Add
        recognizer = UITapGestureRecognizer(target:self, action:Selector("addTaskEntry:"))
        recognizer.delegate = self
        addView.addGestureRecognizer(recognizer)
        taskEntriesBGView.addSubview(addView)

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewWillAppear")


        if let indexPath = taskEntriesTableView.indexPathForSelectedRow {
            taskEntriesTableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewDidAppear")

        // This was originally in viewWillAppear, but it seems that viewWillAppear will be called
        // when changing session (PageController) and then, when changing TabBar, it will NOT
        // be called. 
        // viewDidAppear is always called.

        updateActiveActivityTimer = NSTimer.scheduledTimerWithTimeInterval(1,
                target: self,
              selector: "updateActiveTask:",
              userInfo: nil,
               repeats: true)        

        appLog.log(logger, logtype: .Resource, message: "starting timer \(updateActiveActivityTimer)")

        self.sessionSummary = (0,0)
        self.sessionSummary = session?.getSessionSummary(moc)
        redrawAfterSegue()
        scrollToEnd(taskEntriesTableView)
    }


    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewWillDisappear")
    }


    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewDidDisappear")

        appLog.log(logger, logtype: .Resource, message: "stopping timer \(updateActiveActivityTimer)")

        updateActiveActivityTimer?.invalidate()
    }


    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewWillLayoutSubviews")

        var width = CGRectGetWidth(self.view.frame)
        var height = CGRectGetHeight(self.view.frame) - 50

        var lastview: UIView

        exitButton.frame = CGRectMake(0, 25, 70, 30)
        lastview = exitButton

        sessionNameView.frame = CGRectMake(70, 25, width-70, 30)
        lastview = sessionNameView

        taskEntriesBGView.frame = CGRectMake(0, 55, width, height - 55)
        lastview = taskEntriesBGView

        width = CGRectGetWidth(taskEntriesBGView.frame)
        height = CGRectGetHeight(taskEntriesBGView.frame)
        let padding = 1

        infoAreaView.frame = CGRectMake(CGFloat(padding), CGFloat(padding), width - 2*CGFloat(padding), 30)
        lastview = infoAreaView

        signInSignOutView.frame = CGRectMake(CGFloat(padding), CGRectGetMaxY(lastview.frame) + CGFloat(padding), width - 2*CGFloat(padding), 30)
        lastview = signInSignOutView

        taskEntriesTableView.frame = CGRectMake(CGFloat(padding), CGRectGetMaxY(lastview.frame) + CGFloat(padding), width - 2*CGFloat(padding), height - CGRectGetMaxY(lastview.frame) - 3*CGFloat(padding) - 30)
        lastview = taskEntriesTableView

        addView.frame = CGRectMake(CGFloat(padding), CGRectGetMaxY(lastview.frame) + CGFloat(padding), width - 2*CGFloat(padding), 30)
        lastview = addView

        // This was originally in viewWillAppear, but it seems that viewWillAPpear will be called
        // when changing session (PageController) and then, when changing TabBar, it will NOT
        // be called. 
        // viewWillLayoutSubviews is always called, often several times.

        self.sessionSummary = (0,0)
        self.sessionSummary = session?.getSessionSummary(moc)
        redrawAfterSegue()
        scrollToEnd(taskEntriesTableView)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewDidLayoutSubviews")

        // Inset to left edge on cells with text
        taskEntriesTableView.separatorInset = UIEdgeInsetsZero

        // Inset to left edge on empty cells
        taskEntriesTableView.layoutMargins = UIEdgeInsetsZero
    }

    //-----------------------------------------
    // TaskEntryCreatorByAddToList - GUI actions
    //-----------------------------------------


    func exit(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "exit")
        appLog.log(logger, logtype: .GUIAction, message: "exit")
        
        performSegueWithIdentifier("Exit", sender: self)
    }

    func useTemplate(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "useTemplate")
        appLog.log(logger, logtype: .GUIAction, message: "useTemplate")

        performSegueWithIdentifier("UseTemplate", sender: self)
    }

    func switchOngoingFinished(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "switchOngoingFinished")
        appLog.log(logger, logtype: .GUIAction, message: "switchOngoingFinished")

        signInSignOutView.setNeedsDisplay()
        infoAreaView.setNeedsDisplay()

        guard let w = session?.getLastTaskEntry() else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in switchOngoingFinished")
            return
        }

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
        taskEntriesTableView.reloadData()
        scrollToEnd(taskEntriesTableView)
    }
    
    func addTaskEntry(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "addTaskEntry")
        appLog.log(logger, logtype: .GUIAction, message: "addTaskEntry")

        guard let s = session else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in addTaskEntry")
            return
        }

        let now = NSDate()
        var task = s.tasks[0] as! Task
        if let lastTaskEntry = s.getLastTaskEntry() {
            task = lastTaskEntry.task
            if lastTaskEntry.isOngoing() {
                lastTaskEntry.setStoppedAt(now)
                var (activations, totalTime) = sessionSummary
                activations++
                totalTime += lastTaskEntry.stopTime.timeIntervalSinceDate(lastTaskEntry.startTime)
                sessionSummary = (activations, totalTime)
            }
        }

        TaskEntry.createInMOC(moc, name: "", session: s, task: task)
        TimePoliceModelUtils.save(moc)

        gap2taskEntry = []
        if let s = session,
            wl = s.taskEntries.array as? [TaskEntry] {
            gap2taskEntry = TimePoliceModelUtils.getGap2TaskEntry(wl)
        }

        taskEntriesTableView.reloadData()
        scrollToEnd(taskEntriesTableView)

        signInSignOutView.setNeedsDisplay()
        infoAreaView.setNeedsDisplay()
    }

    //-----------------------------------------
    // TaskEntryCreatorByAddToList - UITableViewDelegate
    //-----------------------------------------

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cellString = ""
        if let cell = tableView.cellForRowAtIndexPath(indexPath),
            s = cell.textLabel?.text {
                cellString = s
        }

        appLog.log(logger, logtype: .EnterExit, message: "tableView.didSelectRowAtIndexPath")
        appLog.log(logger, logtype: .GUIAction, message: "tableView.didSelectRowAtIndexPath(\(cellString))")

        //GAP: Use a popover for a gap, continue if not a gap
        if indexPath.row >= gap2taskEntry.count {
            appLog.log(logger, logtype: .Guard, message: "check fail in tableView:didSelectRowAtIndexPath [taskENtryIndex out of bounds]")
            
            return
        }

        if gap2taskEntry[indexPath.row] == -1 {
            appLog.log(logger, logtype: .Guard, message: "check fail in tableView:didSelectRowAtIndexPath [taskEntryIndex=gap]")
            
            // A gap is never first or last in the list => There is always a choice between fill with previous or next
            
            let alertContoller = UIAlertController(title: "Delete gap", message: nil,
                preferredStyle: .ActionSheet)
            
            let fillWithPreviousAction = UIAlertAction(title: "...fill with previous", style: .Default,
                handler: { action in
                    self.handleDeleteFillWithPrevious(indexPath.row)
                })
            alertContoller.addAction(fillWithPreviousAction)
            
            let fillWithNextAction = UIAlertAction(title: "...fill with next", style: .Default,
                handler: { action in
                    self.handleDeleteFillWithNext(indexPath.row)
                })
            alertContoller.addAction(fillWithNextAction)
            
            let cancel = UIAlertAction(title: "Cancel", style: .Cancel,
                handler: { action in
                    if let indexPath = self.taskEntriesTableView.indexPathForSelectedRow {
                        self.taskEntriesTableView.deselectRowAtIndexPath(indexPath, animated: true)
                    }
                })
            alertContoller.addAction(cancel)
            
            presentViewController(alertContoller, animated: true, completion: nil)
            
            return
        }
        let taskEntryIndex = gap2taskEntry[indexPath.row]

        guard let te = session?.taskEntries[taskEntryIndex] as? TaskEntry else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in tableView:didSelectRowAtIndexPath [taskentry]")
            return
        }

        selectedTaskEntry = te
        selectedTaskEntryIndex = taskEntryIndex
        
        appLog.log(logger, logtype: .Debug) { "selected(row=\(taskEntryIndex), taskentry=\(te.task.name))" }

        performSegueWithIdentifier("EditTaskEntry", sender: self)
    }

    func handleDeleteFillWithPrevious(index: Int) {
        appLog.log(logger, logtype: .Debug, message: "Fill with previous")
        if let s = session {
            let previousTaskEntryIndex = gap2taskEntry[index-1]
            let nextTaskEntryIndex = gap2taskEntry[index+1]
            let nextStartTime = s.taskEntries[nextTaskEntryIndex].startTime
            s.setStopTime(moc, taskEntryIndex: previousTaskEntryIndex, desiredStopTime: nextStartTime)
            redrawAfterSegue()
        }
    }

    func handleDeleteFillWithNext(index: Int) {
        appLog.log(logger, logtype: .Debug, message: "Fill with next")

        if let s = session {
            let previousTaskEntryIndex = gap2taskEntry[index-1]
            let nextTaskEntryIndex = gap2taskEntry[index+1]
            let previousStopTime = s.taskEntries[previousTaskEntryIndex].stopTime
            s.setStartTime(moc, taskEntryIndex: nextTaskEntryIndex, desiredStartTime: previousStopTime)
            redrawAfterSegue()
        }
    }
    
    //-----------------------------------------
    // TaskEntryCreatorByAddToList - UITableViewDataSource
    //-----------------------------------------

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //GAP: Include gaps in count
        if let _ = session?.taskEntries {
            return gap2taskEntry.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TaskEntriesCell")!

        //GAP: Special handling for gaps, should return a cell with other formatting
        if indexPath.row >= gap2taskEntry.count {
            appLog.log(logger, logtype: .Guard, message: "guard fail in tableView:didSelectRowAtIndexPath [taskEntryIndex]")
            return cell
        }
        
        let taskEntryIndex = gap2taskEntry[indexPath.row]
        
        if taskEntryIndex == -1 {
            cell.textLabel?.text = "---"

            cell.backgroundColor = UIColor(white:0.2, alpha:1.0)
            cell.textLabel?.textColor = UIColor(white: 0.5, alpha: 1.0)
            cell.textLabel?.adjustsFontSizeToFitWidth = true

            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero

            cell.imageView?.image = nil

            return cell
        }

        guard let w = session?.taskEntries[taskEntryIndex] as? TaskEntry else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in tableView:cellForRowAtIndexPath")
            return cell
        }

        if w.isStopped() {
            let timeForTaskEntry = w.stopTime.timeIntervalSinceDate(w.startTime)
            cell.textLabel?.text = "\(w.task.name) \(UtilitiesDate.getStringNoDate(w.startTime))->\(UtilitiesDate.getStringNoDate(w.stopTime)) = \(UtilitiesDate.getString(timeForTaskEntry))\n"
        } else {
            cell.textLabel?.text = "\(w.task.name) \(UtilitiesDate.getStringNoDate(w.startTime))->(ongoing) = ------\n"
        }     
        if let colorString = w.task.getProperty("color") {
            let color = UtilitiesColor.string2color(colorString)
            
            cell.imageView?.image = UtilitiesImage.getImageWithColor(color, width: 10.0, height: 10.0)
        }

        cell.backgroundColor = UIColor(white:0.3, alpha:1.0)
        cell.textLabel?.textColor = UIColor(white: 1.0, alpha: 1.0)
        cell.textLabel?.adjustsFontSizeToFitWidth = true

        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero

        return cell
    }


    //----------------------------------------------
    //  TaskEntryCreatorByAddToList - ToolbarInfoDelegate
    //----------------------------------------------

    func getToolbarInfo() -> ToolbarInfo {
        appLog.log(logger, logtype: .PeriodicCallback, message: "getToolbarInfo")

        var (totalActivations, totalTime) = sessionSummary

        var signedIn = false
        var sessionName = "---"

        if let s = session {

            sessionName = s.getDisplayNameWithSuffix()

            if let taskEntry = s.getLastTaskEntry() {
                if taskEntry.isOngoing() {
                    signedIn = true

                    let now = NSDate()
                    if(now.compare(taskEntry.startTime) == .OrderedDescending) {
                        let timeForActiveTask = NSDate().timeIntervalSinceDate(taskEntry.startTime)
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
    // TaskEntryCreatorByAddToList - Segue handling
    //---------------------------------------------
    
    // See base class

    override func redrawAfterSegue() {
        //GAP: Update list of gaps, there may be new ones, or old ones may be "removed"
        gap2taskEntry = []
        if let s = session,
            wl = s.taskEntries.array as? [TaskEntry] {
            gap2taskEntry = TimePoliceModelUtils.getGap2TaskEntry(wl)
        }

        taskEntriesTableView.reloadData()
        signInSignOutView.setNeedsDisplay()
        infoAreaView.setNeedsDisplay()
        sessionNameView.setNeedsDisplay()
    }
        

    //--------------------------------------------------------------
    // TaskEntryCreatorByAddToList - Periodic update of views, triggered by timeout
    //--------------------------------------------------------------

    var updateN = 0

    @objc
    func updateActiveTask(timer: NSTimer) {
        appLog.log(logger, logtype: .PeriodicCallback, message: "updateActiveTask")
        infoAreaView.setNeedsDisplay()
    }

    //---------------------------------------------
    // TaskEntryCreatorByAddToList - Utility functions
    //---------------------------------------------


    func scrollToEnd(tableView: UITableView) {
        let numberOfSections = tableView.numberOfSections
        let numberOfRows = tableView.numberOfRowsInSection(numberOfSections-1)
        
        if numberOfRows > 0 {
            let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
        
    }

}

