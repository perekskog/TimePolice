//
//  TaskPickerViewController.swift
//  TimePolice
//
//  Created by Per Ekskog on 2014-11-04.
//  Copyright (c) 2014 Per Ekskog. All rights reserved.
//


/* TODO

- getSelectionAreaInfo
  Är det Theme som gr uträkning av tid för aktuell task? Kasnek inte så bra...

- gestureRecognizer
  Hur ska den implementeras, får kompileringsfel?

*/

import UIKit
import CoreData

//==================================================
//==================================================
//  TaskPickerViewController
//==================================================

class TaskPickerViewController: UIViewController
	{

    var session: Session?
    var sourceController: TimePoliceViewController?
    var tp: TaskPicker?
    
    var statusView: UITextView?

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let theme = BlackGreenTheme()
//        let theme = BasicTheme()
        let layout = GridLayout(rows: 7, columns: 3, padding: 1, toolbarHeight: 30)
        let taskSelectionStrategy = TaskSelectAny()
        
        /*1.2OK*/
        (self.view as! TimePoliceBackgroundView).theme = theme

        var tpRect = self.view.bounds
        tpRect.origin.x = 0
        tpRect.size.width -= 0
        tpRect.origin.y += 25
        tpRect.size.height -= 158
        let taskPickerBackgroundView = TaskPickerBackgroundView(frame: tpRect)
        self.view.addSubview(taskPickerBackgroundView)

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
        
        let exitRect = CGRect(origin: CGPoint(x: self.view.bounds.size.width - 80, y: self.view.bounds.size.height-120), size: CGSize(width:70, height:30))
        let exitButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        exitButton.frame = exitRect
        exitButton.backgroundColor = UIColor(red: 0.0, green: 0.7, blue: 0.0, alpha: 1.0)
        exitButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        exitButton.setTitle("EXIT", forState: UIControlState.Normal)
        exitButton.addTarget(self, action: "exit:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(exitButton)

        TextViewLogger.log(statusView!, message: String("\n\(getString(NSDate())) TaskPickerVC.viewDidLoad"))

        if let s = session {
            if let moc = self.managedObjectContext {
                tp = TaskPicker(vc: self, statusView: statusView!, backgroundView: taskPickerBackgroundView,
                    layout: layout, theme: theme, taskSelectionStrategy: taskSelectionStrategy,
                    session: s, moc: moc)
            
                tp?.setup()
                TextViewLogger.log(statusView!, message: TimePoliceModelUtils.getSessionWork(s))
            }
        }


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        TextViewLogger.log(statusView!, message: String("\n\(getString(NSDate())) TaskPickerVC.didReceiveMemoryWarning"))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        TextViewLogger.log(statusView!, message: String("\n\(getString(NSDate())) TaskPickerVC.viewWillAppear"))
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.orangeColor()]
    }
    
    //---------------------------------------------
    // TaskPickerViewController - Segue handling
    //---------------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        TextViewLogger.log(statusView!, message: String("\n\(getString(NSDate())) TaskPickerVC.prepareForSegue(\(segue.identifier)"))

        if segue.identifier == "EditWork" {
            if let s = session {
                TextViewLogger.log(statusView!, message: TimePoliceModelUtils.getSessionWork(s))
            }

            let vc = segue.destinationViewController as! TaskPickerEditWorkViewController
            
            if let s = session {
                vc.taskList = s.tasks.array as? [Task]
                vc.maximumDate = NSDate()
                if let wl = s.work.array as? [Work] {
                    if wl.count >= 1 {
                        // At least one item: Set as item to edit.
                        vc.work = wl[wl.count-1]
                    }
                    if wl.count >= 2 {
                        // If at least two items: Limit how far back in time the datepicker can go.
                        vc.minimumDate = wl[wl.count-2].startTime
                    }
                }
            }
        }
    }

    @IBAction func cancelEditWork(unwindSegue: UIStoryboardSegue ) {
        TextViewLogger.log(statusView!, message: "\(getString(NSDate())) TaskPickerVC.cancelEditWork")
    }

    @IBAction func okEditWork(unwindSegue: UIStoryboardSegue ) {
        TextViewLogger.log(statusView!, message: "\(getString(NSDate())) TaskPickerVC.okEditWork")

        if unwindSegue.identifier == "OkEditWork" {

            let vc = unwindSegue.sourceViewController as! TaskPickerEditWorkViewController

            if let moc = managedObjectContext,
                     s = session {

                if let t = vc.taskToUse {
                    // Change task if this attribute was set
                    TextViewLogger.log(statusView!, message: "\nEditWork selected task=\(t.name)")
                    if let w = session?.getLastWork() {
                        w.task = t
                    }
                } else {
                    TextViewLogger.log(statusView!, message: "\nEditWork no task selected")
                }
                
                if let initialDate = vc.initialDate {
                    TextViewLogger.log(statusView!, message: "\nEditWork initial date=\(getString(initialDate))")
                    TextViewLogger.log(statusView!, message: "\nEditWork selected date=\(getString(vc.datePicker.date))")
                }
                
                if initialDate != vc.datePicker.date {
                    // Change starttime is time has been changed
                    TextViewLogger.log(statusView!, message: "\nSelected time != initial time, setting starttime")
                    s.setStartTime(moc, workIndex: s.work.count-1, desiredStartTime: vc.datePicker.date)
                } else {
                    TextViewLogger.log(statusView!, message: "\nSelected time = initial time, don't set starttime")
                }

                TimePoliceModelUtils.save(moc)

                TextViewLogger.log(statusView!, message: "\n" + TimePoliceModelUtils.getSessionWork(s))
            }
            
            tp?.redraw()
        }
    }

    func exit(sender: UIButton) {
        TextViewLogger.log(statusView!, message: "\(getString(NSDate())) TaskPickerVC.exit")

        sourceController?.exitFromSegue()
        self.navigationController?.popViewControllerAnimated(true)
        tp?.updateActiveActivityTimer?.invalidate()
    }

    
    //--------------------------------------------------
    // TaskPickerViewController - CoreData MOC
    //--------------------------------------------------
    
    lazy var managedObjectContext : NSManagedObjectContext? = {

        /*1.2OK*/
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
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
    var vc: TaskPickerViewController!
    var statusView: UITextView!
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
	
    init(vc: TaskPickerViewController, statusView: UITextView, backgroundView:TaskPickerBackgroundView,
        layout: Layout, theme: Theme, taskSelectionStrategy: TaskSelectionStrategy, 
        session: Session,
        moc: NSManagedObjectContext) {
            
        TextViewLogger.log(statusView, message: "\(getString(NSDate())) TaskPicker.init")

        self.session = session

        self.vc = vc
        self.statusView = statusView
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
	var signInSignOutView: ToolView?
	var infoAreaView: ToolView?
	var settingsView: ToolView?


    //--------------------------------------------------
	// TaskPicker - setup
    //--------------------------------------------------

	func setup() {
        TextViewLogger.log(statusView!, message: "\(getString(NSDate())) TaskPicker.setup")

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
        TextViewLogger.log(statusView,  message: String("\n\(getString(NSDate())) TaskPicker.handleTapSettings"))
    }


    // Tap on sign in/sign out, call taskSignIn/taskSignOut and update views

    func handleTapSigninSignout(sender: UITapGestureRecognizer) {
        TextViewLogger.log(statusView, message: String("\n\(getString(NSDate())) TaskPicker.handleTapSigninSignout"))

        let taskList = session.tasks.array as! [Task]
        
        if let work = session.getLastWork() {
            if work.isOngoing() {
               // Work ongoing => sign out
                let taskIndex = find(taskList, work.task as Task)
                taskSignOut(work.task as Task)
                taskbuttonviews[taskIndex!]?.setNeedsDisplay()
            } else {
                // No ongoing work => sign in to previous task
                let task = work.task
                let taskIndex = find(taskList, task)
                taskSignIn(task)
                taskbuttonviews[taskIndex!]?.setNeedsDisplay()
            }
        } else {
            // Empty worklist => do nothing
        }

        signInSignOutView?.setNeedsDisplay()
        infoAreaView?.setNeedsDisplay()

        TextViewLogger.log(statusView, message: TimePoliceModelUtils.getSessionWork(session))
    }


    // Tap on new task, call taskSignIn/taskSignOut and update views

    func handleTap(sender: UITapGestureRecognizer) {
        TextViewLogger.log(statusView, message: String("\n\(getString(NSDate())) TaskPicker.handleTap"))

        let taskList = session.tasks.array as! [Task]
        
        if let work = session.getLastWork() {
            if work.isOngoing() {
                let taskIndex = find(taskList, work.task as Task)
                taskSignOut(work.task as Task)
                taskbuttonviews[taskIndex!]?.setNeedsDisplay()
            }
        }

        let taskIndex = recognizers[sender]
        let task = taskList[taskIndex!]

        taskSignIn(task)

        taskbuttonviews[taskIndex!]?.setNeedsDisplay()
        signInSignOutView?.setNeedsDisplay()
        infoAreaView?.setNeedsDisplay()

        TextViewLogger.log(statusView, message: TimePoliceModelUtils.getSessionWork(session))
    }

    // Long press on task, edit current work

    func handleLongPress(sender: UILongPressGestureRecognizer) {

        if sender.state != UIGestureRecognizerState.Began {
            return
        }

        TextViewLogger.log(statusView,  message: String("\n\(getString(NSDate())) TaskPicker.handleLongPress"))

        if let work = session.getLastWork()
            where work.isOngoing() {
            
            let taskList = session.tasks.array as! [Task]
            let taskIndex = recognizers[sender]
            let task = taskList[taskIndex!]
            if work.task != task {
                TextViewLogger.log(statusView,  message: String("\n\(getString(NSDate())) Work is ongoing, LongPress on inactive task"))
                return
            }

            vc.performSegueWithIdentifier("EditWork", sender: vc)
        } else {
            TextViewLogger.log(statusView,  message: String("\n\(getString(NSDate())) No last work or signed out"))            
        }

    }


    //--------------------------------------------
    //  TaskPicker - Sign int/out
    //--------------------------------------------

    // Update currentWork when sign in to a task

    func taskSignIn(task: Task) {
        TextViewLogger.log(statusView, message: String("\n\(getString(NSDate())) TaskPicker.taskSignIn(\(task.name))"))

        let w = Work.createInMOC(self.moc, name: "", session: session, task: task)

        TimePoliceModelUtils.save(moc)
    }

    // Update currentWork, previousTask, numberOfTimesActivated and totalTimeActive when sign out from a task

    func taskSignOut(task: Task) {
        TextViewLogger.log(statusView, message:String("\n\(getString(NSDate())) TaskPicker.taskSignOut(\(task.name))"))

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
                TextViewLogger.log(statusView, message:String("\n\(getString(NSDate())) TaskPicker.taskSignOut - no work ongoing"))
            }
        } else {
            TextViewLogger.log(statusView, message:String("\n\(getString(NSDate())) TaskPicker.taskSignOut - no work"))
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
    		totalTimeActiveForSession: totalTime)

    	return toolbarInfo
    }

}


 






