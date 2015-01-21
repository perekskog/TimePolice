//
//  ViewController.swift
//  TimePolice
//
//  Created by Per Ekskog on 2014-11-04.
//  Copyright (c) 2014 Per Ekskog. All rights reserved.
//


import UIKit


class ViewController: UIViewController
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

        // Do any additional setup after loading the view, typically from a nib.

/*
        let theme = BasicTheme()

        smallBackground?.numberOfTasks = 2
        smallBackground?.theme = theme

        let layout = GridLayout(rows: 3, columns: 3)
        
        taskList = [ Task(name: "Private"), Task(name: "Work")]

        if let rect = smallBackground?.frame {
            let middleRect = layout.getViewRect(rect, selectionArea: 4)
            let buttonView = ButtonView(frame: middleRect)
            buttonView.selectionAreaInfoDelegate = self
            buttonView.taskPosition = 1
            buttonView.theme = theme

			let recognizer = UITapGestureRecognizer(target:self, action:Selector("handleTap:"))
            recognizer.delegate = self
            buttonView.addGestureRecognizer(recognizer)

            smallBackground?.addSubview(buttonView)
        }
*/

        totalTimeActive = [:]
        numberOfTimesActivated = [:]

        let theme = BasicTheme()
        let layout = GridLayout(rows: 7, columns: 3)
        let taskSelectionStrategy = TaskSelectAny()

        taskList = [
            Task(name: "I Email"), Task(name: "I Ticket"), Task(name: "---"),
            Task(name: "I Lync"), Task(name: "I F2F"), Task(name: "---"),
            Task(name: "P Task"), Task(name: "P US"), Task(name: "P Ticket"), 
            Task(name: "P OF"), Task(name: "P Meeting"), Task(name: "---"),
            Task(name: "U Productive"), Task(name: "U Non productive"), Task(name: "U Non work"),
            Task(name: "M Planned"), Task(name: "M Coffee"),  Task(name: "---"),
            Task(name: "M WC"), Task(name: "M Other"), Task(name: "---")
		]
//        taskList = [ Task(name: "Out"), Task(name: "Down"), Task(name: "Other"), Task(name: "Omnifocus"), Task(name: "Evernote"), Task(name: "---"), Task(name: "Dev"), Task(name: "Media")]
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


/////////////////////////
// WorkSpace
/*
class WorkSpace {
    var view: UIView!
	var taskPickers: [TaskPicker]!

	init(view: UIView){
		self.view = view
		self.taskPickers = []
	}

	func addSubview(view: UIView, position:CGPoint) {
		view.addSubview(xxx)
	}
}
*/

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

let SignInSignOut = -1	// Active button for signing in/out of a session
let InfoArea = -2		// Display area for ongoing work
let Settings = -3		// Segue to settings, configurations etc


protocol Layout {
    func numberOfSelectionAreas() -> Int
	func getViewRect(parentViewRect: CGRect, selectionArea: Int) -> CGRect
}

class GridLayout : Layout {
	var rows: Int
	var columns: Int
	let toolbarHeight = 30
	let padding = 2

	init(rows: Int, columns: Int) {
		self.rows = rows
		self.columns = columns
	}

    func numberOfSelectionAreas() -> Int {
        return rows * columns;
    }

	func getViewRect(parentViewRect: CGRect, selectionArea: Int) -> CGRect {
		switch selectionArea {
			case SignInSignOut:
				let column = 0
				let columnWidth = Int(parentViewRect.width) / columns
				let rect = CGRect(x:column*columnWidth+padding, y:padding, width:columnWidth-padding, height:toolbarHeight)
				return rect
			case InfoArea:
				let column = 1
				let columnWidth = Int(parentViewRect.width) / columns
				let rect = CGRect(x:column*columnWidth+padding, y:padding, width:columnWidth-padding, height:toolbarHeight)
				return rect
			case Settings:
				let column = 2
				let columnWidth = Int(parentViewRect.width) / columns
				let rect = CGRect(x:column*columnWidth+padding, y:padding, width:columnWidth-padding, height:toolbarHeight)
				return rect
			default:
				let row = selectionArea / columns
				let column = selectionArea % columns
				let rowHeight = (Int(parentViewRect.height)-toolbarHeight) / rows
				let columnWidth = Int(parentViewRect.width) / columns
				let rect = CGRect(x:column*columnWidth+padding, y:row*rowHeight+toolbarHeight+2*padding, width:columnWidth-padding, height:rowHeight-padding)

				return rect
		}
	}
}

