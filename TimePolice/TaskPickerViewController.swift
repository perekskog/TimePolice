//
//  TaskPickerViewController.swift
//  TimePolice
//
//  Created by Per Ekskog on 2014-11-04.
//  Copyright (c) 2014 Per Ekskog. All rights reserved.
//


import UIKit


class TaskPickerViewController: UIViewController
	 , SelectionAreaInfoDelegate
	, TaskPickerTaskSelectionDelegate
    , UIGestureRecognizerDelegate
    , ToolbarInfoDelegate
	{
    
    @IBOutlet var button1: TestButtonView!
    @IBOutlet var smallBackground: BackgroundView!
    @IBOutlet var statustext: UITextView!

    var taskList: [Task]?
    
    var tp: TaskPicker?

    var currentWork: Work?

    var totalTimeActive: [String: NSTimeInterval]!
    var numberOfTimesActivated: [String: Int]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        statustext.text! = String("\n\(NSDate()):ViewController.viewDidLoad")
        let numberOfElements = countElements(statustext.text)
        let range:NSRange = NSMakeRange(numberOfElements-1, 1)
        statustext.scrollRangeToVisible(range)

        totalTimeActive = [:]
        numberOfTimesActivated = [:]

        let theme = BasicTheme()
        let layout = GridLayout(rows: 7, columns: 3)
        let taskSelectionStrategy = TaskSelectAny()

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
        
        if let workspace = smallBackground {
            tp = TaskPicker(statustext: statustext, workspace: smallBackground, layout: layout, theme: theme, taskList: taskList!, taskSelectionStrategy: taskSelectionStrategy, selectionAreaInfoDelegate: self)
            tp!.taskSelectionDelegate = self
            tp!.toolbarInfoDelegate = self
            tp!.setup()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        let s = String("\n\(getString(NSDate())) ViewController.didReceiveMemoryWarning")
        TextViewLogger.log(statustext, message: s)
    }

    func taskSignIn(task: Task) {
        TextViewLogger.log(statustext, message: String("\n\(getString(NSDate())) ViewController.taskSignIn(\(task.name))"))

        currentWork = Work(task: task)
        currentWork?.startTime = NSDate()
    }

    func taskSignOut(task: Task) {
        TextViewLogger.log(statustext, message:String("\n\(getString(NSDate())) ViewController.taskSignOut(\(task.name))"))

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


///////////////////////////////////////////////////
// TaskPicker and TaskPickerTaskSelectionDelegate

protocol TaskPickerTaskSelectionDelegate {
	func taskSignIn(task: Task)
	func taskSignOut(task: Task)
}

class TaskPicker: NSObject, UIGestureRecognizerDelegate, ToolbarInfoDelegate {
	// Initialized roperties
    var statustext: UITextView
    var workspace:BackgroundView!
	var layout: Layout!
	var theme: Theme!
	var session: Session!
    var taskList: [Task]!
    var taskSelectionStrategy: TaskSelectionStrategy!
    var selectionAreaInfoDelegate: SelectionAreaInfoDelegate
    var recognizers: [UIGestureRecognizer: Int]!
    var views: [Int: ButtonView]!
	var currentTaskIndex: Int!
	
    init(statustext: UITextView, workspace:BackgroundView, layout: Layout, theme: Theme, taskList: [Task], taskSelectionStrategy: TaskSelectionStrategy, selectionAreaInfoDelegate: SelectionAreaInfoDelegate) {
        self.statustext = statustext
        self.workspace = workspace
		self.layout = layout
		self.theme = theme
		self.taskList = taskList
		self.taskSelectionStrategy = taskSelectionStrategy
		self.selectionAreaInfoDelegate = selectionAreaInfoDelegate
		self.recognizers = [:]
        self.views = [:]
        self.currentTaskIndex = -1
	}

	var updateActiveActivityTimer: NSTimer?
	var signInSignOutView: ToolView?
	var infoAreaView: ToolView?
	var settingsView: ToolView?

	var toolbarInfoDelegate: ToolbarInfoDelegate?

	// Uninitialized properties

	// Delegates
	var taskSelectionDelegate: TaskPickerTaskSelectionDelegate?

	func setup() {
		workspace.numberOfTasks = taskList.count
		workspace.theme = theme

		// Setup task buttons
		let numberOfButtonsToDraw = min(taskList.count, layout.numberOfSelectionAreas())
		for i in 0..<numberOfButtonsToDraw {
			let viewRect = layout.getViewRect(workspace.frame, selectionArea: i)
            let view = ButtonView(frame: viewRect)
			view.theme = theme
			view.selectionAreaInfoDelegate = selectionAreaInfoDelegate
			view.taskSelectionStrategy = taskSelectionStrategy
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
        if (currentTaskIndex >= 0 && currentTaskIndex < taskList.count) {
            taskSelectionDelegate?.taskSignIn(taskList[currentTaskIndex])        	
            views[currentTaskIndex]?.setNeedsDisplay()
            signInSignOutView?.setNeedsDisplay()
            infoAreaView?.setNeedsDisplay()
        }
	}

	func signOut() {
        if (currentTaskIndex >= 0 && currentTaskIndex < taskList.count) {
            taskSelectionDelegate?.taskSignOut(taskList[currentTaskIndex])
            views[currentTaskIndex]?.setNeedsDisplay()
            signInSignOutView?.setNeedsDisplay()
            infoAreaView?.setNeedsDisplay()
        }
	}


	func taskSelected(newTaskIndex: Int) {
        statustext.text! += String("\n\(getString(NSDate())) TaskPicker.taskSelected\(newTaskIndex)")
        let numberOfElements = countElements(statustext.text)
        let range:NSRange = NSMakeRange(numberOfElements-1, 1)
        statustext.scrollRangeToVisible(range)

        if (currentTaskIndex >= 0 && currentTaskIndex < taskList.count) {
            taskSelectionDelegate?.taskSignOut(taskList[currentTaskIndex])
            views[currentTaskIndex]?.setNeedsDisplay()
        }
        if (newTaskIndex >= 0 && newTaskIndex < taskList.count) {
            taskSelectionDelegate?.taskSignIn(taskList[newTaskIndex])
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
        if let taskNumber = recognizers[sender] {
            taskSelected(taskNumber)
        }
	}

    // Tap on sign in/sign out
	func handleTapSigninSignout(sender: UITapGestureRecognizer) {
        statustext.text! += String("\n\(getString(NSDate())) TaskPicker.handleTapSigninSignout")
        let numberOfElements = countElements(statustext.text)
        let range:NSRange = NSMakeRange(numberOfElements-1, 1)
        statustext.scrollRangeToVisible(range)

        println("Tap: Signin/signout")
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
        statustext.text! += String("\n\(getString(NSDate())) TaskPicker.handleTapSettings")
        let numberOfElements = countElements(statustext.text)
        let range:NSRange = NSMakeRange(numberOfElements-1, 1)
        statustext.scrollRangeToVisible(range)

        println("Tap: Settings")
    }
    
    // ToolbarInfoDelegate
    func getToolbarInfo() -> ToolbarInfo {
        let toolbarInfo = toolbarInfoDelegate!.getToolbarInfo()
    	return toolbarInfo
    }
    
    @objc
    func updateActiveTask(timer: NSTimer) {
        if currentTaskIndex >= 0 {
            let view = views[currentTaskIndex]
            views[currentTaskIndex]?.setNeedsDisplay()
            infoAreaView?.setNeedsDisplay()
        }
    }


}



//////////////////////////////////////////////
// Custom view

class TestButtonView: UIView {
	override func drawRect(rect: CGRect) {
		let context = UIGraphicsGetCurrentContext()

		drawButton(context, parent: rect)
	}

	func drawButton(context: CGContextRef, parent: CGRect) {
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()

        // Gradient
        let locations: [CGFloat] = [ 0.0, 1.0 ]
	    let colors = [CGColorCreate(colorSpaceRGB, [0.4, 0.4, 0.6, 1.0]),
        	          CGColorCreate(colorSpaceRGB, [0.6, 0.6, 0.9, 1.0])]
	    let colorspace = CGColorSpaceCreateDeviceRGB()
	    let gradient = CGGradientCreateWithColors(colorspace,
                  colors, locations)
    	var startPoint = CGPoint()
	    var endPoint =  CGPoint()
    	startPoint.x = 0.0
	    startPoint.y = 0.0
    	endPoint.x = 0
    	endPoint.y = 700
	    CGContextDrawLinearGradient(context, gradient,
               startPoint, endPoint, 0)

	}

}
 






