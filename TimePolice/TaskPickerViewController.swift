//
//  TaskPickerViewController.swift
//  TimePolice
//
//  Created by Per Ekskog on 2014-11-04.
//  Copyright (c) 2014 Per Ekskog. All rights reserved.
//


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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let theme = BlackGreenTheme()
//        let theme = BasicTheme()
        let layout = GridLayout(rows: 7, columns: 3, padding: 1, toolbarHeight: 30)
        let taskSelectionStrategy = TaskSelectAny()
        
        (self.view as TimePoliceBackgroundView).theme = theme

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
        let statusView = UITextView(frame: statusRect)
        statusView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        statusView.textColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        statusView.font = UIFont.systemFontOfSize(8)
        statusView.editable = false
        self.view.addSubview(statusView)
        
        let exitRect = CGRect(origin: CGPoint(x: self.view.bounds.size.width - 80, y: self.view.bounds.size.height-120), size: CGSize(width:70, height:30))
        let exitButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        exitButton.frame = exitRect
        exitButton.backgroundColor = UIColor(red: 0.0, green: 0.7, blue: 0.0, alpha: 1.0)
        exitButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        exitButton.setTitle("EXIT", forState: UIControlState.Normal)
        exitButton.addTarget(self, action: "exit:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(exitButton)

        
        
        // TextViewLogger.reset(statusView)
        TextViewLogger.log(statusView, message: String("\n\(NSDate()):ViewController.viewDidLoad"))


        if let s = session {
            if let moc = self.managedObjectContext {
                tp = TaskPicker(vc: self, statustext: statusView, backgroundView: taskPickerBackgroundView,
                    layout: layout, theme: theme, taskSelectionStrategy: taskSelectionStrategy,
                    session: s, moc: moc)
            
                tp?.setup()
                TextViewLogger.log(statusView, message: TimePoliceModelUtils.getSessionWork(s))
            }
        }


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // TextViewLogger.log(statustext, message: String("\n\(getString(NSDate())) ViewController.didReceiveMemoryWarning"))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.orangeColor()]
    }
    
    //---------------------------------------------
    // TaskPickerViewController - Segue exit
    //---------------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditWork" {
            if let s = session {
                TimePoliceModelUtils.dumpSessionWork(s)
            }

            let vc = segue.destinationViewController as TaskPickerEditWorkViewController
            if let s = session {
                vc.taskList = s.tasks.array as? [Task]
                if let wl = s.work.array as? [Work] {
                    if wl.count >= 1 {
                        vc.work = wl[wl.count-1]
                    }
                    if wl.count >= 2 {
                        vc.minimumDate = wl[wl.count-2].startTime
                    }
                }
            }
        }
    }

    @IBAction func cancelEditWork(unwindSegue: UIStoryboardSegue ) {
        // Only "implemented" to satisfy a respondsToSelector: search.
        // You can actually implement more stuff here, if you want, IE, if
        // you need to reach out to a server to mention that this screen was
        // returned to from a later screen.
        println("cancelEditWork")
    }

    @IBAction func okEditWork(unwindSegue: UIStoryboardSegue ) {
        // Only "implemented" to satisfy a respondsToSelector: search.
        // You can actually implement more stuff here, if you want, IE, if
        // you need to reach out to a server to mention that this screen was
        // returned to from a later screen.

        println("okEditWork")

        if unwindSegue.identifier == "OkEditWork" {

            let vc = unwindSegue.sourceViewController as TaskPickerEditWorkViewController

            if let t = vc.taskToUse {
                println("taskToUse=\(t.name)")
                if let s = session {
                    if let wl = s.work.array as? [Work] {
                        if wl.count >= 1 {
                            wl[wl.count-1].task = t
                        }
                    } 
                }
            }
            
            println("Initial=\(vc.initialDate), current=\(vc.datePicker.date)")
            if vc.datePicker.date != vc.initialDate {
                if let s = session {
                    if let wl = s.work.array as? [Work] {
                        if wl.count >= 1 {
                            wl[wl.count-1].startTime = vc.datePicker.date
                        }
                        if wl.count >= 2 {
                            wl[wl.count-2].stopTime = vc.datePicker.date
                        }
                    }   
                }
            }
        }

        if let moc = managedObjectContext {
            TimePoliceModelUtils.save(moc)
        }

        if let s = session {
            TimePoliceModelUtils.dumpSessionWork(s)
        }
    }

    

    //---------------------------------------------
    // TaskPickerViewController - Buttons
    //---------------------------------------------

    func exit(sender: UIButton) {
        sourceController?.exitFromSegue()
        self.navigationController?.popViewControllerAnimated(true)
        tp?.updateActiveActivityTimer?.invalidate()
    }
    
    //--------------------------------------------------
    // TaskPickerViewController - CoreData MOC & save
    //--------------------------------------------------
    
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
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
    var statustext: UITextView!
    var backgroundView:TaskPickerBackgroundView!

    // Preferences, set at creation time
	var layout: Layout!
	var theme: Theme!
    var taskSelectionStrategy: TaskSelectionStrategy!

    // Cached values, calculated at startup
	var sessionSummary: [Task: (Int, NSTimeInterval)]!

    // Non persitent data, initialized in init(), then set in setup()
    var recognizers: [UIGestureRecognizer: Int]!
    var views: [Int: TaskPickerButtonView]!
    var moc: NSManagedObjectContext!

    // Non persistent data, empty at start
    var currentWork: Work?

	
    init(vc: TaskPickerViewController, statustext: UITextView, backgroundView:TaskPickerBackgroundView,
        layout: Layout, theme: Theme, taskSelectionStrategy: TaskSelectionStrategy, 
        session: Session,
        moc: NSManagedObjectContext) {

        self.session = session

        self.vc = vc
        self.statustext = statustext
        self.backgroundView = backgroundView

		self.layout = layout
		self.theme = theme
        self.taskSelectionStrategy = taskSelectionStrategy

        self.sessionSummary = session.getSessionSummary(moc)
            
        self.moc = moc

        self.recognizers = [:]
        self.views = [:]
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
		backgroundView.theme = theme
        let taskList = session.tasks.array as [Task]
		// Setup task buttons
		let numberOfButtonsToDraw = min(taskList.count, layout.numberOfSelectionAreas())
		for i in 0..<numberOfButtonsToDraw {
			let viewRect = layout.getViewRect(backgroundView.frame, selectionArea: i)
            let view = TaskPickerButtonView(frame: viewRect)
			view.theme = theme
			view.selectionAreaInfoDelegate = self
			view.taskPosition = i

			let recognizer = UITapGestureRecognizer(target:self, action:Selector("handleTap:"))
            recognizer.delegate = self

            view.addGestureRecognizer(recognizer)
			recognizers[recognizer] = i
            views[i] = view

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
        
        // Check last work item, is something ongoing?
        if session.work.count > 0 {
            // Found a work item, look at the last one
            let work = session.work.objectAtIndex(session.work.count-1) as Work

            // If start==stop it is ongoing work
            if work.startTime == work.stopTime {
                TextViewLogger.log(statustext, message: String("\nOW: \(work.task.name) \(work.startTime)->\(work.stopTime)"))
                currentWork = work
            } else {
                TextViewLogger.log(statustext, message: String("\nNo ongoing work"))
            }
        } else {
            TextViewLogger.log(statustext, message: String("\nWorklist empty"))
        }
        
        TimePoliceModelUtils.dumpSessionWork(session)
    }




    //------------------------------------
    //  TaskPicker - SelectionStrategy
    //------------------------------------

	// Gesture recognizer delegate

    func gestureRecognizer(gestureRecognizer: UITapGestureRecognizer,
        shouldReceiveTouch touch: UITouch) -> Bool {
            if let taskNumber = recognizers[gestureRecognizer] {
                return taskIsSelectable(taskNumber)
            } else {
                return true
            }
	}

    func taskIsSelectable(taskNumber: Int) -> Bool {
        // Should use taskSelectionStrategy
        return true
    }


    //-------------------------------------
    //  TaskPicker - Tap on buttons
    //-------------------------------------

    // Tap on settings    

    func handleTapSettings(sender: UITapGestureRecognizer) {
        TextViewLogger.log(statustext,  message: String("\n\(getString(NSDate())) TaskPicker.handleTapSettings"))
        vc.performSegueWithIdentifier("EditWork", sender: vc)
    }
        


    // Tap on sign in/sign out, call taskSignIn/taskSignOut and update views

    func handleTapSigninSignout(sender: UITapGestureRecognizer) {
        TextViewLogger.log(statustext, message: String("\n\(getString(NSDate())) TaskPicker.handleTapSigninSignout"))

        let taskList = session.tasks.array as [Task]
        
        if session.work.count >= 1 {
            // At least one item in worklist, look at the last item
            let work = session.work[session.work.count-1] as Work
            if work.startTime == work.stopTime {
               // Work ongoing => sign out
                let taskIndex = find(taskList, work.task as Task)
                taskSignOut(work.task as Task)
                views[taskIndex!]?.setNeedsDisplay()
            } else {
                // No ongoing work => sign in to previous task
                let task = work.task
                let taskIndex = find(taskList, task)
                taskSignIn(task)
                views[taskIndex!]?.setNeedsDisplay()
            }
        } else {
            // Empty worklist => do nothing
        }

        signInSignOutView?.setNeedsDisplay()
        infoAreaView?.setNeedsDisplay()
    }


    // Tap on new task, call taskSignIn/taskSignOut and update views

    func handleTap(sender: UITapGestureRecognizer) {
        TextViewLogger.log(statustext, message: String("\n\(getString(NSDate())) TaskPicker.handleTap"))

        let taskList = session.tasks.array as [Task]
        
        if let work = currentWork {
            let taskIndex = find(taskList, work.task as Task)
            taskSignOut(work.task as Task)
            views[taskIndex!]?.setNeedsDisplay()
        }

        let taskIndex = recognizers[sender]
        let task = taskList[taskIndex!]
        taskSignIn(task)
        views[taskIndex!]?.setNeedsDisplay()

        signInSignOutView?.setNeedsDisplay()
        infoAreaView?.setNeedsDisplay()
    }

    //--------------------------------------------
    //  TaskPicker - Sign int/out
    //--------------------------------------------

    // Update currentWork when sign in to a task

    func taskSignIn(task: Task) {
        TextViewLogger.log(statustext, message: String("\n\(getString(NSDate())) TaskPicker.taskSignIn(\(task.name))"))

        currentWork = Work.createInMOC(self.moc, name: "")
        if let w = currentWork {
            w.task = task
            w.startTime = NSDate()
            w.stopTime = w.startTime
            
            let sw = session.work.mutableCopy() as NSMutableOrderedSet
            sw.addObject(w)
            session.work = sw

            TimePoliceModelUtils.save(moc)
            
            TimePoliceModelUtils.dumpSessionWork(session)
            TextViewLogger.reset(statustext)
            TextViewLogger.log(statustext, message: TimePoliceModelUtils.getSessionWork(session))

        }
    }

    // Update currentWork, previousTask, numberOfTimesActivated and totalTimeActive when sign out from a task

    func taskSignOut(task: Task) {
        TextViewLogger.log(statustext, message:String("\n\(getString(NSDate())) TaskPicker.taskSignOut(\(task.name))"))

        if let work = currentWork {
            work.stopTime = NSDate()
            var taskSummary: (Int, NSTimeInterval) = (0, 0)
            if let t = sessionSummary[work.task] {
                taskSummary = t
            }
            var (numberOfTimesActivated, totalTimeActive) = taskSummary
            numberOfTimesActivated++
            totalTimeActive += work.stopTime.timeIntervalSinceDate(work.startTime)
            sessionSummary[work.task] = (numberOfTimesActivated, totalTimeActive)

            let sw = session.work.mutableCopy() as NSMutableOrderedSet
            sw.replaceObjectAtIndex(sw.count-1, withObject: work)
            session.work = sw

            TimePoliceModelUtils.save(moc)
        }

        currentWork = nil

        TimePoliceModelUtils.dumpSessionWork(session)
        TextViewLogger.reset(statustext)
        TextViewLogger.log(statustext, message: TimePoliceModelUtils.getSessionWork(session))

    }



    //---------------------------------------------------
    // TaskPicker - Periodic update of views, triggered by timeout
    //---------------------------------------------------

    @objc
    func updateActiveTask(timer: NSTimer) {
        //print(".")
        if let currentTask = currentWork?.task {
            let taskList = session.tasks.array as [Task]
            if let currentTaskIndex = find(taskList, currentTask as Task) {
                let view = views[currentTaskIndex]
                views[currentTaskIndex]?.setNeedsDisplay()
                infoAreaView?.setNeedsDisplay()
            }
        }
    }


    //----------------------------------------------
    //  TaskPicker - Button info
    //----------------------------------------------

	// SelectionAreaInfoDelegate

	func getSelectionAreaInfo(selectionArea: Int) -> SelectionAreaInfo {
        //print("gsl(\(selectionArea))")

        let taskList = session.tasks.array as [Task]
        let task = taskList[selectionArea]

        var taskSummary: (Int, NSTimeInterval) = (0, 0)
        if let t = sessionSummary[task] {
            taskSummary = t
        }
        let (numberOfTimesActivated, totalTimeActive) = taskSummary

        var active = false
        var activatedAt = NSDate()
        if let work = currentWork? {
            if taskList[selectionArea] == work.task {
                active = true
                activatedAt = work.startTime
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
    	var signedIn = false
    	if let work = currentWork {
    		signedIn = true
    	}

    	var totalActivations: Int = 1 // The first task is active when first selected
    	var totalTime: NSTimeInterval = 0

        for (task, (activations, time)) in sessionSummary {
            totalActivations += activations
            totalTime += time
        }

        if let work = currentWork {
	    	let timeForActiveTask = NSDate().timeIntervalSinceDate(work.startTime)
	    	totalTime += timeForActiveTask
	    }
    	
    	let toolbarInfo = ToolbarInfo(
    		signedIn: signedIn, 
    		totalTimesActivatedForSession: totalActivations,
    		totalTimeActiveForSession: totalTime)

    	return toolbarInfo
    }

}


 






