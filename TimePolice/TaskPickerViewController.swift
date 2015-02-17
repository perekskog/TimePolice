//
//  TaskPickerViewController.swift
//  TimePolice
//
//  Created by Per Ekskog on 2014-11-04.
//  Copyright (c) 2014 Per Ekskog. All rights reserved.
//


import UIKit
import CoreData

class TaskPickerViewController: UIViewController
	{

    var taskList: [Task]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
//        self.navigationController!.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        
//        self.navigationController!.navigationBar.barStyle = UIBarStyle.Black
//        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
//        let theme = BlackGreenTheme()
        let theme = BasicTheme()
        let layout = GridLayout(rows: 7, columns: 3, padding: 1, toolbarHeight: 30)
        let taskSelectionStrategy = TaskSelectAny()
        
        (self.view as TimePoliceBackgroundView).theme = theme

        var tpRect = self.view.bounds
        tpRect.origin.x = 5
        tpRect.size.width -= 10
        tpRect.origin.y += 30
        tpRect.size.height -= 158
        let taskPickerBackgroundView = TaskPickerBackgroundView(frame: tpRect)
        self.view.addSubview(taskPickerBackgroundView)

        var statusRect = self.view.bounds
        statusRect.origin.x = 5
        statusRect.size.width -= 10
        statusRect.origin.y = statusRect.size.height-110
        statusRect.size.height = 100
        let statusView = UITextView(frame: statusRect)
        statusView.backgroundColor = UIColor(white: 0.0, alpha: 1.0)
        statusView.textColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        statusView.font = UIFont.systemFontOfSize(10)
        statusView.editable = false
        self.view.addSubview(statusView)
        
        TextViewLogger.reset(statusView)
        TextViewLogger.log(statusView, message: String("\n\(NSDate()):ViewController.viewDidLoad"))

        var tp = TaskPicker(statustext: statusView, backgroundView: taskPickerBackgroundView,
            layout: layout, theme: theme, taskSelectionStrategy: taskSelectionStrategy,
            taskList: taskList!, totalTimeActive: [:], numberOfTimesActivated:[:])
        tp.setup()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
//        TextViewLogger.log(statustext, message: String("\n\(getString(NSDate())) ViewController.didReceiveMemoryWarning"))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.orangeColor()]
    }


}


///////////////////////////////////////////////////
// TaskPicker and TaskPickerTaskSelectionDelegate

class TaskPicker: NSObject, UIGestureRecognizerDelegate, ToolbarInfoDelegate, SelectionAreaInfoDelegate {
    // Persistent data form the model, set at creation time
    var taskList: [Task]!
    var currentWork: Work?
    var previousTask: Task?

	// Views, set at creation time
    var statustext: UITextView
    var backgroundView:TaskPickerBackgroundView!

    // Preferences, set at creation time
	var layout: Layout!
	var theme: Theme!
    var taskSelectionStrategy: TaskSelectionStrategy!

    // Cached values, calculated at startup
	var totalTimeActive: [String: NSTimeInterval]!
    var numberOfTimesActivated: [String: Int]!

    // Non persitent data, initialized in init(), then set in setup()
    var recognizers: [UIGestureRecognizer: Int]!
    var views: [Int: TaskPickerButtonView]!
	
    init(statustext: UITextView, backgroundView:TaskPickerBackgroundView, 
        layout: Layout, theme: Theme, taskSelectionStrategy: TaskSelectionStrategy, 
        taskList: [Task], totalTimeActive: [String: NSTimeInterval], numberOfTimesActivated: [String: Int]) {
        self.statustext = statustext
        self.backgroundView = backgroundView

		self.layout = layout
		self.theme = theme
        self.taskSelectionStrategy = taskSelectionStrategy

		self.taskList = taskList
        self.totalTimeActive = totalTimeActive // Was: [:]
        self.numberOfTimesActivated = numberOfTimesActivated // Was: [:]

        self.recognizers = [:]
        self.views = [:]
	}

    // Non presistent local attributes, setup when initialising the view
    // var currentTaskIndex = -1
	var updateActiveActivityTimer: NSTimer?
	var signInSignOutView: ToolView?
	var infoAreaView: ToolView?
	var settingsView: ToolView?



	// Uninitialized properties

