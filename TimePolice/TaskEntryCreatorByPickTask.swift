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
    let signInSignOutView = TaskPickerToolView()
    let infoAreaView = TaskPickerToolView()

    let taskPickerBGView = TaskPickerBGView()

    var layout: Layout?

    var sessionTaskSummary: [Task: (Int, NSTimeInterval)]!

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
        exitButton.addTarget(self, action: "exit:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(exitButton)

        sessionNameView.theme = theme
        sessionNameView.tool = .SessionName
        var recognizer = UITapGestureRecognizer(target:self, action:Selector("useTemplate:"))
        recognizer.delegate = self
        sessionNameView.addGestureRecognizer(recognizer)

        self.view.addSubview(sessionNameView)
        
        taskPickerBGView.theme = theme
        self.view.addSubview(taskPickerBGView)

        signInSignOutView.theme = theme
        signInSignOutView.toolbarInfoDelegate = self
        signInSignOutView.tool = .SignInSignOut
        recognizer = UITapGestureRecognizer(target:self, action:Selector("handleTapSigninSignout:"))
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
        let toolHeight: CGFloat = 30

        var columns: Int = 1 + s.tasks.count/10

        if let cols = s.getProperty("columns"),
            c = Int(cols) {
                columns = c
        }

        var rows: Int = s.tasks.count/columns
        if s.tasks.count % columns > 0 {
            rows++
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

            view.selectionAreaInfoDelegate = self
            view.taskPosition = i

            if i < numberOfTasksInSession {

                if tl[i].name != spacerName {
                
                    let tapRecognizer = UITapGestureRecognizer(target:self, action:Selector("handleTapTask:"))
                    tapRecognizer.delegate = self
                    view.addGestureRecognizer(tapRecognizer)
                    recognizers[tapRecognizer] = i
                    
                    let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPressTask:"))
                    tapRecognizer.delegate = self
                    view.addGestureRecognizer(longPressRecognizer)
                    recognizers[longPressRecognizer] = i
                }
            }
                
            taskbuttonviews[i] = view
            taskPickerBGView.addSubview(view)
        }

        updateActiveActivityTimer = NSTimer.scheduledTimerWithTimeInterval(1,
            target: self,
            selector: "updateActiveTask:",
            userInfo: nil,
            repeats: true)

        appLog.log(logger, logtype: .Resource, message: "starting timer \(updateActiveActivityTimer)")

        redrawAfterSegue()

    }


    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewWillDisappear")

        appLog.log(logger, logtype: .Resource, message: "stopping timer \(updateActiveActivityTimer)")

        updateActiveActivityTimer?.invalidate()
    }


    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewWillLayoutSubviews")

        let width = CGRectGetWidth(self.view.frame)
        let height = CGRectGetHeight(self.view.frame) - 50

        exitButton.frame = CGRectMake(0, 25, 70, 30)
        
        sessionNameView.frame = CGRectMake(70, 25, width-70, 30)
        sessionNameView.toolbarInfoDelegate = self
        
        taskPickerBGView.frame = CGRectMake(0, 55, width, height - 55)

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
                work = s.getLastWork() else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in handleTapSigninSignout")
            return
        }

        if work.isOngoing() {
            setLastWorkAsFinished()
        } else {
            setLastWorkAsOngoing()
        }
        if let taskIndex = taskList.indexOf(work.task as Task) {
            taskbuttonviews[taskIndex]?.setNeedsDisplay()
        }

        appLog.log(logger, logtype: .EnterExit) { TimePoliceModelUtils.getSessionWork(s) }
    }

    func handleTapTask(sender: UITapGestureRecognizer) {
        appLog.log(logger, logtype: .EnterExit, message: "handleTap")
        appLog.log(logger, logtype: .GUIAction, message: "handleTap")

        signInSignOutView.setNeedsDisplay()
        infoAreaView.setNeedsDisplay()

        guard let s = session,
                taskList = s.tasks.array as? [Task] else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in handleTapTask")
            return
        }

        // Handle ongoing task
        if let work = s.getLastWork() {
            if let taskIndex = taskList.indexOf(work.task as Task) {
                taskbuttonviews[taskIndex]?.setNeedsDisplay()
            }

            if work.isOngoing() {
                setLastWorkAsFinished()
            }
        }

        // Handle new task
        let taskIndex = recognizers[sender]
        let task = taskList[taskIndex!]
        addNewWork(task)
        taskbuttonviews[taskIndex!]?.setNeedsDisplay()

        appLog.log(logger, logtype: .CoreDataSnapshot) { TimePoliceModelUtils.getSessionWork(s) }
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
        
        guard let work = s.getLastWork() else {
            appLog.log(logger, logtype: .EnterExit, message: "No last work")
            appLog.log(logger, logtype: .Guard, message: "guard fail in handleLongPress 2")
            return
        }
        
        let taskPressedIndex = recognizers[sender]
        let taskPressed = taskList[taskPressedIndex!]
        if work.isOngoing() && work.task != taskPressed {
            appLog.log(logger, logtype: .EnterExit, message: "Work is ongoing, LongPress on inactive task")
            return
        }

        selectedWorkIndex = s.work.count - 1

        performSegueWithIdentifier("EditTaskEntry", sender: self)
    }

    
    //---------------------------------------------
    // TaskEntryCreatorByPickTask - Segue handling (from base class)
    //---------------------------------------------
    
    override func redrawAfterSegue() {
        appLog.log(logger, logtype: .EnterExit, message: "redraw")

        sessionTaskSummary = session?.getSessionTaskSummary(false)

        signInSignOutView.setNeedsDisplay()
        infoAreaView.setNeedsDisplay()

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
        
        guard let work = s.getLastWork() else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in getSelectionAreaInfo getLastWork")
            return sai
        }

        if selectionArea >= 0 && selectionArea < taskList.count {
            if taskList[selectionArea] == work.task {
                sai.active = true
                sai.activatedAt = work.startTime
                if work.isOngoing() {
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
        if let work = session?.getLastWork() {
            if work.isOngoing() {
                signedIn = true
                
                let now = NSDate()
                if(now.compare(work.startTime) == .OrderedDescending) {
                    let timeForActiveTask = NSDate().timeIntervalSinceDate(work.startTime)
                    totalTime += timeForActiveTask
                }
            }
        }
        
        var sessionName = ""
        if let s = session {
            var sessionNameSuffix = ""
            if let e = s.getProperty("extension") {
                sessionNameSuffix = UtilitiesDate.getStringWithFormat(s.created, format: e)
            }
            sessionName = "\(s.name) \(sessionNameSuffix)"
        }
        let toolbarInfo = ToolbarInfo(
            signedIn: signedIn,
            totalTimesActivatedForSession: totalActivations,
            totalTimeActiveForSession: totalTime,
            sessionName: sessionName)
        
        return toolbarInfo
    }

    //--------------------------------------------
    //  TaskEntryCreatorByPickTask - Sign int/out, add new work
    //--------------------------------------------

    func addNewWork(task: Task) {
        appLog.log(logger, logtype: .EnterExit, message: "addWork")

        if let s = session {
            Work.createInMOC(moc, name: "", session: s, task: task)
            TimePoliceModelUtils.save(moc)
        }
    }

    func setLastWorkAsFinished() {
        appLog.log(logger, logtype: .EnterExit, message: "setLastWorkFinished")

        guard let work = session?.getLastWork() else {
            appLog.log(logger, logtype: .Debug, message: "no work in list")
            appLog.log(logger, logtype: .Guard, message: "guard fail in setLastWorkAsFinished")
            return
        }
        
        if work.isOngoing() {
            work.setStoppedAt(NSDate())

            var taskSummary: (Int, NSTimeInterval) = (0, 0)
            if let t = sessionTaskSummary[work.task] {
                taskSummary = t
            }
            var (numberOfTimesActivated, totalTimeActive) = taskSummary
            numberOfTimesActivated++
            totalTimeActive += work.stopTime.timeIntervalSinceDate(work.startTime)
            sessionTaskSummary[work.task] = (numberOfTimesActivated, totalTimeActive)

            TimePoliceModelUtils.save(moc)
        } else {
            appLog.log(logger, logtype: .EnterExit, message: "last work not ongoing")
        }
    }

    func setLastWorkAsOngoing() {
        appLog.log(logger, logtype: .EnterExit, message: "setLastWorkOngoing")

        guard let work = session?.getLastWork() else {
            appLog.log(logger, logtype: .Debug, message: "no work in list")
            appLog.log(logger, logtype: .Guard, message: "guard fail in setLastWorkAsOngoing")
            return
        }
        if !work.isOngoing() {
            var taskSummary: (Int, NSTimeInterval) = (0, 0)
            if let t = sessionTaskSummary[work.task] {
                taskSummary = t
            }
            var (numberOfTimesActivated, totalTimeActive) = taskSummary
            numberOfTimesActivated--
            totalTimeActive -= work.stopTime.timeIntervalSinceDate(work.startTime)
            sessionTaskSummary[work.task] = (numberOfTimesActivated, totalTimeActive)

            work.setAsOngoing()

            TimePoliceModelUtils.save(moc)
        } else {
            appLog.log(logger, logtype: .EnterExit, message: "last work not finished")
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
            
        guard let work = s.getLastWork() else {
// Commented out, too frequent...
//                appLog.log(logger, logtype: .Guard, message: "guard fail in updateActiveTask lastwork")
                return
        }
        
        guard let taskList = s.tasks.array as? [Task] else {
                appLog.log(logger, logtype: .Guard, message: "guard fail in updateActiveTask tasklist")
                return
        }
        
        guard let taskIndex = taskList.indexOf(work.task as Task) else {
                appLog.log(logger, logtype: .Guard, message: "guard fail in updateActiveTask taskindex")
                return
        }
        
        taskbuttonviews[taskIndex]?.setNeedsDisplay()
        infoAreaView.setNeedsDisplay()
    }

}