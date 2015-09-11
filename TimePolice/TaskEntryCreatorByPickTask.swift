//
//  TaskEntryCreatorByPickTaskVC.swift
//  TimePolice
//
//  Created by Per Ekskog on 2014-11-04.
//  Copyright (c) 2014 Per Ekskog. All rights reserved.
//


/* 

TODO

- Behöver översyn angående optionals
    If there is no session, sessionTaskSummary will not be set

*/

import UIKit
import CoreData

//==================================================
//==================================================
//  TaskPickerVC
//==================================================

class TaskEntryCreatorByPickTaskVC:
        TaskEntryCreatorBase,
        ToolbarInfoDelegate,
        SelectionAreaInfoDelegate,
        UIGestureRecognizerDelegate
	{

    let exitButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
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




    //--------------------------------------------------------
    // TaskPickerVC - Lazy properties
    //--------------------------------------------------------
    
    override func getLogDomain() -> String {
        return "TaskEntryCreatorTaskPicker"
    }


    //---------------------------------------------
    // TaskPickerVC - View lifecycle
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
        self.view.addSubview(sessionNameView)
        
        taskPickerBGView.theme = theme
        self.view.addSubview(taskPickerBGView)

        signInSignOutView.theme = theme
        signInSignOutView.toolbarInfoDelegate = self
        signInSignOutView.tool = .SignInSignOut
        var recognizer = UITapGestureRecognizer(target:self, action:Selector("handleTapSigninSignout:"))
        signInSignOutView.addGestureRecognizer(recognizer)
        taskPickerBGView.addSubview(signInSignOutView)
            
        infoAreaView.theme = theme
        infoAreaView.toolbarInfoDelegate = self
        infoAreaView.tool = .InfoArea
        taskPickerBGView.addSubview(infoAreaView)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let padding: CGFloat = 1

        if let s = session,
            moc = managedObjectContext {
            if s.tasks.count <= 6 {
                layout = GridLayout(rows: 6, columns: 1, padding: padding, toolHeight: 30)
            } else if s.tasks.count <= 12 {
                layout = GridLayout(rows: 6, columns: 2, padding: padding, toolHeight: 30)
            } else if s.tasks.count <= 21 {
                layout = GridLayout(rows: 7, columns: 3, padding: padding, toolHeight: 30)
            } else if s.tasks.count <= 24 {
                layout = GridLayout(rows: 8, columns: 3, padding: padding, toolHeight: 30)
            } else if s.tasks.count <= 27 {
                layout = GridLayout(rows: 9, columns: 3, padding: padding, toolHeight: 30)
            } else if s.tasks.count <= 30 {
                layout = GridLayout(rows: 10, columns: 3, padding: padding, toolHeight: 30)
            } else {
                layout = GridLayout(rows: 10, columns: 4, padding: padding, toolHeight: 30)
            }

            self.sessionTaskSummary = s.getSessionTaskSummary(moc)
        }

        for (_, v) in taskbuttonviews {
            if let rr = v.gestureRecognizers as? [UIGestureRecognizer] {
                for r in rr {
                    v.removeGestureRecognizer(r)
                }
            }
            v.removeFromSuperview()
        }

        recognizers = [:]
        taskbuttonviews = [:]

        if let tl = session?.tasks.array as? [Task],
            l = layout {
            let numberOfButtonsToDraw = l.numberOfSelectionAreas()
            let numberOfTasksInSession = tl.count
            for i in 0..<numberOfButtonsToDraw {
                let view = TaskPickerButtonView()
                view.theme = theme

                view.selectionAreaInfoDelegate = self
                view.taskPosition = i

                if i < numberOfTasksInSession {
                    
                    let tapRecognizer = UITapGestureRecognizer(target:self, action:Selector("handleTapTask:"))
                    tapRecognizer.delegate = self
                    view.addGestureRecognizer(tapRecognizer)
                    recognizers[tapRecognizer] = i
                    
                    let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPressTask:"))
                    tapRecognizer.delegate = self
                    view.addGestureRecognizer(longPressRecognizer)
                    recognizers[longPressRecognizer] = i
                }
                    
                taskbuttonviews[i] = view
                taskPickerBGView.addSubview(view)
            }
        }

        updateActiveActivityTimer = NSTimer.scheduledTimerWithTimeInterval(1,
            target: self,
            selector: "updateActiveTask:",
            userInfo: nil,
            repeats: true)

        println("starting timer \(updateActiveActivityTimer)")

    }


    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        println("stopping timer \(updateActiveActivityTimer)")

        updateActiveActivityTimer.invalidate()
    }


    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        var lastview : UIView
        let width = CGRectGetWidth(self.view.frame)
        let height = CGRectGetHeight(self.view.frame)

        exitButton.frame = CGRectMake(0, 25, 70, 30)
        lastview = exitButton
        
        sessionNameView.frame = CGRectMake(70, 25, width-70, 30)
        sessionNameView.toolbarInfoDelegate = self
        lastview = sessionNameView
        
        taskPickerBGView.frame = CGRectMake(0, 55, width, height - 55)
        lastview = taskPickerBGView

        if let l = layout {
            let numberOfButtonsToDraw = l.numberOfSelectionAreas()
            for i in 0..<numberOfButtonsToDraw {
                if let v = taskbuttonviews[i] {
                    v.frame = l.getViewRect(taskPickerBGView.frame, buttonNumber: i)
                }
            }

            signInSignOutView.frame = l.getViewRectSignInSignOut(taskPickerBGView.frame)
            infoAreaView.frame = l.getViewRectInfo(taskPickerBGView.frame)
        }


    }




    //---------------------------------------------
    // TaskPickerVC - GUI actions
    //---------------------------------------------

    func exit(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "exit")

        updateActiveActivityTimer?.invalidate()
        performSegueWithIdentifier("Exit", sender: self)
    }

    func handleTapSigninSignout(sender: UITapGestureRecognizer) {
        appLog.log(logger, logtype: .EnterExit, message: "handleTapSigninSignout")

        if let taskList = session?.tasks.array as? [Task],
            work = session?.getLastWork() {
            if work.isOngoing() {
                setLastWorkAsFinished()
            } else {
                setLastWorkAsOngoing()
            }
            let taskIndex = find(taskList, work.task as Task)
            taskbuttonviews[taskIndex!]?.setNeedsDisplay()
        }

        signInSignOutView.setNeedsDisplay()
        infoAreaView.setNeedsDisplay()

        if let s = session {
            appLog.log(logger, logtype: .EnterExit) { TimePoliceModelUtils.getSessionWork(s) }
        }
    }

    func handleTapTask(sender: UITapGestureRecognizer) {
        appLog.log(logger, logtype: .EnterExit, message: "handleTap")

        // Handle ongoing task
        if let taskList = session?.tasks.array as? [Task],
            work = session?.getLastWork() {
            let taskIndex = find(taskList, work.task as Task)
            taskbuttonviews[taskIndex!]?.setNeedsDisplay()
            if work.isOngoing() {
                setLastWorkAsFinished()
            }
                
        }

        // Handle new task
        if let taskList = session?.tasks.array as? [Task] {
            let taskIndex = recognizers[sender]
            let task = taskList[taskIndex!]
            addNewWork(task)
            taskbuttonviews[taskIndex!]?.setNeedsDisplay()
        }

        signInSignOutView.setNeedsDisplay()
        infoAreaView.setNeedsDisplay()

        if let s = session {
            appLog.log(logger, logtype: .EnterExit) { TimePoliceModelUtils.getSessionWork(s) }
        }
    }

    func handleLongPressTask(sender: UILongPressGestureRecognizer) {
        appLog.log(logger, logtype: .EnterExit, message: "handleLongPress")

        if sender.state != UIGestureRecognizerState.Began {
            return
        }

        if let work = session?.getLastWork(),
            taskList = session?.tasks.array as? [Task] {
            let taskPressedIndex = recognizers[sender]
            let taskPressed = taskList[taskPressedIndex!]
            if work.isOngoing() && work.task != taskPressed {
                appLog.log(logger, logtype: .EnterExit, message: "Work is ongoing, LongPress on inactive task")
                return
            }

            selectedWorkIndex = session!.work.count - 1

            performSegueWithIdentifier("EditTaskEntry", sender: self)
        } else {
            appLog.log(logger, logtype: .EnterExit, message: "No last work")
        }

    }

    
    //---------------------------------------------
    // TaskPickerVC - Segue handling (from base class)
    //---------------------------------------------
    
    override func redrawAfterSegue() {
        appLog.log(logger, logtype: .EnterExit, message: "redraw")

        if let moc = managedObjectContext {
            sessionTaskSummary = session?.getSessionTaskSummary(moc)
        }

        signInSignOutView.setNeedsDisplay()
        infoAreaView.setNeedsDisplay()

        for (_, view) in taskbuttonviews {
            view.setNeedsDisplay()
        }
    }

    //---------------------------------------------
    // TaskPickerVC - GestureRecognizerDelegate
    //---------------------------------------------

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
        shouldReceiveTouch touch: UITouch) -> Bool {
            if let taskNumber = recognizers[gestureRecognizer] {
                return true //taskIsSelectable(taskNumber)
            } else {
                return true
            }
    }


    //----------------------------------------------
    //  TaskPickerVC - SelectionAreaInfoDelegate
    //----------------------------------------------

	func getSelectionAreaInfo(selectionArea: Int) -> SelectionAreaInfo {
        appLog.log(logger, logtype: .EnterExit) { "getSelectionAreaInfo\(selectionArea)"}

        // This will only be called when there are selection areas setup 
        //  => there _is_ a session
        //  => There _is_ a task in the taskList
        
        let sai = SelectionAreaInfo()
        
        if let taskList = session?.tasks.array as? [Task] {
            if selectionArea >= 0 && selectionArea < taskList.count {
                let task = taskList[selectionArea]
                sai.task = task
                if let t = sessionTaskSummary[task] {
                    let (numberOfTimesActivated, totalTimeActive) = t
                    sai.numberOfTimesActivated = numberOfTimesActivated
                    sai.totalTimeActive = totalTimeActive
                }
            }
        }
        
        if let work = session?.getLastWork(),
            taskList = session?.tasks.array as? [Task] {
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
        }
        
        return sai
	}

    //----------------------------------------------
    //  TaskPickerVC - ToolbarInfoDelegate
    //----------------------------------------------

    func getToolbarInfo() -> ToolbarInfo {
        appLog.log(logger, logtype: .EnterExit, message: "getToolbarInfo")
        
        var totalActivations: Int = 0 // The first task is active when first selected
        var totalTime: NSTimeInterval = 0
        
        for (task, (activations, time)) in sessionTaskSummary {
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
            sessionName = s.name
        }
        let toolbarInfo = ToolbarInfo(
            signedIn: signedIn,
            totalTimesActivatedForSession: totalActivations,
            totalTimeActiveForSession: totalTime,
            sessionName: sessionName)
        
        return toolbarInfo
    }

    //--------------------------------------------
    //  TaskPickerVC - Sign int/out, add new work
    //--------------------------------------------

    func addNewWork(task: Task) {
        appLog.log(logger, logtype: .EnterExit, message: "addWork")

        if let moc = managedObjectContext,
            s = session {
            let w = Work.createInMOC(moc, name: "", session: s, task: task)
            TimePoliceModelUtils.save(moc)
        }
    }

    func setLastWorkAsFinished() {
        appLog.log(logger, logtype: .EnterExit, message: "setLastWorkFinished")

        if let work = session?.getLastWork(),
            moc = managedObjectContext {
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
        } else {
            appLog.log(logger, logtype: .EnterExit, message: "no work in list")
        }
    }

    func setLastWorkAsOngoing() {
        appLog.log(logger, logtype: .EnterExit, message: "setLastWorkOngoing")

        if let work = session?.getLastWork(),
            moc = managedObjectContext {
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
        } else {
            appLog.log(logger, logtype: .EnterExit, message: "no work in list")
        }
    }



    //--------------------------------------------------------------
    // TaskPickerVC - Periodic update of views, triggered by timeout
    //--------------------------------------------------------------

    var updateN = 0

    @objc
    func updateActiveTask(timer: NSTimer) {
        println("updateActiveTask(timer=\(timer)")
        updateN++
        if updateN == 5 {
            updateN = 0
        }
        if updateN==0 {
            appLog.log(logger, logtype: .Debug, message: "updateActiveTask")
        }
        if let work = session?.getLastWork() {
            let task = work.task
            
            if let taskList = session?.tasks.array as? [Task],
                taskIndex = find(taskList, task as Task) {
                let view = taskbuttonviews[taskIndex]
                taskbuttonviews[taskIndex]?.setNeedsDisplay()
                infoAreaView.setNeedsDisplay()
            }
        }
    }

}