protocol Theme {
	func drawBackground(context: CGContextRef, parent: CGRect, numberOfTasks: Int)
	func drawButton(context: CGContextRef, parent: CGRect, taskPosition: Int, selectionAreaInfo: SelectionAreaInfo)
	func drawTool(context: CGContextRef, parent: CGRect, tool: Int, toolbarInfo: ToolbarInfo)
}		

class BasicTheme : Theme {

    let bigSize:CGFloat = 13.0
    let smallSize:CGFloat = 11.0

	func drawBackground(context: CGContextRef, parent: CGRect, numberOfTasks: Int) {
		// Gradient
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [ 0.0, 1.0 ]
	    let colors = [CGColorCreate(colorSpaceRGB, [0.0, 1.0, 0.0, 1.0]),
        	          CGColorCreate(colorSpaceRGB, [1.0, 1.0, 1.0, 1.0])]
	    let colorspace = CGColorSpaceCreateDeviceRGB()
	    let gradient = CGGradientCreateWithColors(colorspace,
                  colors, locations)
    	var startPoint = CGPoint()
	    var endPoint =  CGPoint()
    	startPoint.x = 0.0
	    startPoint.y = 0.0
    	endPoint.x = 0
    	endPoint.y = parent.height
	    CGContextDrawLinearGradient(context, gradient,
               startPoint, endPoint, 0)
	}

