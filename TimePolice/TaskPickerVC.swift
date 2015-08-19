//
//  TaskPickerViewController.swift
//  TimePolice
//
//  Created by Per Ekskog on 2014-11-04.
//  Copyright (c) 2014 Per Ekskog. All rights reserved.
//


/* 

TODO

- SessionName ska vara en del av VC, ej TimePolice. Den ska läggas i TaskPickerBGView (?)
- Settings ska bort från layout
- VC ska skapa TaskPickerToolView för Exit och SessionName, då funkar THeme med dessa också.
- (Summary och stop/continue ska fortfarande vara en del av "Layout")



- getSelectionAreaInfo
  Är det Theme som gör uträkning av tid för aktuell task? Kasnek inte så bra...

- gestureRecognizer
  Hur ska den implementeras, får kompileringsfel?

*/

import UIKit
import CoreData

//==================================================
//==================================================
//  TaskPickerVC
//==================================================

class TaskPickerVC: 
        TaskEntryCreatorBase
	{

    var sourceController: TimePoliceVC?
    var tp: TaskPicker?
    
//    var statusView: UITextView?

    var selectedWork: Work?

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
        
        (self.view as! TimePoliceBGView).theme = theme

        var lastview : UIView
        let parentWidth = CGRectGetWidth(self.view.frame)
        let parentHeight = CGRectGetHeight(self.view.frame)

        let exitButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        exitButton.frame = CGRectMake(0, 25, 70, 30)
        exitButton.backgroundColor = UIColor(red: 0.0, green: 0.4, blue: 0.0, alpha: 1.0)
        exitButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        exitButton.setTitle("EXIT", forState: UIControlState.Normal)
        exitButton.addTarget(self, action: "exit:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(exitButton)
        lastview = exitButton

        var viewRect = CGRectMake(70, 25, parentWidth-70, 30)
        let sessionNameView = TaskPickerToolView(frame: viewRect)
        sessionNameView.theme = theme
        sessionNameView.tool = SessionName
        self.view.addSubview(sessionNameView)
        lastview = sessionNameView
        
        let taskPickerBGView = TaskPickerBGView()
        taskPickerBGView.frame = CGRectMake(0, 55, parentWidth, parentHeight - 55)
        //taskPickerBGView.frame = layout.adjustedFrame(taskPickerBGView.frame)
        self.view.addSubview(taskPickerBGView)
        lastview = taskPickerBGView


        if let s = session {
            if let moc = self.managedObjectContext {
                var layout: Layout!
                if s.tasks.count <= 6 {
                    layout = GridLayout(rows: 6, columns: 1, padding: padding, toolHeight: 30)
                } else if s.tasks.count <= 12 {
                    layout = GridLayout(rows: 6, columns: 2, padding: padding, toolHeight: 30)
                } else if s.tasks.count <= 21 {
                    layout = GridLayout(rows: 7, columns: 3, padding: padding, toolHeight: 30)
                } else if s.tasks.count <= 24 {
                    layout = GridLayout(rows: 8, columns: 3, padding: padding, toolHeight: 30)
                } else {
                    layout = GridLayout(rows: 10, columns: 4, padding: padding, toolHeight: 30)
                }
                
                tp = TaskPicker(vc: self, backgroundView: taskPickerBGView,
                    layout: layout, theme: theme, taskSelectionStrategy: taskSelectionStrategy,
                    session: s, moc: moc, appLog: appLog)
            
                tp?.setup()

                sessionNameView.toolbarInfoDelegate = tp

                appLog.log(logger, logtype: .Debug) { TimePoliceModelUtils.getSessionWork(s) }
            }
        }
    }


    //---------------------------------------------
    // TaskPickerVC - Button actions
    //---------------------------------------------

    func exit(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "exit")

        tp?.updateActiveActivityTimer?.invalidate()
        performSegueWithIdentifier("Exit", sender: self)
    }


    
    //---------------------------------------------
    // TaskPickerVC - Segue handling
    //---------------------------------------------
    
    override func redrawAfterSegue() {
        tp?.redraw()
    }
    
}


//==================================================
//==================================================
//  TaskPicker
//==================================================


class TaskPicker: NSObject, UIGestureRecognizerDelegate, ToolbarInfoDelegate, SelectionAreaInfoDelegate {
    // Persistent data form the model, set at creation time
    var session: Session

	// Views, set at creation time
    var vc: TaskPickerVC!
//    var statusView: UITextView!
    var backgroundView:TaskPickerBGView!

    // Preferences, set at creation time
	var layout: Layout!
	var theme: Theme!
    var taskSelectionStrategy: TaskSelectionStrategy!

    // Cached values, calculated at startup
	var sessionTaskSummary: [Task: (Int, NSTimeInterval)]!

    // Non persitent data, initialized in init(), then set in setup()
    var recognizers: [UIGestureRecognizer: Int]!
    var taskbuttonviews: [Int: TaskPickerButtonView]!
    var moc: NSManagedObjectContext!

    var appLog: AppLog!
    var logger: AppLogger!
	
