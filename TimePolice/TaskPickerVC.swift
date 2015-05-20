//
//  TaskPickerViewController.swift
//  TimePolice
//
//  Created by Per Ekskog on 2014-11-04.
//  Copyright (c) 2014 Per Ekskog. All rights reserved.
//


/* 

TODO

- getSelectionAreaInfo
  Är det Theme som gör uträkning av tid för aktuell task? Kasnek inte så bra...

- gestureRecognizer
  Hur ska den implementeras, får kompileringsfel?

*/

import UIKit
import CoreData

//==================================================
//==================================================
//  TaskPickerViewController
//==================================================

class TaskPickerVC: UIViewController
	{

    var session: Session?
    var sourceController: TimePoliceVC?
    var tp: TaskPicker?
    
//    var statusView: UITextView?

    var logger: AppLogger?

    var selectedWork: Work?
    var selectedWorkIndex: Int?



    //---------------------------------------------
    // TaskPickerViewController - View lifecycle
    //---------------------------------------------


    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let logger1 = TextViewLog(textview: statusView!, locator: "TaskPickerVC")
        let logger2 = StringLog(locator: "TaskPickerVC")
        let logger3 = ApplogLog(locator: "TaskPickerVC")

        logger = MultiLog()
//        (logger as! MultiLog).logger1 = logger1
        (logger as! MultiLog).logger2 = logger2
        (logger as! MultiLog).logger3 = logger3

        appLog.log(logger!, logtype: .EnterExit, message: "viewDidLoad")


        let theme = BlackGreenTheme()
//        let theme = BasicTheme()
        let layout = GridLayout(rows: 7, columns: 3, padding: 1, toolbarHeight: 30)
        let taskSelectionStrategy = TaskSelectAny()
        
        (self.view as! TimePoliceBackgroundView).theme = theme

        var lastview : UIView
        let width = CGRectGetWidth(self.view.frame)
        let height = CGRectGetHeight(self.view.frame)

        let taskPickerBackgroundView = TaskPickerBackgroundView()
        taskPickerBackgroundView.frame = CGRectMake(0, 25, width - 1, height - 155)
        self.view.addSubview(taskPickerBackgroundView)
        lastview = taskPickerBackgroundView

/*
        var statusRect = self.view.bounds
        statusRect.origin.x = 5
        statusRect.origin.y = statusRect.size.height-110
        statusRect.size.height = 100
        statusRect.size.width -= 10
        statusView = UITextView(frame: statusRect)
        statusView!.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        statusView!.textColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        statusView!.font = UIFont.systemFontOfSize(8)
        statusView!.editable = false
        self.view.addSubview(statusView!)
*/

        let exitButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        exitButton.frame = CGRectMake(width - 80, height - 45, 70, 30)
        exitButton.backgroundColor = UIColor(red: 0.0, green: 0.7, blue: 0.0, alpha: 1.0)
        exitButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        exitButton.setTitle("EXIT", forState: UIControlState.Normal)
        exitButton.addTarget(self, action: "exit:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(exitButton)
        lastview = exitButton
        
        if let s = session {
            if let moc = self.managedObjectContext {
                tp = TaskPicker(vc: self, backgroundView: taskPickerBackgroundView,
                    layout: layout, theme: theme, taskSelectionStrategy: taskSelectionStrategy,
                    session: s, moc: moc, appLog: appLog)
            
                tp?.setup()
                appLog.log(logger!, logtype: .Debug) { TimePoliceModelUtils.getSessionWork(s) }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        appLog.log(logger!, logtype: .EnterExit, message: "didReceiveMemoryWarning")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger!, logtype: .EnterExit, message: "viewWillAppear")
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.orangeColor()]
    }


    //---------------------------------------------
    // TaskPickerViewController - Button actions
    //---------------------------------------------

    func exit(sender: UIButton) {
        appLog.log(logger!, logtype: .EnterExit, message: "exit")

        tp?.updateActiveActivityTimer?.invalidate()
        performSegueWithIdentifier("Exit", sender: self)
    }


    
    //---------------------------------------------
    // TaskPickerViewController - Segue handling
    //---------------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        appLog.log(logger!, logtype: .EnterExit, message: "prepareForSegue")

        if segue.identifier == "EditWork" {
            let vc = segue.destinationViewController as! EditWorkVC
            
            if let s = session {
                appLog.log(logger!, logtype: .EnterExit) { TimePoliceModelUtils.getSessionWork(s) }

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
                    if i < wl.count-1 {
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
        appLog.log(logger!, logtype: .EnterExit, message: "exitEditWork(unwindsegue=\(unwindSegue.identifier))")

        let vc = unwindSegue.sourceViewController as! EditWorkVC

        if unwindSegue.identifier == "CancelEditWork" {
            appLog.log(logger!, logtype: .EnterExit, message: "Handle CancelEditWork... Do nothing")
            // Do nothing
        }

        if unwindSegue.identifier == "OkEditWork" {
            appLog.log(logger!, logtype: .EnterExit, message: "Handle OkEditWork")

            if let moc = managedObjectContext,
                     s = session,
                     i = selectedWorkIndex {

                if let t = vc.taskToUse {
                    // Change task if this attribute was set
                    appLog.log(logger!, logtype: .EnterExit, message: "EditWork selected task=\(t.name)")
                    s.getWork(i)!.task = t
                } else {
                    appLog.log(logger!, logtype: .EnterExit, message: "EditWork no task selected")
                }
                
                if let initialDate = vc.initialStartDate,
                   datepickerStart = vc.datepickerStart {
                    appLog.log(logger!, logtype: .Debug, message: "EditWork initial start date=\(getString(initialDate))")
                    appLog.log(logger!, logtype: .Debug, message: "EditWork selected start date=\(getString(datepickerStart.date))")

                    if initialDate != datepickerStart.date {
                        // The initial starttime was changed
                        appLog.log(logger!, logtype: .Debug, message: "Selected starttime != initial starttime, setting starttime")
                        s.setStartTime(moc, workIndex: s.work.count-1, desiredStartTime: datepickerStart.date)
                    } else {
                        appLog.log(logger!, logtype: .Debug, message: "Selected starttime = initial starttime, don't set starttime")
                    }
                }

                if let initialDate = vc.initialStopDate,
                    datepickerStop = vc.datepickerStop {
                    appLog.log(logger!, logtype: .Debug, message: "EditWork initial stop date=\(getString(initialDate))")
                    appLog.log(logger!, logtype: .Debug, message: "EditWork selected stop date=\(getString(datepickerStop.date))")

                    if initialDate != datepickerStop.date {
                        // The initial stoptime was changed
                        appLog.log(logger!, logtype: .Debug, message: "Selected stoptime != initial stoptime, setting stoptime")
                        s.setStopTime(moc, workIndex: s.work.count-1, desiredStopTime: datepickerStop.date)
                    } else {
                        appLog.log(logger!, logtype: .Debug, message: "Selected stoptime = initial stoptime, don't set stoptime")
                    }
                }


                TimePoliceModelUtils.save(moc)

                appLog.log(logger!, logtype: .Debug) { TimePoliceModelUtils.getSessionWork(s) }
            }
            
            tp?.redraw()
        }

        if unwindSegue.identifier == "DeleteWork" {
            appLog.log(logger!, logtype: .Debug, message: "Handle DeleteWork")

            if let moc = managedObjectContext,
                     s = session,
                     i = selectedWorkIndex {

                if let fillEmptySpaceWith = vc.fillEmptySpaceWith?.selectedSegmentIndex {
                    switch fillEmptySpaceWith {
                    case 0: // Nothing, deleteWork
                        appLog.log(logger!, logtype: .Debug, message: "Fill with nothing")
                        s.deleteWork(moc, workIndex: i)
                    case 1: // Previous item, deleteNextWorkAndAlignStop
                        appLog.log(logger!, logtype: .Debug, message: "Fill with previous")
                        s.deleteNextWorkAndAlignStop(moc, workIndex: i-1)
                    case 2: // Next item, deletePreviousWorkAndAlignStart
                        appLog.log(logger!, logtype: .Debug, message: "Fill with next")
                        s.deletePreviousWorkAndAlignStart(moc, workIndex: i+1)
                    default: // Not handled
                        appLog.log(logger!, logtype: .Debug, message: "Not handled")
                    }
                }
                tp?.redraw()
            }

        }

    }


    
    //--------------------------------------------------------
    // TaskPickerViewController - AppDelegate lazy properties
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
    var backgroundView:TaskPickerBackgroundView!

    // Preferences, set at creation time
	var layout: Layout!
	var theme: Theme!
    var taskSelectionStrategy: TaskSelectionStrategy!

    // Cached values, calculated at startup
	var sessionSummary: [Task: (Int, NSTimeInterval)]!

    // Non persitent data, initialized in init(), then set in setup()
    var recognizers: [UIGestureRecognizer: Int]!
    var taskbuttonviews: [Int: TaskPickerButtonView]!
    var moc: NSManagedObjectContext!

    var appLog: AppLog!
    var logger: AppLogger?
	
    init(vc: TaskPickerVC, backgroundView:TaskPickerBackgroundView,
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

        appLog.log(logger!, logtype: .EnterExit, message: "init")

        self.session = session

        self.vc = vc
//        self.statusView = statusView
        self.backgroundView = backgroundView

		self.layout = layout
		self.theme = theme
        self.taskSelectionStrategy = taskSelectionStrategy

        self.sessionSummary = session.getSessionSummary(moc)
            
        self.moc = moc

        self.recognizers = [:]
        self.taskbuttonviews = [:]
	}

    // Non presistent local attributes, setup when initialising the view
	var updateActiveActivityTimer: NSTimer?
    var sessionNameView: ToolView?
	var signInSignOutView: ToolView?
	var infoAreaView: ToolView?
	var settingsView: ToolView?


    //--------------------------------------------------
	// TaskPicker - setup
    //--------------------------------------------------

	func setup() {
        appLog.log(logger!, logtype: .EnterExit, message: "setup")

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

        // Setup sessionname
        var viewRect = layout.getViewRect(backgroundView.frame, selectionArea: SessionName)
        sessionNameView = ToolView(frame: viewRect)
        sessionNameView!.theme = theme
        sessionNameView!.toolbarInfoDelegate = self
        sessionNameView!.tool = SessionName
        backgroundView.addSubview(sessionNameView!)

		// Setup sign in/out button
		viewRect = layout.getViewRect(backgroundView.frame, selectionArea: SignInSignOut)
	    signInSignOutView = ToolView(frame: viewRect)
		signInSignOutView!.theme = theme
		signInSignOutView!.toolbarInfoDelegate = self
		signInSignOutView!.tool = SignInSignOut
		var recognizer = UITapGestureRecognizer(target:self, action:Selector("handleTapSigninSignout:"))
	    recognizer.delegate = self
	    signInSignOutView!.addGestureRecognizer(recognizer)
		backgroundView.addSubview(signInSignOutView!)

		// Setup infoarea
		viewRect = layout.getViewRect(backgroundView.frame, selectionArea: InfoArea)
	    infoAreaView = ToolView(frame: viewRect)
		infoAreaView!.theme = theme
		infoAreaView!.toolbarInfoDelegate = self
		infoAreaView!.tool = InfoArea
		backgroundView.addSubview(infoAreaView!)

		// Setup settings
		viewRect = layout.getViewRect(backgroundView.frame, selectionArea: Settings)
	    settingsView = ToolView(frame: viewRect)
		settingsView!.theme = theme
		settingsView!.toolbarInfoDelegate = self
		settingsView!.tool = Settings
		recognizer = UITapGestureRecognizer(target:self, action:Selector("handleTapSettings:"))
	    recognizer.delegate = self
	    settingsView!.addGestureRecognizer(recognizer)
		backgroundView.addSubview(settingsView!)
        
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
        appLog.log(logger!, logtype: .EnterExit, message: "redraw")

        sessionSummary = session.getSessionSummary(moc)

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
        appLog.log(logger!, logtype: .EnterExit, message: "handleTapSettings")
    }


    // Tap on sign in/sign out, call taskSignIn/taskSignOut and update views

    func handleTapSigninSignout(sender: UITapGestureRecognizer) {
        appLog.log(logger!, logtype: .EnterExit, message: "handleTapSigninSignout")

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

        appLog.log(logger!, logtype: .EnterExit) { TimePoliceModelUtils.getSessionWork(self.session) }
    }


    // Tap on new task, call taskSignIn/taskSignOut and update views

    func handleTap(sender: UITapGestureRecognizer) {
        appLog.log(logger!, logtype: .EnterExit, message: "handleTap")

        let taskList = session.tasks.array as! [Task]
        
        if let work = session.getLastWork() {
            if work.isOngoing() {
                setLastWorkAsFinished()
                let taskIndex = find(taskList, work.task as Task)
                taskbuttonviews[taskIndex!]?.setNeedsDisplay()
            }
        }

        let taskIndex = recognizers[sender]
        let task = taskList[taskIndex!]

        addNewWork(task)

        taskbuttonviews[taskIndex!]?.setNeedsDisplay()
        signInSignOutView?.setNeedsDisplay()
        infoAreaView?.setNeedsDisplay()

        appLog.log(logger!, logtype: .EnterExit) { TimePoliceModelUtils.getSessionWork(self.session) }
    }

    // Long press on task, edit current work

    func handleLongPress(sender: UILongPressGestureRecognizer) {
        appLog.log(logger!, logtype: .EnterExit, message: "handleLongPress")

        if sender.state != UIGestureRecognizerState.Began {
            return
        }

        if let work = session.getLastWork() {
            
            let taskList = session.tasks.array as! [Task]
            let taskIndex = recognizers[sender]
            let task = taskList[taskIndex!]
            if work.isOngoing() && work.task != task {
                appLog.log(logger!, logtype: .EnterExit, message: "Work is ongoing, LongPress on inactive task")
                return
            }

            vc.selectedWork = work
            vc.selectedWorkIndex = session.work.count-1

            vc.performSegueWithIdentifier("EditWork", sender: vc)
        } else {
            appLog.log(logger!, logtype: .EnterExit, message: "No last work")
        }

    }


    //--------------------------------------------
    //  TaskPicker - Sign int/out
    //--------------------------------------------

    // Update currentWork when sign in to a task

    func addNewWork(task: Task) {
        appLog.log(logger!, logtype: .EnterExit, message: "addWork")

        let w = Work.createInMOC(self.moc, name: "", session: session, task: task)

        TimePoliceModelUtils.save(moc)
    }

    // Update currentWork, previousTask, numberOfTimesActivated and totalTimeActive when sign out from a task

    func setLastWorkAsFinished() {
        appLog.log(logger!, logtype: .EnterExit, message: "setLastWorkFinished")

        //if let work = currentWork {
        if let work = session.getLastWork() {
            if work.isOngoing() {
                work.setStoppedAt(NSDate())

                var taskSummary: (Int, NSTimeInterval) = (0, 0)
                if let t = sessionSummary[work.task] {
                    taskSummary = t
                }
                var (numberOfTimesActivated, totalTimeActive) = taskSummary
                numberOfTimesActivated++
                totalTimeActive += work.stopTime.timeIntervalSinceDate(work.startTime)
                sessionSummary[work.task] = (numberOfTimesActivated, totalTimeActive)

                TimePoliceModelUtils.save(moc)
            } else {
                appLog.log(logger!, logtype: .EnterExit, message: "last work not ongoing")
            }
        } else {
            appLog.log(logger!, logtype: .EnterExit, message: "no work in list")
        }
    }

    func setLastWorkAsOngoing() {
        appLog.log(logger!, logtype: .EnterExit, message: "setLastWorkOngoing")

        //if let work = currentWork {
        if let work = session.getLastWork() {
            if !work.isOngoing() {
                var taskSummary: (Int, NSTimeInterval) = (0, 0)
                if let t = sessionSummary[work.task] {
                    taskSummary = t
                }
                var (numberOfTimesActivated, totalTimeActive) = taskSummary
                numberOfTimesActivated--
                totalTimeActive -= work.stopTime.timeIntervalSinceDate(work.startTime)
                sessionSummary[work.task] = (numberOfTimesActivated, totalTimeActive)

                work.setAsOngoing()

                TimePoliceModelUtils.save(moc)
            } else {
                appLog.log(logger!, logtype: .EnterExit, message: "last work not finished")
            }
        } else {
            appLog.log(logger!, logtype: .EnterExit, message: "no work in list")
        }
    }


    //--------------------------------------------------------------
    // TaskPicker - Periodic update of views, triggered by timeout
    //--------------------------------------------------------------

    @objc
    func updateActiveTask(timer: NSTimer) {
        //print(".")
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
        appLog.log(logger!, logtype: .EnterExit) { "getSelectionAreaInfo\(selectionArea)"}

        let taskList = session.tasks.array as! [Task]
        let task = taskList[selectionArea]

        var taskSummary: (Int, NSTimeInterval) = (0, 0)
        if let t = sessionSummary[task] {
            taskSummary = t
        }
        let (numberOfTimesActivated, totalTimeActive) = taskSummary

        var active = false
        var activatedAt = NSDate()
        if let work = session.getLastWork() {
            if work.isOngoing() {
                if taskList[selectionArea] == work.task {
                    active = true
                    activatedAt = work.startTime
                }
            }
        }

        let selectionAreaInfo = SelectionAreaInfo(
            task: task,
            numberOfTimesActivated: numberOfTimesActivated,
            totalTimeActive: totalTimeActive,
            active: active,
            activatedAt: activatedAt)
 		return selectionAreaInfo
	}

	// ToolbarInfoDelegate

    func getToolbarInfo() -> ToolbarInfo {
        appLog.log(logger!, logtype: .EnterExit, message: "getToolbarInfo")

        var totalActivations: Int = 1 // The first task is active when first selected
        var totalTime: NSTimeInterval = 0
        
        for (task, (activations, time)) in sessionSummary {
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


 






