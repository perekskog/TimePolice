//
//  EditWorkViewController.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-03-09.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

import UIKit

class TaskPickerEditWorkViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet var editorLabel: UILabel!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var taskPickerTable: UITableView!
    
    // Input values
    var work: Work?
    var minimumDate: NSDate?
    var maximumDate: NSDate?
    var taskList: [Task]?

    // Output values
    var taskToUse: Task?
    var initialDate: NSDate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        taskPickerTable.dataSource = self
        taskPickerTable.delegate = self

        datePicker.minimumDate = self.minimumDate
        datePicker.maximumDate = self.maximumDate
        
        if let w = work {
            if w.isOngoing() {
                initialDate = self.minimumDate
                editorLabel.text = "Starttime"
            } else {
                initialDate = self.maximumDate
                editorLabel.text = "Stoptime"
            }
        }
        
        if let d = initialDate {
            datePicker.date = d
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //-----------------------------------------
    // EditWorkViewController- UITableView
    //-----------------------------------------

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let t = taskList {
            return t.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EditWorkCell") as! UITableViewCell
        cell.textLabel?.text = taskList?[indexPath.row].name
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let task = taskList?[indexPath.row] {
            taskToUse = task
        }
    }

}
