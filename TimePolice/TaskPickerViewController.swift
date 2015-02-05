//
//  TaskPickerViewController.swift
//  TimePolice
//
//  Created by Per Ekskog on 2014-11-04.
//  Copyright (c) 2014 Per Ekskog. All rights reserved.
//


import UIKit

class TaskPickerViewController: UIViewController
	{
    
    @IBOutlet var taskPickerView: TaskPickerBackgroundView!
    @IBOutlet var statustext: UITextView!

    var taskList: [Task]?
    var tp: TaskPicker?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        TextViewLogger.reset(statustext)
        TextViewLogger.log(statustext, message: String("\n\(NSDate()):ViewController.viewDidLoad"))

        let theme = BasicTheme()
        let layout = GridLayout(rows: 7, columns: 3)
        let taskSelectionStrategy = TaskSelectAny()
        
        (self.view as TimePoliceBackgroundView).theme = theme

        taskList = [
            Task(name: "I F2F"), Task(name: "---"), Task(name: "I Lync"),
            Task(name: "I Email"), Task(name: "I Ticket"), Task(name: "I Blixt"),
            Task(name: "P OF"), Task(name: "P Task"), Task(name: "P Ticket"),
            Task(name: "P US"), Task(name: "P Meeting"), Task(name: "P Other"),
            Task(name: "N Waste"), Task(name: "---"), Task(name: "N Not work"),
            Task(name: "N Connect"), Task(name: "N Down"), Task(name: "N Time in"),
            Task(name: "N Walking"), Task(name: "N Coffee/WC"),  Task(name: "N Other"),
		]
        
/*
        taskList = [
            Task(name: "Out"), Task(name: "Down"), Task(name: "Other"),
            Task(name: "Omnifocus"), Task(name: "Evernote"), Task(name: "---"),
            Task(name: "Dev"), Task(name: "Media")
        ]
*/
        
        if let workspace = taskPickerView {
            tp = TaskPicker(statustext: statustext, workspace: workspace, 
                layout: layout, theme: theme, taskSelectionStrategy: taskSelectionStrategy,
                taskList: taskList!, totalTimeActive: [:], numberOfTimesActivated:[:])
            tp!.setup()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        TextViewLogger.log(statustext, message: String("\n\(getString(NSDate())) ViewController.didReceiveMemoryWarning"))
    }


}


///////////////////////////////////////////////////
// TaskPicker and TaskPickerTaskSelectionDelegate

class TaskPicker: NSObject, UIGestureRecognizerDelegate, ToolbarInfoDelegate, SelectionAreaInfoDelegate {
	// Persistent attributes, set in init
    var statustext: UITextView
    var workspace:TaskPickerBackgroundView!

    // Preferences, set in init
	var layout: Layout!
	var theme: Theme!
    var taskSelectionStrategy: TaskSelectionStrategy!

    // Persistent attributes, to be replaced by a persistent session object
    var taskList: [Task]!
	var totalTimeActive: [String: NSTimeInterval]!
    var numberOfTimesActivated: [String: Int]!

    // Persistent attributes, to be set by creator if they are set
    var currentWork: Work?
    var previousTask: Task?

    // Non persitent attributes, initialized in init(), then set in setup()
    var recognizers: [UIGestureRecognizer: Int]!
    var views: [Int: TaskPickerButtonView]!
	