    init(vc: TaskPickerVC, backgroundView:TaskPickerBGView,
        layout: Layout, theme: Theme, taskSelectionStrategy: TaskSelectionStrategy, 
        session: Session,
        moc: NSManagedObjectContext, appLog: AppLog) {

        self.appLog = appLog

//        let logger1 = TextViewLog(textview: statusView, locator: "TaskPicker")
        let logger2 = StringLog(locator: "TaskPicker")
        let logger3 = ApplogLog(locator: "TaskPicker")

        self.logger = MultiLog()
//        (logger as! MultiLog).logger1 = logger1
        (logger as! MultiLog).logger2 = logger2
        (logger as! MultiLog).logger3 = logger3

        appLog.log(logger, logtype: .EnterExit, message: "init")

        self.session = session

        self.vc = vc
//        self.statusView = statusView
        self.backgroundView = backgroundView

		self.layout = layout
		self.theme = theme
        self.taskSelectionStrategy = taskSelectionStrategy

        self.sessionTaskSummary = session.getSessionTaskSummary(moc)
            
        self.moc = moc

        self.recognizers = [:]
        self.taskbuttonviews = [:]
	}

    // Non presistent local attributes, setup when initialising the view
	var updateActiveActivityTimer: NSTimer?
    var sessionNameView: TaskPickerToolView?
	var signInSignOutView: TaskPickerToolView?
	var infoAreaView: TaskPickerToolView?
	var settingsView: TaskPickerToolView?


    //--------------------------------------------------
	// TaskPicker - setup
    //--------------------------------------------------

	func setup() {
        appLog.log(logger, logtype: .EnterExit, message: "setup")

		backgroundView.theme = theme
        let taskList = session.tasks.array as! [Task]

		// Setup task buttons
		let numberOfButtonsToDraw = min(taskList.count, layout.numberOfSelectionAreas())
		for i in 0..<numberOfButtonsToDraw {
			let viewRect = layout.getViewRect(backgroundView.frame, selectionArea: i)
            let view = TaskPickerButtonView(frame: viewRect)
			view.theme = theme
			view.selectionAreaInfoDelegate = self
			view.taskPosition = i

			let tapRecognizer = UITapGestureRecognizer(target:self, action:Selector("handleTap:"))
            tapRecognizer.delegate = self
            view.addGestureRecognizer(tapRecognizer)
			recognizers[tapRecognizer] = i

            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPress:"))
            longPressRecognizer.delegate = self
            view.addGestureRecognizer(longPressRecognizer)
            recognizers[longPressRecognizer] = i

            taskbuttonviews[i] = view

			backgroundView.addSubview(view)
		}

		// Setup sign in/out button
		var viewRect = layout.getViewRect(backgroundView.frame, selectionArea: SignInSignOut)
	    signInSignOutView = TaskPickerToolView(frame: viewRect)
		signInSignOutView!.theme = theme
		signInSignOutView!.toolbarInfoDelegate = self
		signInSignOutView!.tool = SignInSignOut
		var recognizer = UITapGestureRecognizer(target:self, action:Selector("handleTapSigninSignout:"))
	    recognizer.delegate = self
	    signInSignOutView!.addGestureRecognizer(recognizer)
		backgroundView.addSubview(signInSignOutView!)

		// Setup infoarea
		viewRect = layout.getViewRect(backgroundView.frame, selectionArea: InfoArea)
	    infoAreaView = TaskPickerToolView(frame: viewRect)
		infoAreaView!.theme = theme
		infoAreaView!.toolbarInfoDelegate = self
		infoAreaView!.tool = InfoArea
		backgroundView.addSubview(infoAreaView!)
        
        updateActiveActivityTimer = NSTimer.scheduledTimerWithTimeInterval(1,
                                   target: self,
                                 selector: "updateActiveTask:",
                                 userInfo: nil,
                                  repeats: true)        
    }

    //------------------------------------
    //  TaskPicker - redraw
    //------------------------------------

    func redraw() {
        appLog.log(logger, logtype: .EnterExit, message: "redraw")

        sessionTaskSummary = session.getSessionTaskSummary(moc)

        signInSignOutView?.setNeedsDisplay()
        infoAreaView?.setNeedsDisplay()
        settingsView?.setNeedsDisplay()

        for (_, view) in taskbuttonviews {
            view.setNeedsDisplay()
        }
    }


    //------------------------------------
    //  TaskPicker - SelectionStrategy
    //------------------------------------

	// Gesture recognizer delegate
/*1.2*/
    /*
    func gestureRecognizer(gestureRecognizer: UITapGestureRecognizer,
        shouldReceiveTouch touch: UITouch) -> Bool {
            if let taskNumber = recognizers[gestureRecognizer] {
                return taskIsSelectable(taskNumber)
            } else {
                return true
            }
	}*/

    func taskIsSelectable(taskNumber: Int) -> Bool {
        // Should use taskSelectionStrategy
        return true
    }


    //-------------------------------------
    //  TaskPicker - Tap on buttons
    //-------------------------------------


    // Tap on settings    