    func addText(context: CGContextRef, text: String, origin: CGPoint, fontSize: CGFloat, withFrame: Bool, foregroundColor: CGColor) {
		CGContextSaveGState(context)
		var attributes: [String: AnyObject] = [
	    	NSForegroundColorAttributeName : foregroundColor,
    		NSFontAttributeName : UIFont.systemFontOfSize(fontSize)
		]
        let font = attributes[NSFontAttributeName] as UIFont
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = text.sizeWithAttributes(attributes)
        CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
        let size = CGSize(width:Int(textSize.width+0.5)+1, height:Int(textSize.height+0.5))
        let textRect = CGRect(
                origin: CGPoint(x: origin.x-textSize.width/2, y:origin.y),
                size: size)
        let textPath    = CGPathCreateWithRect(textRect, nil)
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedString)
        let frame       = CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: attributedString.length), textPath, nil)
        CTFrameDraw(frame, context)        
        CGContextRestoreGState(context)

        // Rectangle
        if(withFrame) {
            CGContextSetLineWidth(context, 1.0)
            CGContextSetStrokeColorWithColor(context,
                UIColor.blueColor().CGColor)
            let rect = CGRect(x:origin.x-textSize.width/2, y: origin.y-textSize.height/2, width: textSize.width, height: textSize.height)
            CGContextAddRect(context, rect)
            CGContextStrokePath(context)
        }
	}

	func drawButton(context: CGContextRef, parent: CGRect, taskPosition: Int, selectionAreaInfo: SelectionAreaInfo) {
        // Gradient
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        var colors = [CGColorCreate(colorSpaceRGB, [1.0, 1.0, 1.0, 1.0]),
            CGColorCreate(colorSpaceRGB, [0.3, 0.3, 1.0, 1.0])]
        if selectionAreaInfo.active {
        	colors = [CGColorCreate(colorSpaceRGB, [1.0, 1.0, 1.0, 1.0]),
            CGColorCreate(colorSpaceRGB, [1.0, 1.0, 1.0, 1.0])]
        }
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradientCreateWithColors(colorspace,
            colors, locations)
        var startPoint = CGPoint()
        var endPoint =  CGPoint()
        startPoint.x = 0.0
        startPoint.y = 0.0
        endPoint.x = 0
        endPoint.y = parent.height
        CGContextDrawLinearGradient(context, gradient,
            startPoint, endPoint, 0)

        let color = UIColor(white: 0.0, alpha: 1.0).CGColor
        addText(context, text: selectionAreaInfo.task.name, origin: CGPoint(x:parent.width/2, y:parent.height/4), fontSize: bigSize, withFrame: false, foregroundColor: color)
        if selectionAreaInfo.active {
        	let now = NSDate()
        	let activeTime = now.timeIntervalSinceDate(selectionAreaInfo.activatedAt)
    	    addText(context, text: getString(activeTime), origin: CGPoint(x:parent.width/2, y:parent.height/4*3), fontSize: smallSize, withFrame: false, foregroundColor: color)
        } else {
	        addText(context, text: String(selectionAreaInfo.numberOfTimesActivated), origin: CGPoint(x:parent.width/4, y:parent.height/4*3), fontSize: smallSize, withFrame: false, foregroundColor: color)
    	    addText(context, text: getString(selectionAreaInfo.totalTimeActive), origin: CGPoint(x:parent.width/4*3, y:parent.height/4*3), fontSize: smallSize, withFrame: false, foregroundColor: color)
        }
	}

	func drawTool(context: CGContextRef, parent: CGRect, tool: Int, toolbarInfo: ToolbarInfo) {
        // Gradient
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [ 0.0, 1.0 ]

        var foregroundColor = UIColor(white: 1.0, alpha: 1.0).CGColor
        var backgroundColors = [CGColorCreate(colorSpaceRGB, [0.4, 0.4, 0.4, 1.0]),
            CGColorCreate(colorSpaceRGB, [0.2, 0.2, 0.2, 1.0])]
        if !toolbarInfo.signedIn {
        	backgroundColors = [CGColorCreate(colorSpaceRGB, [1.0, 1.0, 1.0, 1.0]),
            CGColorCreate(colorSpaceRGB, [0.8, 0.8, 0.8, 1.0])]
            foregroundColor = UIColor(white: 0.0, alpha: 1.0).CGColor
        }
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradientCreateWithColors(colorspace,
            backgroundColors, locations)
        var startPoint = CGPoint()
        var endPoint =  CGPoint()
        startPoint.x = 0.0
        startPoint.y = 0.0
        endPoint.x = 0
        endPoint.y = parent.height
        CGContextDrawLinearGradient(context, gradient,
            startPoint, endPoint, 0)

        var text: String
        switch tool {
        	case SignInSignOut: 
        		if toolbarInfo.signedIn {
        			text = "Sign out"
        		} else {
        			text = "Sign in"
        		}
        	case InfoArea:
        		text = "\(toolbarInfo.totalTimesActivatedForSession)    \(getString(toolbarInfo.totalTimeActiveForSession))"
        	case Settings:
        		text = "Settings"
            default:
                text = "---"
        }

        addText(context, text: text, origin: CGPoint(x:parent.width/2, y:parent.height/2), fontSize: bigSize, withFrame: false, foregroundColor: foregroundColor)
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
            settingsView?.setNeedsDisplay()
        }
	}

	func signOut() {
        if (currentTaskIndex >= 0 && currentTaskIndex < taskList.count) {
            taskSelectionDelegate?.taskSignOut(taskList[currentTaskIndex])
            views[currentTaskIndex]?.setNeedsDisplay()
            signInSignOutView?.setNeedsDisplay()
            infoAreaView?.setNeedsDisplay()
            settingsView?.setNeedsDisplay()
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

  		var textAttributes: [String: AnyObject] = [
	    	NSForegroundColorAttributeName : UIColor(white: 1.0, alpha: 1.0).CGColor,
    		NSFontAttributeName : UIFont.systemFontOfSize(15)
		]

        drawTextMultiLine(context, parent: rect, text: "Hello, World, here I am again! The quick brown fox jumps over the lazy dog", attributes: textAttributes, x: 50, y: 50)
        drawTextMultiLine(context, parent: rect, text: "Hello, World, here I am again! The quick brown fox jumps over the lazy dog", attributes: textAttributes, x: 150, y: 150)
        drawTextMultiLine(context, parent: rect, text: "Hello, World, here I am again! The quick brown fox jumps over the lazy dog", attributes: textAttributes, x: 0, y: 0)
        drawTextOneLine(context, parent: rect, text: "Mail", attributes: textAttributes, x:200, y:50)
	}

    func drawTextOneLine(context: CGContextRef, parent: CGRect, text: NSString, attributes: [String: AnyObject], x: CGFloat, y: CGFloat) -> CGSize {

         CGContextSaveGState(context)

        let font = attributes[NSFontAttributeName] as UIFont
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = text.sizeWithAttributes(attributes)
        
        CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
        
        // y: Add font.descender (its a negative value) to align the text at the baseline
        let textPath    = CGPathCreateWithRect(CGRect(x: x, y: y + font.descender, width: ceil(textSize.width), height: ceil(textSize.height)), nil)
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedString)
        let frame       = CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: attributedString.length), textPath, nil)
        CTFrameDraw(frame, context)
        
        CGContextRestoreGState(context)

        return textSize
   }


    func drawTextMultiLine(context: CGContextRef, parent: CGRect, text: NSString, attributes: [String: AnyObject], x: CGFloat, y: CGFloat) -> CGSize {

        CGContextSaveGState(context)

        let font = attributes[NSFontAttributeName] as UIFont
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = text.sizeWithAttributes(attributes)
        
        CGContextTranslateCTM(context, 0.0, parent.size.height+2*y-250) //
        CGContextScaleCTM(context, 1.0, -1.0);
        
        let textPath    = CGPathCreateWithRect(CGRect(x: x, y: y, width: 50, height: 150), nil)
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedString)
        let frame       = CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: attributedString.length), textPath, nil)
        CTFrameDraw(frame, context)
        
        CGContextRestoreGState(context)

        return textSize
    }
    

	func drawButton(context: CGContextRef, parent: CGRect) {
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()

        // Gradient
        let locations: [CGFloat] = [ 0.0, 1.0 ]
	    let colors = [CGColorCreate(colorSpaceRGB, [0.0, 0.0, 1.0, 1.0]),
        	          CGColorCreate(colorSpaceRGB, [1.0, 1.0, 1.0, 1.0])]
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

        // Play button
/*
		CGContextSetFillColorWithColor(context, UIColor.blackColor().CGColor)
  		CGContextMoveToPoint(context, parent.width / 4, parent.height / 4)
  		CGContextAddLineToPoint(context, parent.width * 3 / 4, parent.height / 2)
  		CGContextAddLineToPoint(context, parent.width / 4, parent.height * 3 / 4)
  		CGContextAddLineToPoint(context, parent.width / 4, parent.height / 4)
  		CGContextFillPath(context)
*/
        // Blue rectangle
        CGContextSetLineWidth(context, 4.0)
        CGContextSetStrokeColorWithColor(context,
            UIColor.blueColor().CGColor)
        let rectangle = CGRectMake(60,170,200,80)
        CGContextAddRect(context, rectangle)
        CGContextStrokePath(context)

        // Fill blue rectangle
        CGContextAddRect(context, rectangle)
		CGContextSetFillColorWithColor(context, CGColorCreate(colorSpaceRGB, [1.0, 0.8, 0.8, 0.8]))
  		CGContextFillPath(context)

        // Ellipse
        CGContextSetLineWidth(context, 4.0)
        CGContextSetStrokeColorWithColor(context,
            UIColor.blueColor().CGColor)
        CGContextAddEllipseInRect(context, rectangle)
        CGContextStrokePath(context)

        // Dashed curve with shadow
        let myShadowOffset = CGSizeMake (-10,  15)
        CGContextSetLineWidth(context, 20.0)
        CGContextSaveGState(context)
        CGContextSetShadow (context, myShadowOffset, 5)
        CGContextSetStrokeColorWithColor(context,
                CGColorCreate(colorSpaceRGB, [1.0, 0.2, 0.2, 0.8]))
        let dashArray:[CGFloat] = [2,6,4,2]
        CGContextSetLineDash(context, 3, dashArray, 4)
        CGContextMoveToPoint(context, 60, 170)
        CGContextAddQuadCurveToPoint(context, 165, 90, 260, 170)
        CGContextStrokePath(context)
        CGContextRestoreGState(context)

        // Red rectangle
        CGContextSetLineWidth(context, 4.0)
        CGContextSetStrokeColorWithColor(context,
            UIColor.redColor().CGColor)
        let rectangle2 = CGRectMake(50,50,100,100)
        CGContextAddRect(context, rectangle2)
        CGContextStrokePath(context)
	}

}
 






