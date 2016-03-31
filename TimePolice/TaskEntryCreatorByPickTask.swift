//
//  TaskEntryCreatorByPickTaskVC.swift
//  TimePolice
//
//  Created by Per Ekskog on 2014-11-04.
//  Copyright (c) 2014 Per Ekskog. All rights reserved.
//


/* 

TODO

*/

import UIKit
import CoreData

//==================================================
//==================================================
//  TaskEntryCreatorByPickTask
//==================================================

class TaskEntryCreatorByPickTaskVC:
        TaskEntryCreatorBase,
        ToolbarInfoDelegate,
        SelectionAreaInfoDelegate,
        UIGestureRecognizerDelegate
	{

    let exitButton = UIButton(type: UIButtonType.System)
    let sessionNameView = TaskPickerToolView()
    let pageIndicatorView = TaskPickerPageIndicatorView()
    let signInSignOutView = TaskPickerToolView()
    let infoAreaView = TaskPickerToolView()

    let taskPickerBGView = TaskPickerBGView()

    var layout: Layout?

    var sessionTaskSummary: [Task: (Int, NSTimeInterval)] = [:]

    var recognizers: [UIGestureRecognizer: Int] = [:]
    var taskbuttonviews: [Int: TaskPickerButtonView] = [:]

    var updateActiveActivityTimer: NSTimer?
    
    let theme = BlackGreenTheme()
//        let theme = BasicTheme()

    let taskSelectionStrategy = TaskSelectAny()


    //---------------------------------------------
    // TaskEntryCreatorByPickTask - AppLoggerDataSource
    //---------------------------------------------

    override
    func getLogDomain() -> String {
        return "TaskEntryCreatorByPickTask"
    }


    //---------------------------------------------
    // TaskEntryCreatorByPickTask - View lifecycle
    //---------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        logger.datasource = self
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewDidLoad")

        (self.view as! TimePoliceBGView).theme = theme

        exitButton.backgroundColor = UIColor(red: 0.0, green: 0.4, blue: 0.0, alpha: 1.0)
        exitButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        exitButton.setTitle("EXIT", forState: UIControlState.Normal)
        exitButton.titleLabel?.font = UIFont.systemFontOfSize(CGFloat(themeBigTextSize))
        exitButton.addTarget(self, action: #selector(TaskEntryCreatorByPickTaskVC.exit(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(exitButton)

        sessionNameView.theme = theme
        sessionNameView.tool = .SessionName
        var recognizer = UITapGestureRecognizer(target:self, action:#selector(TaskEntryCreatorByPickTaskVC.useTemplate(_:)))
        recognizer.delegate = self
        sessionNameView.addGestureRecognizer(recognizer)
        self.view.addSubview(sessionNameView)

        pageIndicatorView.theme = theme
        self.view.addSubview(pageIndicatorView)
                
        taskPickerBGView.theme = theme
        self.view.addSubview(taskPickerBGView)

        signInSignOutView.theme = theme
        signInSignOutView.toolbarInfoDelegate = self
        signInSignOutView.tool = .SignInSignOut
        recognizer = UITapGestureRecognizer(target:self, action:#selector(TaskEntryCreatorByPickTaskVC.handleTapSigninSignout(_:)))
        signInSignOutView.addGestureRecognizer(recognizer)
        taskPickerBGView.addSubview(signInSignOutView)
            
        infoAreaView.theme = theme
        infoAreaView.toolbarInfoDelegate = self
        infoAreaView.tool = .InfoArea
        taskPickerBGView.addSubview(infoAreaView)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewWillAppear")

        for (_, v) in taskbuttonviews {
            if let rr = v.gestureRecognizers {
                for r in rr {
                    v.removeGestureRecognizer(r)
                }
            }
            v.removeFromSuperview()
        }

        recognizers = [:]
        taskbuttonviews = [:]

        guard let s = session else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in viewWillAppear")
            return
        }

        let padding: CGFloat = 1
        let toolHeight: CGFloat = CGFloat(minimumComponentHeight)

        var columns: Int = 1 + s.tasks.count/10

        if let cols = s.getProperty("columns"),
            c = Int(cols) {
                columns = c
        }

        var rows: Int = s.tasks.count/columns
        if s.tasks.count % columns > 0 {
            rows += 1
        }

        layout = GridLayout(rows: rows, columns: columns, padding: padding, toolHeight: toolHeight)
        
        self.sessionTaskSummary = s.getSessionTaskSummary(false)

        guard let tl = s.tasks.array as? [Task],
            l = layout else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in viewWillAppear 2")
            return
        }

        let numberOfButtonsToDraw = l.numberOfSelectionAreas()
        let numberOfTasksInSession = tl.count
        for i in 0..<numberOfButtonsToDraw {
            let view = TaskPickerButtonView()
            view.theme = theme
            view.frame = l.getViewRect(taskPickerBGView.frame, buttonNumber: i)


            view.selectionAreaInfoDelegate = self
            view.taskPosition = i

            if i < numberOfTasksInSession {

                if tl[i].name != spacerName {
                
                    let tapRecognizer = UITapGestureRecognizer(target:self, action:#selector(TaskEntryCreatorByPickTaskVC.handleTapTask(_:)))
                    tapRecognizer.delegate = self
                    view.addGestureRecognizer(tapRecognizer)
                    recognizers[tapRecognizer] = i
                    
                    let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(TaskEntryCreatorByPickTaskVC.handleLongPressTask(_:)))
                    tapRecognizer.delegate = self
                    view.addGestureRecognizer(longPressRecognizer)
                    recognizers[longPressRecognizer] = i
                }
            }
                
            taskbuttonviews[i] = view
            taskPickerBGView.addSubview(view)
        }

        redrawAfterSegue()
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
            selector: #selector(TaskEntryCreatorByPickTaskVC.updateActiveTask(_:)),
            userInfo: nil,
            repeats: true)

        appLog.log(logger, logtype: .Resource, message: "starting timer \(updateActiveActivityTimer)")
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

        let width = CGRectGetWidth(self.view.frame)
        let height = CGRectGetHeight(self.view.frame) - 50

        exitButton.frame = CGRectMake(0, 25, 70, CGFloat(minimumComponentHeight))
        
        sessionNameView.frame = CGRectMake(70, 25, width-70, CGFloat(minimumComponentHeight) - 5)
        sessionNameView.toolbarInfoDelegate = self

        pageIndicatorView.frame = CGRectMake(70, 25 + CGFloat(minimumComponentHeight) - 5, width-70, 5)
        pageIndicatorView.toolbarInfoDelegate = self

        taskPickerBGView.frame = CGRectMake(0, 25 + CGFloat(minimumComponentHeight), width, height - 25 - CGFloat(minimumComponentHeight))

        guard let l = layout else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in viewWillLayoutSubviews")
            return
        }

        let numberOfButtonsToDraw = l.numberOfSelectionAreas()
        for i in 0..<numberOfButtonsToDraw {
            if let v = taskbuttonviews[i] {
                v.frame = l.getViewRect(taskPickerBGView.frame, buttonNumber: i)
            }
        }

        signInSignOutView.frame = l.getViewRectSignInSignOut(taskPickerBGView.frame)
        infoAreaView.frame = l.getViewRectInfo(taskPickerBGView.frame)

    }




    //---------------------------------------------
    // TaskEntryCreatorByPickTask - GUI actions
    //---------------------------------------------

    func exit(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "exit")
        appLog.log(logger, logtype: .GUIAction, message: "exit")

        updateActiveActivityTimer?.invalidate()
        performSegueWithIdentifier("Exit", sender: self)
    }

    func useTemplate(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "useTemplate")
        appLog.log(logger, logtype: .GUIAction, message: "useTemplate")

        performSegueWithIdentifier("UseTemplate", sender: self)
    }

    func handleTapSigninSignout(sender: UITapGestureRecognizer) {
        appLog.log(logger, logtype: .EnterExit, message: "handleTapSigninSignout")
        appLog.log(logger, logtype: .GUIAction, message: "handleTapSigninSignout")

        signInSignOutView.setNeedsDisplay()
        infoAreaView.setNeedsDisplay()

        guard let s = session,
                taskList = s.tasks.array as? [Task],
                taskEntry = s.getLastTaskEntry() else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in handleTapSigninSignout")
            return
        }

        if taskEntry.isOngoing() {
            setLastTaskEntryAsFinished()
        } else {
            setLastTaskEntryAsOngoing()
        }
        if let taskIndex = taskList.indexOf(taskEntry.task as Task) {
            taskbuttonviews[taskIndex]?.setNeedsDisplay()
        }

        appLog.log(logger, logtype: .EnterExit) { TimePoliceModelUtils.getSessionTaskEntries(s) }
    }

    func handleTapTask(sender: UITapGestureRecognizer) {
        appLog.log(logger, logtype: .EnterExit, message: "handleTap")

        signInSignOutView.setNeedsDisplay()
        infoAreaView.setNeedsDisplay()

        guard let s = session,
                taskList = s.tasks.array as? [Task] else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in handleTapTask")
            return
        }

        // Handle ongoing task
        if let taskEntry = s.getLastTaskEntry() {
            if let taskIndex = taskList.indexOf(taskEntry.task as Task) {
                taskbuttonviews[taskIndex]?.setNeedsDisplay()
            }

            if taskEntry.isOngoing() {
                setLastTaskEntryAsFinished()
            }
        }

        // Handle new task
        let taskIndex = recognizers[sender]
        let task = taskList[taskIndex!]
        
        appLog.log(logger, logtype: .GUIAction, message: "handleTap(\(task.name))")

        addNewTaskEntry(task)
        taskbuttonviews[taskIndex!]?.setNeedsDisplay()

        appLog.log(logger, logtype: .CoreDataSnapshot) { TimePoliceModelUtils.getSessionTaskEntries(s) }
    }

    func handleLongPressTask(sender: UILongPressGestureRecognizer) {
        appLog.log(logger, logtype: .EnterExit, message: "handleLongPressTask")
        appLog.log(logger, logtype: .GUIAction, message: "handleLongPressTask")

        if sender.state != UIGestureRecognizerState.Began {
            return
        }

        guard let s = session,
                taskList = session?.tasks.array as? [Task] else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in handleLongPress 1")
            return
        }
        
        guard let taskEntry = s.getLastTaskEntry() else {
            appLog.log(logger, logtype: .EnterExit, message: "No last taskentry")
            appLog.log(logger, logtype: .Guard, message: "guard fail in handleLongPress 2")
            return
        }
        
        let taskPressedIndex = recognizers[sender]
        let taskPressed = taskList[taskPressedIndex!]
        if taskEntry.isOngoing() && taskEntry.task != taskPressed {
            appLog.log(logger, logtype: .EnterExit, message: "TaskEntry is ongoing, LongPress on inactive task")
            return
        }

        selectedTaskEntryIndex = s.taskEntries.count - 1

        performSegueWithIdentifier("EditTaskEntry", sender: self)
    }

    
    //---------------------------------------------
    // TaskEntryCreatorByPickTask - Segue handling (from base class)
    //---------------------------------------------
    
    override func redrawAfterSegue() {
        appLog.log(logger, logtype: .EnterExit, message: "redraw")

        if let s = session?.getSessionTaskSummary(false) {
            sessionTaskSummary = s
        }

        signInSignOutView.setNeedsDisplay()
        infoAreaView.setNeedsDisplay()
        sessionNameView.setNeedsDisplay()
        pageIndicatorView.setNeedsDisplay()

        for (_, view) in taskbuttonviews {
            view.setNeedsDisplay()
        }
    }

    //---------------------------------------------
    // TaskEntryCreatorByPickTask - GestureRecognizerDelegate
    //---------------------------------------------

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
        shouldReceiveTouch touch: UITouch) -> Bool {
            return true
            /*
            if let taskNumber = recognizers[gestureRecognizer] {
                return true //taskIsSelectable(taskNumber)
            } else {
                return true
            }
            */
    }


    //----------------------------------------------
    //  TaskEntryCreatorByPickTask - SelectionAreaInfoDelegate
    //----------------------------------------------

	func getSelectionAreaInfo(selectionArea: Int) -> SelectionAreaInfo {
        appLog.log(logger, logtype: .PeriodicCallback) { "getSelectionAreaInfo\(selectionArea)"}

        // This will only be called when there are selection areas setup 
        //  => there _is_ a session
        //  => There _is_ a task in the taskList
        
        let sai = SelectionAreaInfo()
        
        guard let s = session,
            taskList = s.tasks.array as? [Task] else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in getSelectionAreaInfo 1")
            return sai
        }

        if selectionArea >= 0 && selectionArea < taskList.count {
            let task = taskList[selectionArea]
            sai.task = task
            if let t = sessionTaskSummary[task] {
                let (numberOfTimesActivated, totalTimeActive) = t
                sai.numberOfTimesActivated = numberOfTimesActivated
                sai.totalTimeActive = totalTimeActive
            }
        }
        
        guard let taskEntry = s.getLastTaskEntry() else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in getSelectionAreaInfo getLastTaskEntry")
            return sai
        }

        if selectionArea >= 0 && selectionArea < taskList.count {
            if taskList[selectionArea] == taskEntry.task {
                sai.active = true
                sai.activatedAt = taskEntry.startTime
                if taskEntry.isOngoing() {
                    sai.ongoing = true
                } else {
                    sai.ongoing = false
                }
            } else {
                sai.active = false
                sai.ongoing = false
            }
        }
        
        return sai
	}

    //----------------------------------------------
    //  TaskEntryCreatorByPickTask - ToolbarInfoDelegate
    //----------------------------------------------

    func getToolbarInfo() -> ToolbarInfo {
        appLog.log(logger, logtype: .PeriodicCallback, message: "getToolbarInfo")
        
        var totalActivations: Int = 0 // The first task is active when first selected
        var totalTime: NSTimeInterval = 0
        
        for (_, (activations, time)) in sessionTaskSummary {
            totalActivations += activations
            totalTime += time
        }
        
        var signedIn = false
        if let taskEntry = session?.getLastTaskEntry() {
            if taskEntry.isOngoing() {
                signedIn = true
                
                let now = NSDate()
                if(now.compare(taskEntry.startTime) == .OrderedDescending) {
                    let timeForActiveTask = NSDate().timeIntervalSinceDate(taskEntry.startTime)
                    totalTime += timeForActiveTask
                }
            }
        }
        
        var sessionName = "---"
        if let s = session {
            sessionName = s.getDisplayNameWithSuffix()
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

    //--------------------------------------------
    //  TaskEntryCreatorByPickTask - Sign int/out, add new taskEntry
    //--------------------------------------------

    func addNewTaskEntry(task: Task) {
        appLog.log(logger, logtype: .EnterExit, message: "addTaskEntry")

        if let s = session {
            TaskEntry.createInMOC(moc, name: "", session: s, task: task)
            TimePoliceModelUtils.save(moc)
        }
    }

    func setLastTaskEntryAsFinished() {
        appLog.log(logger, logtype: .EnterExit, message: "setLastTaskEntryFinished")

        guard let taskEntry = session?.getLastTaskEntry() else {
            appLog.log(logger, logtype: .Debug, message: "no taskentry in list")
            appLog.log(logger, logtype: .Guard, message: "guard fail in setLastTaskEntryAsFinished")
            return
        }
        
        if taskEntry.isOngoing() {
            taskEntry.setStoppedAt(NSDate())

            var taskSummary: (Int, NSTimeInterval) = (0, 0)
            if let t = sessionTaskSummary[taskEntry.task] {
                taskSummary = t
            }
            var (numberOfTimesActivated, totalTimeActive) = taskSummary
            numberOfTimesActivated += 1
            totalTimeActive += taskEntry.stopTime.timeIntervalSinceDate(taskEntry.startTime)
            sessionTaskSummary[taskEntry.task] = (numberOfTimesActivated, totalTimeActive)

            TimePoliceModelUtils.save(moc)
        } else {
            appLog.log(logger, logtype: .EnterExit, message: "last taskentry not ongoing")
        }
    }

    func setLastTaskEntryAsOngoing() {
        appLog.log(logger, logtype: .EnterExit, message: "setLastTaskEntryOngoing")

        guard let taskEntry = session?.getLastTaskEntry() else {
            appLog.log(logger, logtype: .Debug, message: "no taskEntry in list")
            appLog.log(logger, logtype: .Guard, message: "guard fail in setLastTaskEntryAsOngoing")
            return
        }
        if !taskEntry.isOngoing() {
            var taskSummary: (Int, NSTimeInterval) = (0, 0)
            if let t = sessionTaskSummary[taskEntry.task] {
                taskSummary = t
            }
            var (numberOfTimesActivated, totalTimeActive) = taskSummary
            numberOfTimesActivated -= 1
            totalTimeActive -= taskEntry.stopTime.timeIntervalSinceDate(taskEntry.startTime)
            sessionTaskSummary[taskEntry.task] = (numberOfTimesActivated, totalTimeActive)

            taskEntry.setAsOngoing()

            TimePoliceModelUtils.save(moc)
        } else {
            appLog.log(logger, logtype: .EnterExit, message: "last taskEntry not finished")
        }
    }



    //--------------------------------------------------------------
    // TaskEntryCreatorByPickTask - Periodic update of views, triggered by timeout
    //--------------------------------------------------------------

    var updateN = 0

    @objc
    func updateActiveTask(timer: NSTimer) {
        appLog.log(logger, logtype: .PeriodicCallback, message: "updateActiveTask")

        guard let s = session else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in updateActiveTask session")
            return
        }
            
        guard let taskEntry = s.getLastTaskEntry() else {
// Commented out, too frequent...
//                appLog.log(logger, logtype: .Guard, message: "guard fail in updateActiveTask lasttaskentry")
                return
        }
        
        guard let taskList = s.tasks.array as? [Task] else {
                appLog.log(logger, logtype: .Guard, message: "guard fail in updateActiveTask tasklist")
                return
        }
        
        guard let taskIndex = taskList.indexOf(taskEntry.task as Task) else {
                appLog.log(logger, logtype: .Guard, message: "guard fail in updateActiveTask taskindex")
                return
        }
        
        taskbuttonviews[taskIndex]?.setNeedsDisplay()
        infoAreaView.setNeedsDisplay()
    }

}