    func handleTapSettings(sender: UITapGestureRecognizer) {
        appLog.log(logger, logtype: .EnterExit, message: "handleTapSettings")
    }


    // Tap on sign in/sign out, call taskSignIn/taskSignOut and update views

    func handleTapSigninSignout(sender: UITapGestureRecognizer) {
        appLog.log(logger, logtype: .EnterExit, message: "handleTapSigninSignout")

        let taskList = session.tasks.array as! [Task]
        
        if let work = session.getLastWork() {
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

        signInSignOutView?.setNeedsDisplay()
        infoAreaView?.setNeedsDisplay()

        appLog.log(logger, logtype: .EnterExit) { TimePoliceModelUtils.getSessionWork(self.session) }
    }


    // Tap on new task, call taskSignIn/taskSignOut and update views

    func handleTap(sender: UITapGestureRecognizer) {
        appLog.log(logger, logtype: .EnterExit, message: "handleTap")

        let taskList = session.tasks.array as! [Task]
        
        if let work = session.getLastWork() {
            let taskIndex = find(taskList, work.task as Task)
            taskbuttonviews[taskIndex!]?.setNeedsDisplay()
            if work.isOngoing() {
                setLastWorkAsFinished()
            }
        }

        let taskIndex = recognizers[sender]
        let task = taskList[taskIndex!]

        addNewWork(task)

        taskbuttonviews[taskIndex!]?.setNeedsDisplay()
        signInSignOutView?.setNeedsDisplay()
        infoAreaView?.setNeedsDisplay()

        appLog.log(logger, logtype: .EnterExit) { TimePoliceModelUtils.getSessionWork(self.session) }
    }

    // Long press on task, edit current work

    func handleLongPress(sender: UILongPressGestureRecognizer) {
        appLog.log(logger, logtype: .EnterExit, message: "handleLongPress")

        if sender.state != UIGestureRecognizerState.Began {
            return
        }

        if let work = session.getLastWork() {
            
            let taskList = session.tasks.array as! [Task]
            let taskIndex = recognizers[sender]
            let task = taskList[taskIndex!]
            if work.isOngoing() && work.task != task {
                appLog.log(logger, logtype: .EnterExit, message: "Work is ongoing, LongPress on inactive task")
                return
            }

            vc.selectedWork = work
            vc.selectedWorkIndex = session.work.count-1

            vc.performSegueWithIdentifier("EditWork", sender: vc)
        } else {
            appLog.log(logger, logtype: .EnterExit, message: "No last work")
        }

    }


    //--------------------------------------------
    //  TaskPicker - Sign int/out
    //--------------------------------------------

    // Update currentWork when sign in to a task

    func addNewWork(task: Task) {
        appLog.log(logger, logtype: .EnterExit, message: "addWork")

        let w = Work.createInMOC(self.moc, name: "", session: session, task: task)

        TimePoliceModelUtils.save(moc)
    }

    // Update currentWork, previousTask, numberOfTimesActivated and totalTimeActive when sign out from a task

    func setLastWorkAsFinished() {
        appLog.log(logger, logtype: .EnterExit, message: "setLastWorkFinished")

        //if let work = currentWork {
        if let work = session.getLastWork() {
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

        //if let work = currentWork {
        if let work = session.getLastWork() {
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
    // TaskPicker - Periodic update of views, triggered by timeout
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
        if let work = session.getLastWork() {
            let task = work.task
            
            let taskList = session.tasks.array as! [Task]
            if let taskIndex = find(taskList, task as Task) {
                let view = taskbuttonviews[taskIndex]
                taskbuttonviews[taskIndex]?.setNeedsDisplay()
                infoAreaView?.setNeedsDisplay()
            }
        }
    }


    //----------------------------------------------
    //  TaskPicker - Button info
    //----------------------------------------------

	// SelectionAreaInfoDelegate

	func getSelectionAreaInfo(selectionArea: Int) -> SelectionAreaInfo {
        appLog.log(logger, logtype: .EnterExit) { "getSelectionAreaInfo\(selectionArea)"}

        let taskList = session.tasks.array as! [Task]
        let task = taskList[selectionArea]

        var taskSummary: (Int, NSTimeInterval) = (0, 0)
        if let t = sessionTaskSummary[task] {
            taskSummary = t
        }
        let (numberOfTimesActivated, totalTimeActive) = taskSummary

        var active = false
        var ongoing = false
        var activatedAt = NSDate()
        if let work = session.getLastWork() {
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

	// ToolbarInfoDelegate

    func getToolbarInfo() -> ToolbarInfo {
        appLog.log(logger, logtype: .EnterExit, message: "getToolbarInfo")

        var totalActivations: Int = 0 // The first task is active when first selected
        var totalTime: NSTimeInterval = 0
        
        for (task, (activations, time)) in sessionTaskSummary {
            totalActivations += activations
            totalTime += time
        }

        var signedIn = false
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

    	let toolbarInfo = ToolbarInfo(
    		signedIn: signedIn, 
    		totalTimesActivatedForSession: totalActivations,
    		totalTimeActiveForSession: totalTime,
            sessionName: session.name)

    	return toolbarInfo
    }

}


 






