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
        // Dispose of any resources that can be recreated.
        statustext.text! += String("\n\(getString(NSDate())) ViewController.didReceiveMemoryWarning")
        let numberOfElements = countElements(statustext.text)
        let range:NSRange = NSMakeRange(numberOfElements-1, 1)
        statustext.scrollRangeToVisible(range)
    }

    func taskSignIn(task: Task) {
        statustext.text! += String("\n\(getString(NSDate())) ViewController.taskSignIn(\(task.name))")
        let numberOfElements = countElements(statustext.text)
        let range:NSRange = NSMakeRange(numberOfElements-1, 1)
        statustext.scrollRangeToVisible(range)

        println("SignIn\(task.name)")
        currentWork = Work(task: task)
        currentWork?.startTime = NSDate()
    }

    func taskSignOut(task: Task) {
        statustext.text! += String("\n\(getString(NSDate())) ViewController.taskSignOut(\(task.name))")
        let numberOfElements = countElements(statustext.text)
        let range:NSRange = NSMakeRange(numberOfElements-1, 1)
        statustext.scrollRangeToVisible(range)

        println("SignOut\(task.name)")
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

	// Gesture recognizer delegate
	func handleTap(sender: UITapGestureRecognizer) {
        println("handleTap")
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

///////////////////////////////////////////////
// ProjectTemplate and ProjectTemplateManager

class TimePolice {
	var templateList: [String:ProjectTemplate]!
	var projectList: [String:Project]!

	init() {
		templateList = [:]
		projectList = [:]
	}

	var view: UIView?

	func addTemplate(template: ProjectTemplate) {
		templateList[template.name] = template
	}

	func removeTemplate(template: ProjectTemplate) {
		templateList[template.name] = nil
	}

	func addProject(project: Project) {
		projectList[project.name] = project
	}

	func removeProject(project: Project) {
		projectList[project.name] = nil
	}

	func redraw() {

	}

}


///////////////////////////////////////////////
// ProjectTemplate

func == (lhs: ProjectTemplate, rhs: ProjectTemplate) -> Bool {
    return (lhs.name == rhs.name
    && lhs.taskList == rhs.taskList)
}

class ProjectTemplate: Equatable {
	var name: String!
	var taskList: [Task]!

	init(name: String) {
		self.name = name
		self.taskList = []
	}
	init(name: String, taskList: [Task]) {
		self.name = name
		self.taskList = taskList
	}
}

/////////////////////////////////////////
// Project

// TODO: Add check for taskSelectionStrategy and sessionList
func == (lhs: Project, rhs: Project) -> Bool {
    return (lhs.name == rhs.name
    && lhs.taskList == rhs.taskList)
}

class Project: Equatable {
	var name: String
	var taskSelectionStrategy: TaskSelectionStrategy!
    var taskList: [Task]!
    var sessionList: [String:Session]!

    init(name: String, taskSelectionStrategy: TaskSelectionStrategy, taskList: [Task]) {
    	self.name = name
        self.taskSelectionStrategy = taskSelectionStrategy
        self.taskList = taskList
        self.sessionList = [:]
    }

    func addSession(session: Session) {
    	sessionList[session.name] = session
    }

    func removeSession(session: Session) {
    	sessionList[session.name] = nil
    }
    
}

////////////////////////////////////////////////
// Session and SessionTaskListUpdateDelegate

class Session: TaskPickerTaskSelectionDelegate {	
	var name: String!
	var taskList: [Task]!
	var workDone: [Work]!

	init(name: String, taskList: [Task]) {
		self.name = name
		self.taskList = taskList
		self.workDone = []
	}

    var currentWork: Work?

    func taskSignIn(task: Task) {
        currentWork = Work(task: task)
        currentWork?.startTime = NSDate()
    }

    func taskSignOut(task: Task) {
        currentWork?.stopTime = NSDate()
        if let work = currentWork {
            workDone.append(work)
        }
        currentWork = nil
    }
}

/////////////////////////////
// Work and Task

class Work {
	var task: Task!
    var startTime: NSDate!
    var stopTime: NSDate!

	init(task: Task) {
		self.task = task
		startTime = NSDate()
		stopTime = NSDate()
	}

}

func == (lhs: Task, rhs: Task) -> Bool {
    return lhs.id == rhs.id
}

class Task: Equatable {
	var id: String!
	var name: String!

	// Used when creating a new task
	init(name: String) {
        let date = NSDate()
        let dateAndTime = NSDateFormatter.localizedStringFromDate(date,
                    dateStyle: NSDateFormatterStyle.ShortStyle,
                    timeStyle: NSDateFormatterStyle.MediumStyle)
		self.id = "\(dateAndTime) - \(date.timeIntervalSince1970)"
		self.name = name
 	}
 	// Used when deserialized from external storage
	init(id: String, name: String) {
		self.id = id
		self.name = name
	}
}



//////////////////////////////////////////////
// TaskSelectionStrategy, BackgroundView, ButtonView, Layout, Theme

protocol TaskSelectionStrategy {
	func selectableTasks(taskList: [Task]) -> [Task]
    func taskSelected(task: Task)
	func taskUnselected(task: Task)
}

class TaskSelectAny: TaskSelectionStrategy {
	init() {}
	func selectableTasks(taskList: [Task]) -> [Task] {
		return taskList
	}
	func taskSelected(task: Task) {
		// Do nothing
	}
	func taskUnselected(task: Task) {
		// Do nothing
	}
}

class TaskSelectInSequence: TaskSelectionStrategy {
    var selectedTasks: [Task]!
    
	init() {
        selectedTasks = []
    }
    
	func selectableTasks(taskList: [Task]) -> [Task] {
		var indexes = [Int]()

		if selectedTasks==[] {
			return taskList
		}

		for (index, task) in enumerate(taskList) {
			if contains(selectedTasks, task) {
				indexes.append(index)
			}
		}
		let x = indexes.reduce(0) { (total, number) in max(total,number) }

		return Array(taskList[x+1..<taskList.count])
	}

	func taskSelected(task: Task) {
		if !contains(selectedTasks, task) {
			selectedTasks.append(task)
		}
	}

	func taskUnselected(task: Task) {
		selectedTasks = selectedTasks.filter({!($0==task)})
	}	
}

class BackgroundView: UIView {

	var numberOfTasks: Int?
	var theme: Theme?

	override func drawRect(rect: CGRect) {
		super.drawRect(rect)
		let context = UIGraphicsGetCurrentContext()
        if let n = numberOfTasks {
            theme?.drawBackground(context, parent: rect, numberOfTasks: n)
        }
	}
}

class ButtonView: UIView {
	
	var taskPosition: Int?
    var taskSelectionStrategy: TaskSelectionStrategy?
	var selectionAreaInfoDelegate: SelectionAreaInfoDelegate?
	var theme: Theme?

	override func drawRect(rect: CGRect) {
		super.drawRect(rect)
		let context = UIGraphicsGetCurrentContext()
		if let i = taskPosition {
	 		if let selectionAreaInfo = selectionAreaInfoDelegate?.getSelectionAreaInfo(i) {
    		    theme?.drawButton(context, parent: rect, taskPosition: i, selectionAreaInfo: selectionAreaInfo)
    		}
    	}
	}
}

class ToolView: UIView {
	
	var tool: Int?
	var toolbarInfoDelegate: ToolbarInfoDelegate?
	var theme: Theme?

	override func drawRect(rect: CGRect) {
		super.drawRect(rect)
		let context = UIGraphicsGetCurrentContext()
		if let i = tool {
	 		if let toolbarInfo = toolbarInfoDelegate?.getToolbarInfo() {
    		    theme?.drawTool(context, parent: rect, tool: i, toolbarInfo: toolbarInfo)
    		}
    	}
	}
}

class SelectionAreaInfo {
	var task: Task
	var numberOfTimesActivated: Int
	var totalTimeActive: NSTimeInterval
	var active: Bool
	var activatedAt: NSDate
	init(task: Task, numberOfTimesActivated: Int, totalTimeActive: NSTimeInterval, active: Bool, activatedAt: NSDate) {
		self.task = task
		self.numberOfTimesActivated = numberOfTimesActivated
		self.totalTimeActive = totalTimeActive
		self.active = active
		self.activatedAt = activatedAt
	}
}

class ToolbarInfo {
	var signedIn: Bool
	var totalTimesActivatedForSession: Int
	var totalTimeActiveForSession: NSTimeInterval
	init(signedIn: Bool, totalTimesActivatedForSession: Int, totalTimeActiveForSession: NSTimeInterval) {
		self.signedIn = signedIn
		self.totalTimesActivatedForSession = totalTimesActivatedForSession
		self.totalTimeActiveForSession = totalTimeActiveForSession
	}
}

protocol SelectionAreaInfoDelegate {
	func getSelectionAreaInfo(selectionArea: Int) -> SelectionAreaInfo
}

protocol ToolbarInfoDelegate {
	func getToolbarInfo() -> ToolbarInfo
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
// Utilities

func getString(timeInterval: NSTimeInterval) -> String {
    let h = Int(timeInterval / 3600)
	let m = (Int(timeInterval) - h*3600) / 60
	let s = Int(timeInterval) - h*3600 - m*60
	var time: String = "\(h):"
	if m < 10 {
		time += "0\(m):"
	} else {
		time += "\(m):"
	}
	if s < 10 {
		time += "0\(s)"
	} else {
		time += "\(s)"
	}
    return time
}

func getString(date: NSDate) -> String {
	var formatter = NSDateFormatter();
	formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
	let defaultTimeZoneStr = formatter.stringFromDate(date);
	return defaultTimeZoneStr
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
 






