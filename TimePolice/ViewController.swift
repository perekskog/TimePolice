//
//  ViewController.swift
//  TimePolice
//
//  Created by Per Ekskog on 2014-11-04.
//  Copyright (c) 2014 Per Ekskog. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var button1: ButtonView!
    @IBOutlet var statustext: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // let tp = TimePolice()
        // tp.view = 
        // tp.redraw()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

//////////////////////////////////////////////
// Custom view

class ButtonView: UIView {
	override func drawRect(rect: CGRect) {
		let context = UIGraphicsGetCurrentContext()

		drawButton(context, rect: rect)

  		var textAttributes: [String: AnyObject] = [
	    	NSForegroundColorAttributeName : UIColor(white: 1.0, alpha: 1.0).CGColor,
    		NSFontAttributeName : UIFont.systemFontOfSize(15)
		]

        drawText(context, rect: rect, text: "Hello, World, here I am again! The quick brown fox jumps over the lazy dog", attributes: textAttributes, x: 50, y: 50)
        drawText(context, rect: rect, text: "Hello, World, here I am again! The quick brown fox jumps over the lazy dog", attributes: textAttributes, x: 150, y: 150)
        drawText(context, rect: rect, text: "Hello, World, here I am again! The quick brown fox jumps over the lazy dog", attributes: textAttributes, x: 0, y: 0)
        drawTextOnelIne(context, rect: rect, text: "Mail", attributes: textAttributes, x:200, y:50)
 //       drawText2(context, text: "Hello, World, again!", attributes: textAttributes, x: 50, y: 50)
	}

