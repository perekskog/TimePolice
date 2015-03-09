//
//  EditWorkViewController.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-03-09.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

import UIKit

class EditWorkViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var taskPickerTable: UITableView!
    
    // Input values
    var work: Work?
    var taskList: [Task]?

    // Output values
    var taskToUse: Task?
    var startTimeToUse: NSDate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        taskPickerTable.dataSource = self
        taskPickerTable.delegate = self
        if let date = work?.startTime {
            datePicker.date = date
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
        let cell = tableView.dequeueReusableCellWithIdentifier("EditWorkCell") as UITableViewCell
        cell.textLabel?.text = taskList?[indexPath.row].name
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let task = taskList?[indexPath.row] {
            taskToUse = task
        }
    }

}
