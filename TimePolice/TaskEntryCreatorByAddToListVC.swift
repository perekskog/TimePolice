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

    var taskEntriesTableView = UITableView(frame: CGRect.zero, style: .plain)

    var sessionLabel: UILabel?

    var selectedTaskEntry: TaskEntry?


    // Cached values, calculated at startup
    var sessionSummary: (Int, TimeInterval) = (0,0)

    var updateActiveActivityTimer: Timer?

    let exitButton = UIButton(type: UIButtonType.system)
    let sessionNameView = TaskEntriesToolView()
    let pageIndicatorView = TaskPickerPageIndicatorView()
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
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidLoad")

        (self.view as! TimePoliceBGView).theme = theme

        //GAP: Update list of gaps
        gap2taskEntry = []
        if let s = session,
            let wl = s.taskEntries.array as? [TaskEntry] {
            gap2taskEntry = TimePoliceModelUtils.getGap2TaskEntry(wl)
        }
        var s = ""
        for i in gap2taskEntry {
            s += "\(i)\t"
        }
        appLog.log(logger, logtype: .debug, message: s)

        exitButton.backgroundColor = UIColor(red: 0.0, green: 0.4, blue: 0.0, alpha: 1.0)
        exitButton.setTitleColor(UIColor.white, for: UIControlState())
        exitButton.setTitle("EXIT", for: UIControlState())
        exitButton.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(themeBigTextSize))
        exitButton.addTarget(self, action: #selector(TaskEntryCreatorByAddToListVC.exit(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(exitButton)

        sessionNameView.theme = theme
        sessionNameView.tool = .sessionName
        sessionNameView.toolbarInfoDelegate = self
        var recognizer = UITapGestureRecognizer(target:self, action:#selector(TaskEntryCreatorByAddToListVC.useTemplate(_:)))
        recognizer.delegate = self
        sessionNameView.addGestureRecognizer(recognizer)
        self.view.addSubview(sessionNameView)

        pageIndicatorView.theme = theme
        self.view.addSubview(pageIndicatorView)

        taskEntriesBGView.theme = theme
        self.view.addSubview(taskEntriesBGView)

        infoAreaView.theme = theme
        infoAreaView.toolbarInfoDelegate = self
        infoAreaView.tool = .infoArea
        taskEntriesBGView.addSubview(infoAreaView)

        signInSignOutView.theme = theme
        signInSignOutView.toolbarInfoDelegate = self
        signInSignOutView.tool = .signInSignOut
        recognizer = UITapGestureRecognizer(target:self, action:#selector(TaskEntryCreatorByAddToListVC.switchOngoingFinished(_:)))
        recognizer.delegate = self
        signInSignOutView.addGestureRecognizer(recognizer)
        taskEntriesBGView.addSubview(signInSignOutView)


        taskEntriesTableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "TaskEntriesCell")
        taskEntriesTableView.dataSource = self
        taskEntriesTableView.delegate = self
        taskEntriesTableView.rowHeight = CGFloat(selectItemTableRowHeight)
        taskEntriesTableView.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
        taskEntriesTableView.separatorColor = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
        taskEntriesBGView.addSubview(taskEntriesTableView)

        addView.theme = theme
        addView.toolbarInfoDelegate = self
        addView.tool = .add
        recognizer = UITapGestureRecognizer(target:self, action:#selector(TaskEntryCreatorByAddToListVC.addTaskEntry(_:)))
        recognizer.delegate = self
        addView.addGestureRecognizer(recognizer)
        taskEntriesBGView.addSubview(addView)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewWillAppear")


        if let indexPath = taskEntriesTableView.indexPathForSelectedRow {
            taskEntriesTableView.deselectRow(at: indexPath, animated: true)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidAppear")

        // This was originally in viewWillAppear, but it seems that viewWillAppear will be called
        // when changing session (PageController) and then, when changing TabBar, it will NOT
        // be called. 
        // viewDidAppear is always called.

        updateActiveActivityTimer = Timer.scheduledTimer(timeInterval: 1,
                target: self,
              selector: #selector(TaskEntryCreatorByAddToListVC.updateActiveTask(_:)),
              userInfo: nil,
               repeats: true)        

        appLog.log(logger, logtype: .resource, message: "starting timer \(String(describing: updateActiveActivityTimer))")

        self.sessionSummary = (0,0)
        if let s = session?.getSessionSummary(moc) {
            self.sessionSummary = s
        }
        redrawAfterSegue()
        scrollToEnd(taskEntriesTableView)
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewWillDisappear")
    }


    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidDisappear")

        appLog.log(logger, logtype: .resource, message: "stopping timer \(String(describing: updateActiveActivityTimer))")

        updateActiveActivityTimer?.invalidate()
    }


    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        appLog.log(logger, logtype: .viewLifecycle, message: "viewWillLayoutSubviews")

        var width = self.view.frame.width
        var height = self.view.frame.height - 50

        var lastview: UIView

        exitButton.frame = CGRect(x: 0, y: 25, width: 70, height: CGFloat(minimumComponentHeight))
        lastview = exitButton

        sessionNameView.frame = CGRect(x: 70, y: 25, width: width-70, height: CGFloat(minimumComponentHeight) - 5)
        sessionNameView.toolbarInfoDelegate = self

        pageIndicatorView.frame = CGRect(x: 70, y: 25 + CGFloat(minimumComponentHeight) - 5, width: width-70, height: 5)
        pageIndicatorView.toolbarInfoDelegate = self
        lastview = pageIndicatorView

        taskEntriesBGView.frame = CGRect(x: 0, y: 25 + CGFloat(minimumComponentHeight), width: width, height: height - 25 - CGFloat(minimumComponentHeight))
        lastview = taskEntriesBGView

        width = taskEntriesBGView.frame.width
        height = taskEntriesBGView.frame.height
        let padding = 1

        infoAreaView.frame = CGRect(x: CGFloat(padding), y: CGFloat(padding), width: width - 2*CGFloat(padding), height: CGFloat(minimumComponentHeight))
        lastview = infoAreaView

        signInSignOutView.frame = CGRect(x: CGFloat(padding), y: lastview.frame.maxY + CGFloat(padding), width: width - 2*CGFloat(padding), height: CGFloat(minimumComponentHeight))
        lastview = signInSignOutView

        taskEntriesTableView.frame = CGRect(x: CGFloat(padding), y: lastview.frame.maxY + CGFloat(padding), width: width - 2*CGFloat(padding), height: height - lastview.frame.maxY - 3*CGFloat(padding) - CGFloat(minimumComponentHeight))
        lastview = taskEntriesTableView

        addView.frame = CGRect(x: CGFloat(padding), y: lastview.frame.maxY + CGFloat(padding), width: width - 2*CGFloat(padding), height: CGFloat(minimumComponentHeight))
        lastview = addView

        // This was originally in viewWillAppear, but it seems that viewWillAPpear will be called
        // when changing session (PageController) and then, when changing TabBar, it will NOT
        // be called. 
        // viewWillLayoutSubviews is always called, often several times.

        self.sessionSummary = (0,0)
        if let s = session?.getSessionSummary(moc) {
            self.sessionSummary = s
        }
        redrawAfterSegue()
        scrollToEnd(taskEntriesTableView)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidLayoutSubviews")

        // Inset to left edge on cells with text
        taskEntriesTableView.separatorInset = UIEdgeInsets.zero

        // Inset to left edge on empty cells
        taskEntriesTableView.layoutMargins = UIEdgeInsets.zero
    }

    //-----------------------------------------
    // TaskEntryCreatorByAddToList - GUI actions
    //-----------------------------------------


    @objc func exit(_ sender: UIButton) {
        appLog.log(logger, logtype: .enterExit, message: "exit")
        appLog.log(logger, logtype: .guiAction, message: "exit")
        
        performSegue(withIdentifier: "Exit", sender: self)
    }

    @objc func useTemplate(_ sender: UIButton) {
        appLog.log(logger, logtype: .enterExit, message: "useTemplate")
        appLog.log(logger, logtype: .guiAction, message: "useTemplate")

        performSegue(withIdentifier: "UseTemplate", sender: self)
    }

    @objc func switchOngoingFinished(_ sender: UIButton) {
        appLog.log(logger, logtype: .enterExit, message: "switchOngoingFinished")
        appLog.log(logger, logtype: .guiAction, message: "switchOngoingFinished")

        signInSignOutView.setNeedsDisplay()
        infoAreaView.setNeedsDisplay()

        guard let w = session?.getLastTaskEntry() else {
            appLog.log(logger, logtype: .guard, message: "guard fail in switchOngoingFinished")
            return
        }

        if w.isOngoing() {
            w.setStoppedAt(Date())
            var (activations, totalTime) = sessionSummary
            activations += 1
            totalTime += w.stopTime.timeIntervalSince(w.startTime)
            sessionSummary = (activations, totalTime)
        } else {
            var (activations, totalTime) = sessionSummary
            activations -= 1
            totalTime -= w.stopTime.timeIntervalSince(w.startTime)
            sessionSummary = (activations, totalTime)
            w.setAsOngoing()
        }
        taskEntriesTableView.reloadData()
        scrollToEnd(taskEntriesTableView)
    }
    
    @objc func addTaskEntry(_ sender: UIButton) {
        appLog.log(logger, logtype: .enterExit, message: "addTaskEntry")
        appLog.log(logger, logtype: .guiAction, message: "addTaskEntry")

        guard let s = session else {
            appLog.log(logger, logtype: .guard, message: "guard fail in addTaskEntry")
            return
        }

        let now = Date()
        var task = s.tasks[0] as! Task
        if let lastTaskEntry = s.getLastTaskEntry() {
            task = lastTaskEntry.task
            if lastTaskEntry.isOngoing() {
                lastTaskEntry.setStoppedAt(now)
                var (activations, totalTime) = sessionSummary
                activations += 1
                totalTime += lastTaskEntry.stopTime.timeIntervalSince(lastTaskEntry.startTime)
                sessionSummary = (activations, totalTime)
            }
        }

        _ = TaskEntry.createInMOC(moc, name: "", session: s, task: task)
        TimePoliceModelUtils.save(moc)

        gap2taskEntry = []
        if let s = session,
            let wl = s.taskEntries.array as? [TaskEntry] {
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var cellString = ""
        if let cell = tableView.cellForRow(at: indexPath),
            let s = cell.textLabel?.text {
                cellString = s
        }

        appLog.log(logger, logtype: .enterExit, message: "tableView.didSelectRowAtIndexPath")
        appLog.log(logger, logtype: .guiAction, message: "tableView.didSelectRowAtIndexPath(\(cellString))")

        //GAP: Use a popover for a gap, continue if not a gap
        if indexPath.row >= gap2taskEntry.count {
            appLog.log(logger, logtype: .guard, message: "check fail in tableView:didSelectRowAtIndexPath [taskENtryIndex out of bounds]")
            
            return
        }

        if gap2taskEntry[indexPath.row] == -1 {
            appLog.log(logger, logtype: .guard, message: "check fail in tableView:didSelectRowAtIndexPath [taskEntryIndex=gap]")
            
            // A gap is never first or last in the list => There is always a choice between fill with previous or next
            
            let alertContoller = UIAlertController(title: "Delete gap", message: nil,
                preferredStyle: .actionSheet)
            
            let fillWithPreviousAction = UIAlertAction(title: "...fill with previous", style: .default,
                handler: { action in
                    self.handleDeleteFillWithPrevious(indexPath.row)
                })
            alertContoller.addAction(fillWithPreviousAction)
            
            let fillWithNextAction = UIAlertAction(title: "...fill with next", style: .default,
                handler: { action in
                    self.handleDeleteFillWithNext(indexPath.row)
                })
            alertContoller.addAction(fillWithNextAction)
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel,
                handler: { action in
                    if let indexPath = self.taskEntriesTableView.indexPathForSelectedRow {
                        self.taskEntriesTableView.deselectRow(at: indexPath, animated: true)
                    }
                })
            alertContoller.addAction(cancel)
            
            present(alertContoller, animated: true, completion: nil)
            
            return
        }
        let taskEntryIndex = gap2taskEntry[indexPath.row]

        guard let te = session?.taskEntries[taskEntryIndex] as? TaskEntry else {
            appLog.log(logger, logtype: .guard, message: "guard fail in tableView:didSelectRowAtIndexPath [taskentry]")
            return
        }

        selectedTaskEntry = te
        selectedTaskEntryIndex = taskEntryIndex
        
        appLog.log(logger, logtype: .debug) { "selected(row=\(taskEntryIndex), taskentry=\(te.task.name))" }

        performSegue(withIdentifier: "EditTaskEntry", sender: self)
    }

    func handleDeleteFillWithPrevious(_ index: Int) {
        appLog.log(logger, logtype: .debug, message: "Fill with previous")
        if let s = session {
            let previousTaskEntryIndex = gap2taskEntry[index-1]
            let nextTaskEntryIndex = gap2taskEntry[index+1]
            let nextStartTime = (s.taskEntries[nextTaskEntryIndex] as AnyObject).startTime
            s.setStopTime(moc, taskEntryIndex: previousTaskEntryIndex, desiredStopTime: nextStartTime!)
            redrawAfterSegue()
        }
    }

    func handleDeleteFillWithNext(_ index: Int) {
        appLog.log(logger, logtype: .debug, message: "Fill with next")

        if let s = session {
            let previousTaskEntryIndex = gap2taskEntry[index-1]
            let nextTaskEntryIndex = gap2taskEntry[index+1]
            let previousStopTime = (s.taskEntries[previousTaskEntryIndex] as AnyObject).stopTime
            s.setStartTime(moc, taskEntryIndex: nextTaskEntryIndex, desiredStartTime: previousStopTime!)
            redrawAfterSegue()
        }
    }
    
    //-----------------------------------------
    // TaskEntryCreatorByAddToList - UITableViewDataSource
    //-----------------------------------------

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //GAP: Include gaps in count
        if let _ = session?.taskEntries {
            return gap2taskEntry.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskEntriesCell")!

        //GAP: Special handling for gaps, should return a cell with other formatting
        if indexPath.row >= gap2taskEntry.count {
            appLog.log(logger, logtype: .guard, message: "guard fail in tableView:didSelectRowAtIndexPath [taskEntryIndex]")
            return cell
        }
        
        let taskEntryIndex = gap2taskEntry[indexPath.row]
        
        if taskEntryIndex == -1 {
            cell.textLabel?.text = "---"

            cell.backgroundColor = UIColor(white:0.2, alpha:1.0)
            cell.textLabel?.textColor = UIColor(white: 0.5, alpha: 1.0)
            cell.textLabel?.adjustsFontSizeToFitWidth = true

//            cell.separatorInset = UIEdgeInsetsZero
//            cell.layoutMargins = UIEdgeInsetsZero

            cell.imageView?.image = nil

            return cell
        }

        guard let w = session?.taskEntries[taskEntryIndex] as? TaskEntry else {
            appLog.log(logger, logtype: .guard, message: "guard fail in tableView:cellForRowAtIndexPath")
            return cell
        }

        if w.isStopped() {
            let timeForTaskEntry = w.stopTime.timeIntervalSince(w.startTime)
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

//        cell.separatorInset = UIEdgeInsetsZero
//        cell.layoutMargins = UIEdgeInsetsZero

        return cell
    }


    //----------------------------------------------
    //  TaskEntryCreatorByAddToList - ToolbarInfoDelegate
    //----------------------------------------------

    func getToolbarInfo() -> ToolbarInfo {
        appLog.log(logger, logtype: .periodicCallback, message: "getToolbarInfo")

        var (totalActivations, totalTime) = sessionSummary

        var signedIn = false
        var sessionName = "---"

        if let s = session {

            sessionName = s.getDisplayNameWithSuffix()

            if let taskEntry = s.getLastTaskEntry() {
                if taskEntry.isOngoing() {
                    signedIn = true

                    let now = Date()
                    if(now.compare(taskEntry.startTime) == .orderedDescending) {
                        let timeForActiveTask = Date().timeIntervalSince(taskEntry.startTime)
                        totalTime += timeForActiveTask
                    }
                }
            }
        }
        
        var currentPage = 0
        if let n = sessionIndex {
            currentPage = n
        }
        
        var numberOfPages = 1
        if let n = numberOfSessions {
            numberOfPages = n
        }
        
        let toolbarInfo = ToolbarInfo(
            signedIn: signedIn,
            totalTimesActivatedForSession: totalActivations,
            totalTimeActiveForSession: totalTime,
            sessionName: sessionName,
            numberOfPages: numberOfPages,
            currentPage: currentPage)

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
            let wl = s.taskEntries.array as? [TaskEntry] {
            gap2taskEntry = TimePoliceModelUtils.getGap2TaskEntry(wl)
        }

        taskEntriesTableView.reloadData()
        signInSignOutView.setNeedsDisplay()
        infoAreaView.setNeedsDisplay()
        sessionNameView.setNeedsDisplay()
        pageIndicatorView.setNeedsDisplay()
    }
        

    //--------------------------------------------------------------
    // TaskEntryCreatorByAddToList - Periodic update of views, triggered by timeout
    //--------------------------------------------------------------

    var updateN = 0

    @objc
    func updateActiveTask(_ timer: Timer) {
        appLog.log(logger, logtype: .periodicCallback, message: "updateActiveTask")
        infoAreaView.setNeedsDisplay()
    }

    //---------------------------------------------
    // TaskEntryCreatorByAddToList - Utility functions
    //---------------------------------------------


    func scrollToEnd(_ tableView: UITableView) {
        let numberOfSections = tableView.numberOfSections
        let numberOfRows = tableView.numberOfRows(inSection: numberOfSections-1)
        
        if numberOfRows > 0 {
            let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
        }
        
    }

}