    func drawTextOnelIne(context: CGContextRef, rect: CGRect, text: NSString, attributes: [String: AnyObject], x: CGFloat, y: CGFloat) -> CGSize {
         CGContextSaveGState(context)

        let font = attributes[NSFontAttributeName] as UIFont
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = text.sizeWithAttributes(attributes)
        
        CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
        
        // y: Add font.descender (its a negative value) to align the text at the baseline
        let textPath    = CGPathCreateWithRect(CGRect(x: x, y: y + font.descender, width: ceil(textSize.width), height: ceil(textSize.height)), nil)
//        let textPath    = CGPathCreateWithRect(CGRect(x: x, y: y, width: 50, height: 150), nil)
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedString)
        let frame       = CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: attributedString.length), textPath, nil)
        CTFrameDraw(frame, context)
        
        CGContextRestoreGState(context)

        return textSize
   }


    func drawText(context: CGContextRef, rect: CGRect, text: NSString, attributes: [String: AnyObject], x: CGFloat, y: CGFloat) -> CGSize {

        CGContextSaveGState(context)

        let font = attributes[NSFontAttributeName] as UIFont
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = text.sizeWithAttributes(attributes)
        
//        CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
        
        CGContextTranslateCTM(context, 0.0, rect.size.height+2*y-250) //
        CGContextScaleCTM(context, 1.0, -1.0);
        
        // y: Add font.descender (its a negative value) to align the text at the baseline
//        let textPath    = CGPathCreateWithRect(CGRect(x: x, y: y + font.descender, width: ceil(textSize.width), height: ceil(textSize.height)), nil)
        let textPath    = CGPathCreateWithRect(CGRect(x: x, y: y, width: 50, height: 150), nil)
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedString)
        let frame       = CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: attributedString.length), textPath, nil)
        CTFrameDraw(frame, context)
        
        CGContextRestoreGState(context)

        return textSize
    }
    

	func drawButton(context: CGContextRef, rect: CGRect) {
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
    	endPoint.y = 500
	    CGContextDrawLinearGradient(context, gradient,
               startPoint, endPoint, 0)

        // Play button
		CGContextSetFillColorWithColor(context, UIColor.blackColor().CGColor)
  		CGContextMoveToPoint(context, rect.width / 4, rect.height / 4)
  		CGContextAddLineToPoint(context, rect.width * 3 / 4, rect.height / 2)
  		CGContextAddLineToPoint(context, rect.width / 4, rect.height * 3 / 4)
  		CGContextAddLineToPoint(context, rect.width / 4, rect.height / 4)
  		CGContextFillPath(context)

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

    func drawText2(context: CGContextRef, text: NSString, attributes: [String: AnyObject], x: CGFloat, y: CGFloat) -> CGSize {
        //        let font = UIFont(name: "Arial", size: 30)
        //        let attr = [NSFontAttributeName: font!, NSForegroundColorAttributeName : UIColor(white: 1.0, alpha: 1.0).CGColor]
        //        let attr = [NSFontAttributeName: UIFont.systemFontOfSize(24), NSForegroundColorAttributeName : UIColor(white: 1.0, alpha: 1.0).CGColor]
        let size = text.sizeWithAttributes(attributes)
        let rectText = CGRectMake(x, y, 200, 100)
        //        text.drawInRect(rectText, withAttributes: attr)
        text.drawInRect(rectText, withAttributes: attributes)
        return size
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

    func taskSignOut() {
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

	init(task: Task) {
		self.task = task
	}

    var startTime: NSDate?
    var stopTime: NSDate?
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
// TaskSelectionStrategy, Layout, Theme

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

protocol Layout {
    func numberOfSelectionAreas() -> Int
	func getView(parentView: UIView, selectionArea: Int) -> UIView
}

class GridLayout : Layout {
	var rows: Int
	var columns: Int
    var views: [Int: UIView]!

	init(rows: Int, columns: Int) {
		self.rows = rows
		self.columns = columns
		self.views = [:]
	}
    func numberOfSelectionAreas() -> Int {
        return rows * columns;
    }
	func getView(parentView: UIView, selectionArea: Int) -> UIView {
		let row = selectionArea / columns
		let column = selectionArea % columns
		let frame = parentView.frame
		let rowHeight = Int(frame.height) / rows
		let columnWidth = Int(frame.width) / columns

        var x: UIView
		if let view = views[selectionArea] {
            x = view
		} else {
            let y = UIView(frame: CGRect(x:column*columnWidth, y:row*rowHeight, width:columnWidth, height:rowHeight))
	        views[selectionArea] = y
            x = views[selectionArea]!
		}
        return (x)
	}
}

protocol Theme {
	func decorateView(view: UIView, task: Task, taskPosition: Int, isSelectable: Bool) -> UIView
}		

class BasicTheme : Theme {
	func decorateView(view: UIView, task: Task, taskPosition: Int, isSelectable: Bool) -> UIView {
		return view
	}	
}


///////////////////////////////////////////////////
// TaskPicker and TaskPickerTaskSelectionDelegate

protocol TaskPickerTaskSelectionDelegate {
	func taskSignIn(task: Task)
	func taskSignOut()
}


class TaskPicker: NSObject, UIGestureRecognizerDelegate {
	// Initialized roperties
    var workspace:UIView!
	var layout: Layout!
	var theme: Theme!
	var session: Session!
    var taskList: [Task]!
    var taskSelectionStrategy: TaskSelectionStrategy!
    var recognizers: [UIGestureRecognizer: Int]!
	
	init(workspace:UIView, layout: Layout, theme: Theme, taskList: [Task], taskSelectionStrategy: TaskSelectionStrategy) {
        self.workspace = workspace
		self.layout = layout
		self.theme = theme
		self.taskList = taskList
		self.taskSelectionStrategy = taskSelectionStrategy
		self.recognizers = [:]
	}

	// Uninitialized properties
	var currentTask: Task?

	// Delegates
	var taskSelectionDelegate: TaskPickerTaskSelectionDelegate?

	func setup() {
		for i in 0..<layout.numberOfSelectionAreas() {
			let view = layout.getView(workspace, selectionArea: i)
            let t = taskList[i]
            let b = taskIsSelectable(i)
            theme.decorateView(view,
                task: t,
                taskPosition: i,
                isSelectable: taskIsSelectable(i))
			let recognizer = UITapGestureRecognizer(target:self, action:Selector("handleTap:"))
            recognizer.delegate = self
            view.addGestureRecognizer(recognizer)
			recognizers[recognizer] = i
			workspace.addSubview(view)
		}
	}

	func signIn() {
        if let task = currentTask {
            taskSelectionDelegate?.taskSignIn(task)
        }
	}

	func signOut() {
        if let task = currentTask {
            taskSelectionDelegate?.taskSignOut()
        }
	}

	func taskSelected(newTaskIndex: Int) {
        let newTask = taskList[newTaskIndex]
        if let task = currentTask {
            taskSelectionDelegate?.taskSignOut()
        }
        taskSelectionDelegate?.taskSignIn(newTask)
        currentTask = newTask
	}

	func taskIsSelectable(taskNumber: Int) -> Bool {
		return true
	}

	// Gesture recognizer delegate
	func handleTap(recognizer: UITapGestureRecognizer) {
        if let taskNumber = recognizers[recognizer] {
            taskSelected(taskNumber)
        }
	}
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
        shouldReceiveTouch touch: UITouch) -> Bool {
            if let taskNumber = recognizers[gestureRecognizer] {
                return taskIsSelectable(taskNumber)
            } else {
                return true
            }
	}
}