    init(statustext: UITextView, workspace:TaskPickerBackgroundView, 
        layout: Layout, theme: Theme, taskSelectionStrategy: TaskSelectionStrategy, 
        taskList: [Task], totalTimeActive: [String: NSTimeInterval], numberOfTimesActivated: [String: Int]) {
        self.statustext = statustext
        self.workspace = workspace

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
    var currentTaskIndex = -1
	var updateActiveActivityTimer: NSTimer?
	var signInSignOutView: ToolView?
	var infoAreaView: ToolView?
	var settingsView: ToolView?



	// Uninitialized properties

	func setup() {
		workspace.theme = theme

		// Setup task buttons
		let numberOfButtonsToDraw = min(taskList.count, layout.numberOfSelectionAreas())
		for i in 0..<numberOfButtonsToDraw {
			let viewRect = layout.getViewRect(workspace.frame, selectionArea: i)
            let view = TaskPickerButtonView(frame: viewRect)
			view.theme = theme
			view.selectionAreaInfoDelegate = self
			view.taskPosition = i

			let recognizer = UITapGestureRecognizer(target:self, action:Selector("handleTap:"))
            recognizer.delegate = self

            view.addGestureRecognizer(recognizer)
			recognizers[recognizer] = i
            views[i] = view

			workspace.addSubview(view)
		}

		// Setup sign in/out button
		var viewRect = layout.getViewRect(workspace.frame, selectionArea: SignInSignOut)
	    signInSignOutView = ToolView(frame: viewRect)
		signInSignOutView!.theme = theme
		signInSignOutView!.toolbarInfoDelegate = self
		signInSignOutView!.tool = SignInSignOut

		var recognizer = UITapGestureRecognizer(target:self, action:Selector("handleTapSigninSignout:"))
	    recognizer.delegate = self
	    signInSignOutView!.addGestureRecognizer(recognizer)

		workspace.addSubview(signInSignOutView!)

		// Setup infoarea
		viewRect = layout.getViewRect(workspace.frame, selectionArea: InfoArea)
	    infoAreaView = ToolView(frame: viewRect)
		infoAreaView!.theme = theme
		infoAreaView!.toolbarInfoDelegate = self
		infoAreaView!.tool = InfoArea

		workspace.addSubview(infoAreaView!)

		// Setup settings
		viewRect = layout.getViewRect(workspace.frame, selectionArea: Settings)
	    settingsView = ToolView(frame: viewRect)
		settingsView!.theme = theme
		settingsView!.toolbarInfoDelegate = self
		settingsView!.tool = Settings

		recognizer = UITapGestureRecognizer(target:self, action:Selector("handleTapSettings:"))
	    recognizer.delegate = self
	    settingsView!.addGestureRecognizer(recognizer)

		workspace.addSubview(settingsView!)
        
        updateActiveActivityTimer = NSTimer.scheduledTimerWithTimeInterval(1,
                                   target: self,
                                 selector: "updateActiveTask:",
                                 userInfo: nil,
                                  repeats: true)
    }


	func signIn() {
        TextViewLogger.log(statustext, message: String("\n\(getString(NSDate())) TaskPicker.signIn"))
        if (currentTaskIndex >= 0 && currentTaskIndex < taskList.count) {
            taskSignIn(taskList[currentTaskIndex])
            views[currentTaskIndex]?.setNeedsDisplay()
            signInSignOutView?.setNeedsDisplay()
            infoAreaView?.setNeedsDisplay()
        }
	}

	func signOut() {
        TextViewLogger.log(statustext, message: String("\n\(getString(NSDate())) TaskPicker.signOut"))
        if (currentTaskIndex >= 0 && currentTaskIndex < taskList.count) {
            taskSignOut(taskList[currentTaskIndex])
            views[currentTaskIndex]?.setNeedsDisplay()
            signInSignOutView?.setNeedsDisplay()
            infoAreaView?.setNeedsDisplay()
        }
	}


	func taskSelected(newTaskIndex: Int) {
        TextViewLogger.log(statustext, message: String("\n\(getString(NSDate())) TaskPicker.taskSelected\(newTaskIndex)"))

        if (currentTaskIndex >= 0 && currentTaskIndex < taskList.count) {
            taskSignOut(taskList[currentTaskIndex])
            views[currentTaskIndex]?.setNeedsDisplay()
        }
        if (newTaskIndex >= 0 && newTaskIndex < taskList.count) {
            taskSignIn(taskList[newTaskIndex])
            views[newTaskIndex]?.setNeedsDisplay()
        }
        currentTaskIndex = newTaskIndex
        signInSignOutView?.setNeedsDisplay()
	}


	func taskIsSelectable(taskNumber: Int) -> Bool {
		return true
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

	
    // Gesture recognizer callbacks
    func handleTap(sender: UITapGestureRecognizer) {
        TextViewLogger.log(statustext, message: String("\n\(getString(NSDate())) TaskPicker.handleTap"))
        if let taskNumber = recognizers[sender] {
            taskSelected(taskNumber)
        }
	}

    // Tap on sign in/sign out
	func handleTapSigninSignout(sender: UITapGestureRecognizer) {
        TextViewLogger.log(statustext, message: String("\n\(getString(NSDate())) TaskPicker.handleTapSigninSignout"))

        if (currentTaskIndex >= 0 && currentTaskIndex < taskList.count) {
        	signOut()
        	currentTaskIndex = -1*currentTaskIndex
        } else {
        	currentTaskIndex = -1*currentTaskIndex
        	signIn()
        }
    }

	// Tap on settings    
	func handleTapSettings(sender: UITapGestureRecognizer) {
        TextViewLogger.log(statustext,  message: String("\n\(getString(NSDate())) TaskPicker.handleTapSettings"))
    }
        
    @objc
    func updateActiveTask(timer: NSTimer) {
        if currentTaskIndex >= 0 {
            let view = views[currentTaskIndex]
            views[currentTaskIndex]?.setNeedsDisplay()
            infoAreaView?.setNeedsDisplay()
        }
    }







    func taskSignIn(task: Task) {
        TextViewLogger.log(statustext, message: String("\n\(getString(NSDate())) TaskPicker.taskSignIn(\(task.name))"))

        currentWork = Work(task: task)
        currentWork?.startTime = NSDate()
    }

    func taskSignOut(task: Task) {
        TextViewLogger.log(statustext, message:String("\n\(getString(NSDate())) TaskPicker.taskSignOut(\(task.name))"))

        currentWork?.stopTime = NSDate()
        if let work = currentWork {
            var nn = 1
            if var n = numberOfTimesActivated[task.id]? {
                nn = n+1
            }
            numberOfTimesActivated[task.id] = nn

            var mm = work.stopTime.timeIntervalSinceDate(work.startTime)
        	if var m = totalTimeActive[task.id]? {
                mm = m + mm
            }
        totalTimeActive[task.id] = mm
        }
        currentWork = nil
    }

	// SelectionAreaInfoDelegate
	func getSelectionAreaInfo(selectionArea: Int) -> SelectionAreaInfo {
		let task = taskList![selectionArea]
        var nn: Int = 0
        if let n = numberOfTimesActivated[task.id]? {
            nn = n
        }
        var mm: NSTimeInterval = 0
        if let m = totalTimeActive![task.id]? {
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


}


 






