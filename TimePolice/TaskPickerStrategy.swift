//
//  TaskPickerStrategy.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-02-03.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

/*

TODO

*/


import Foundation

protocol TaskSelectionStrategy {
	func selectableTasks(_ taskList: [Task]) -> [Task]
    func isSelectable(_ task: Task) -> Bool
    func taskSelected(_ task: Task)
	func taskUnselected(_ task: Task)
}

class TaskSelectAny: TaskSelectionStrategy {
	init() {}
	func selectableTasks(_ taskList: [Task]) -> [Task] {
		return taskList
	}
    func isSelectable(_ task: Task) -> Bool {
        return true
    }
	func taskSelected(_ task: Task) {
		// Do nothing
	}
	func taskUnselected(_ task: Task) {
		// Do nothing
	}
}

class TaskSelectInSequence: TaskSelectionStrategy {
    var selectedTasks: [Task]!
    
	init() {
        selectedTasks = []
    }
    
	func selectableTasks(_ taskList: [Task]) -> [Task] {
		var indexes = [Int]()

		if selectedTasks==[] {
			return taskList
		}

		for (index, task) in taskList.enumerated() {
			if selectedTasks.contains(task) {
				indexes.append(index)
			}
		}
		let x = indexes.reduce(0) { (total, number) in max(total,number) }

		return Array(taskList[x+1..<taskList.count])
	}
    
    func isSelectable(_ task: Task) -> Bool {
        if selectedTasks.contains(task) {
            return false
        } else {
            return true
        }
    }

	func taskSelected(_ task: Task) {
		if !selectedTasks.contains(task) {
			selectedTasks.append(task)
		}
	}

	func taskUnselected(_ task: Task) {
		selectedTasks = selectedTasks.filter({!($0==task)})
	}	
}

