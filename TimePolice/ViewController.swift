//
//  ViewController.swift
//  TimePolice
//
//  Created by Per Ekskog on 2014-11-04.
//  Copyright (c) 2014 Per Ekskog. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

	var workspace: WorkSpace?

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
	func getView(parentView: UIView, selectionArea: Int) -> (view: UIImageView, position: CGPoint)
}

class GridLayout : Layout {
	var rows: Int
	var columns: Int
    var views: [Int: UIImageView]!

	init(rows: Int, columns: Int) {
		self.rows = rows
		self.columns = columns
		self.views = [:]
	}
    func numberOfSelectionAreas() -> Int {
        return rows * columns;
    }
	func getView(parentView: UIView, selectionArea: Int) -> (view: UIImageView, position: CGPoint) {
		let row = selectionArea / columns
		let column = selectionArea % columns
		let frame = parentView.frame
		let rowHeight = Int(frame.height) / rows
		let columnWidth = Int(frame.width) / columns
        let point = CGPoint(x: column*columnWidth, y: row*rowHeight)

        var x: UIImageView
		if let view = views[selectionArea] {
            x = view
		} else {
	        views[selectionArea] = UIImageView(frame: CGRect(x:0, y:0, width:columnWidth, height:rowHeight))
            x = views[selectionArea]!
		}
        return (x, point)
	}
}

protocol Theme {
	func decorateView(view: UIImageView, task: Task, taskPosition: Int, isSelectable: Bool) -> UIImageView
}		

class BasicTheme : Theme {
	func decorateView(view: UIImageView, task: Task, taskPosition: Int, isSelectable: Bool) -> UIImageView {
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
    var workspace:WorkSpace!
	var layout: Layout!
	var theme: Theme!
	var session: Session!
    var taskList: [Task]!
    var taskSelectionStrategy: TaskSelectionStrategy!
    var recognizers: [UIGestureRecognizer: Int]!
	
	init(workspace:WorkSpace, layout: Layout, theme: Theme, taskList: [Task], taskSelectionStrategy: TaskSelectionStrategy) {
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
			let (view, position) = layout.getView(workspace.view, selectionArea: i)
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


/////////////////////////
// WorkSpace

class WorkSpace {
    var view: UIView!
	var taskPickers: [TaskPicker]!

	init(view: UIView){
		self.view = view
		self.taskPickers = []
	}
}





