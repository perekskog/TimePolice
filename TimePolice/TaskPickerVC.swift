//
//  TaskPickerViewController.swift
//  TimePolice
//
//  Created by Per Ekskog on 2014-11-04.
//  Copyright (c) 2014 Per Ekskog. All rights reserved.
//


/* 

TODO

- Borde jag inte kunna använda navigationbar?
  Sätt left = EXIT och titel till sessionsnamnet.

- gestureRecognizer, TaskPickerStrategy
  Hur ska den implementeras, får kompileringsfel?
    // Gesture recognizer delegate
    
    func gestureRecognizer(gestureRecognizer: UITapGestureRecognizer,
        shouldReceiveTouch touch: UITouch) -> Bool {
            if let taskNumber = recognizers[gestureRecognizer] {
                return taskIsSelectable(taskNumber)
            } else {
                return true
            }
    }

+ Om det finns fler "rutor" i Layout än det finns Tasks ska resten fyllas ut med tomma knappar.
    Ska SelectionAreaInfo innehålla optionals? Känns ganska praktiskt...

- Behöver översyn angående optionals
    If there is no session, sessionTaskSummary will not be set

- Kan inte hantera fall då antal tasks < antal rutor

- Lägg SessionName i NavigationController
    - Ta då också bort SessionName från enum ViewType


DONE

v getSelectionAreaInfo
  Theme ska inte räkna ut tid för pågående task.
  Lägg till timeSinceLastActivation, i fallet med active blir det bra, men annars?
    => Men jag har ju redan activatedAt...


*/

import UIKit
import CoreData

//==================================================
//==================================================
//  TaskPickerVC
//==================================================

class TaskPickerVC: 
        TaskEntryCreatorBase,
        ToolbarInfoDelegate,
        SelectionAreaInfoDelegate
	{

    var sourceController: TimePoliceVC?
    
    let exitButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    let sessionNameView = TaskPickerToolView()
    let taskPickerBGView = TaskPickerBGView()
    let signInSignOutView = TaskPickerToolView()
    let infoAreaView = TaskPickerToolView()

    var layout: Layout?

    var sessionTaskSummary: [Task: (Int, NSTimeInterval)]!

    var recognizers: [UIGestureRecognizer: Int] = [:]
    var taskbuttonviews: [Int: TaskPickerButtonView] = [:]

    var updateActiveActivityTimer: NSTimer?
    



    //--------------------------------------------------------
    // TaskPickerVC - Lazy properties
    //--------------------------------------------------------
/*
    lazy var logger: AppLogger = {
        let logger = MultiLog()
        //      logger.logger1 = TextViewLog(textview: statusView!, locator: "WorkListVC")
        logger.logger2 = StringLog(locator: "TaskPickerVC")
        logger.logger3 = ApplogLog(locator: "TaskPickerVC")
        
        return logger
    }()
*/

    //---------------------------------------------
    // TaskPickerVC - View lifecycle
    //---------------------------------------------

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.orangeColor()]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let theme = BlackGreenTheme()
//        let theme = BasicTheme()

        let taskSelectionStrategy = TaskSelectAny()

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
            } else {
                layout = GridLayout(rows: 10, columns: 4, padding: padding, toolHeight: 30)
            }

            self.sessionTaskSummary = s.getSessionTaskSummary(moc)
        }

        
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
                    view.addGestureRecognizer(tapRecognizer)
                    recognizers[tapRecognizer] = i
                    
                    let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPressTask:"))
                    view.addGestureRecognizer(longPressRecognizer)
                    recognizers[longPressRecognizer] = i
                }
                    
                taskbuttonviews[i] = view
                taskPickerBGView.addSubview(view)
            }
                
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

            updateActiveActivityTimer = NSTimer.scheduledTimerWithTimeInterval(1,
                    target: self,
                    selector: "updateActiveTask:",
                    userInfo: nil,
                    repeats: true)
        }

    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        appLog.log(logger, logtype: .iOS, message: "viewWillLayoutSubviews")

        var lastview : UIView
        let width = CGRectGetWidth(self.view.frame)
        let height = CGRectGetHeight(self.view.frame)

        exitButton.frame = CGRectMake(0, 25, 70, 30)
        lastview = exitButton
        
        sessionNameView.frame = CGRectMake(70, 25, width-70, 30)
        sessionNameView.toolbarInfoDelegate = self
        lastview = sessionNameView
        
        taskPickerBGView.frame = CGRectMake(0, 55, width, height - 55)
        //taskPickerBGView.frame = layout.adjustedFrame(taskPickerBGView.frame)
        lastview = taskPickerBGView

        if let l = layout {
            let numberOfButtonsToDraw = l.numberOfSelectionAreas()
            for i in 0..<numberOfButtonsToDraw {
                if let v = taskbuttonviews[i] {
                    v.frame = l.getViewRect(taskPickerBGView.frame, buttonNumber: i)
                }
            }
            signInSignOutView.frame = l.getViewRect(taskPickerBGView.frame, selectionArea: .SignInSignOut)

            infoAreaView.frame = l.getViewRect(taskPickerBGView.frame, selectionArea: .InfoArea)
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

    func handleTapSettings(sender: UITapGestureRecognizer) {
        appLog.log(logger, logtype: .EnterExit, message: "handleTapSettings")
    }

    func handleTapSigninSignout(sender: UITapGestureRecognizer) {
        appLog.log(logger, logtype: .EnterExit, message: "handleTapSigninSignout")

        if let taskList = session?.tasks.array as? [Task],
            work = session?.getLastWork() {
            if work.isOngoing() {
               // Last work ongoing -> finished
                setLastWorkAsFinished()
            } else {
                // Last work finished -> ongoing
                setLastWorkAsOngoing()
            }
            let taskIndex = find(taskList, work.task as Task)
            taskbuttonviews[taskIndex!]?.setNeedsDisplay()
        } else {
            // Empty worklist => do nothing
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
            let taskIndex = recognizers[sender]
            let task = taskList[taskIndex!]
            if work.isOngoing() && work.task != task {
                appLog.log(logger, logtype: .EnterExit, message: "Work is ongoing, LongPress on inactive task")
                return
            }

            selectedWorkIndex = session!.work.count - 1

            performSegueWithIdentifier("EditWork", sender: self)
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


    //----------------------------------------------
    //  TaskPickerVC - SelectionAreaInfoDelegate
    //----------------------------------------------

	func getSelectionAreaInfo(selectionArea: Int) -> SelectionAreaInfo {
        appLog.log(logger, logtype: .EnterExit) { "getSelectionAreaInfo\(selectionArea)"}

        // This will only be called when there are selection areas setup 
        //  => there _is_ a session
        //  => There _is_ a task in the taskList
        
        let taskList = session!.tasks.array as! [Task]
        let task = taskList[selectionArea]
        
        var taskSummary: (Int, NSTimeInterval) = (0, 0)
        if let t = sessionTaskSummary[task] {
            taskSummary = t
        }
        let (numberOfTimesActivated, totalTimeActive) = taskSummary
        
        var active = false
        var ongoing = false
        var activatedAt = NSDate()
        if let work = session?.getLastWork() {
            if taskList[selectionArea] == work.task {
                active = true
                activatedAt = work.startTime
                if work.isOngoing() {
                    ongoing = true
                }
            }
        }
        let selectionAreaInfo = SelectionAreaInfo(
            task: task,
            numberOfTimesActivated: numberOfTimesActivated,
            totalTimeActive: totalTimeActive,
            active: active,
            activatedAt: activatedAt,
            ongoing: ongoing)
        
        return selectionAreaInfo
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