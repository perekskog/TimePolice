//
//  TaskPickerStrategy.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-02-03.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

import Foundation

protocol TaskSelectionStrategy {
	func selectableTasks(taskList: [Task]) -> [Task]
    func isSelectable(task: Task) -> Bool
    func taskSelected(task: Task)
	func taskUnselected(task: Task)
}

class TaskSelectAny: TaskSelectionStrategy {
	init() {}
	func selectableTasks(taskList: [Task]) -> [Task] {
		return taskList
	}
    func isSelectable(task: Task) -> Bool {
        return true
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
    
    func isSelectable(task: Task) -> Bool {
        if contains(selectedTasks, task) {
            return false
        } else {
            return true
        }
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