	func setup() {
		backgroundView.theme = theme

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
    }





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
        // SHould use taskSelectionStrategy
        return true
    }





    // Tap on settings    

    func handleTapSettings(sender: UITapGestureRecognizer) {
        TextViewLogger.log(statustext,  message: String("\n\(getString(NSDate())) TaskPicker.handleTapSettings"))
    }
        


    // Tap on sign in/sign out, call taskSignIn/taskSignOut and update views

    func handleTapSigninSignout(sender: UITapGestureRecognizer) {
        TextViewLogger.log(statustext, message: String("\n\(getString(NSDate())) TaskPicker.handleTapSigninSignout"))

        if let work = currentWork {
            // Sign out
            let taskIndex = find(taskList, work.task as Task)
            taskSignOut(work.task as Task)
            views[taskIndex!]?.setNeedsDisplay()
        } else {
            // Sign in if there is a previous task to sign in to
            if let task = previousTask {
                let taskIndex = find(taskList, task)
                taskSignIn(task)
                views[taskIndex!]?.setNeedsDisplay()
            }
        }

        signInSignOutView?.setNeedsDisplay()
        infoAreaView?.setNeedsDisplay()
    }


    // Tap on new task, call taskSignIn/taskSignOut and update views

    func handleTap(sender: UITapGestureRecognizer) {
        TextViewLogger.log(statustext, message: String("\n\(getString(NSDate())) TaskPicker.handleTap"))

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


    // Update currentWork when sign in to a task

    func taskSignIn(task: Task) {
        TextViewLogger.log(statustext, message: String("\n\(getString(NSDate())) TaskPicker.taskSignIn(\(task.name))"))

        currentWork = Work.createInMOC(self.managedObjectContext!, name: "")
        currentWork?.task = task
        currentWork?.startTime = NSDate()
    }

    // Update currentWork, previousTask, numberOfTimesActivated and totalTimeActive when sign out from a task

    func taskSignOut(task: Task) {
        TextViewLogger.log(statustext, message:String("\n\(getString(NSDate())) TaskPicker.taskSignOut(\(task.name))"))

        if let work = currentWork {
            work.stopTime = NSDate()

            var nn = 1
            if var n = numberOfTimesActivated[task.name]? {
                nn = n+1
            }
            numberOfTimesActivated[task.name] = nn

            var mm = work.stopTime.timeIntervalSinceDate(work.startTime)
        	if var m = totalTimeActive[task.name]? {
                mm = m + mm
            }
            totalTimeActive[task.name] = mm

            previousTask = work.task
        }

        currentWork = nil
    }




    // Periodic update of views, triggered by timeout

    @objc
    func updateActiveTask(timer: NSTimer) {
//        if currentTaskIndex >= 0 {
        if let currentTask = currentWork?.task {
            if let currentTaskIndex = find(taskList, currentTask as Task) {
                let view = views[currentTaskIndex]
                views[currentTaskIndex]?.setNeedsDisplay()
                infoAreaView?.setNeedsDisplay()
            }
        }
    }




	// SelectionAreaInfoDelegate

	func getSelectionAreaInfo(selectionArea: Int) -> SelectionAreaInfo {
		let task = taskList![selectionArea]
        var nn: Int = 0
        if let n = numberOfTimesActivated[task.name]? {
            nn = n
        }
        var mm: NSTimeInterval = 0
        if let m = totalTimeActive![task.name]? {
            mm = m
        }
        var active = false
        var activatedAt = NSDate()
        if let work = currentWork? {
            if taskList![selectionArea] == work.task {
                active = true
                activatedAt = work.startTime
            }
        }
        let selectionAreaInfo = SelectionAreaInfo(
            task: task,
            numberOfTimesActivated: nn,
            totalTimeActive: mm,
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

    	var totalActivations: Int = 1 // THe first task is active when first selected
    	for (task, activations) in numberOfTimesActivated {
    		totalActivations += activations
    	}
    	
    	var totalTime: NSTimeInterval = 0
    	for (task, time) in totalTimeActive {
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

    /////////////////////
    // CoreData
    
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
        }()
    
    func save() {
        var error : NSError?
        if(managedObjectContext!.save(&error) ) {
            println("Save: error(\(error?.localizedDescription))")
        }
    }
    
    
    func dumpData() {
        println("Projects")
        let fetchRequest1 = NSFetchRequest(entityName: "Project")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest1, error: nil) as? [Project] {
            for project in fetchResults {
                println("\(project.name)")
            }
        }
    }


}


 






