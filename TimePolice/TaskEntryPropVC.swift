//
//  TaskEntryPropVC.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-05-08.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

/*

TODO

- Redigera Work.name. Behöver bara vara synligt i WorkProp (så jag kan kolla i efterhand varför jag valde en diverse-task)

*/

import UIKit

enum FillWith: Int {
    case FillWithNone, FillWithPrevious, FillWithNext
}

enum InsertPosition: Int {
    case InsertNewBeforeThis, InsertNewAfterThis
}

class TaskEntryPropVC: 
    UIViewController, 
    UITableViewDataSource, 
    UITableViewDelegate,
    AppLoggerDataSource  {

    // Input data
    var taskEntryTemplate: Work?
    var segue: String?
    var taskList: [Task] = []
    var minimumDate: NSDate?
    var maximumDate: NSDate?
    var isOngoing: Bool?
    var isFirst: Bool?
    var isLast: Bool?
    
    // Output data
    var taskToUse: Task?
    var initialStartDate: NSDate?
    var initialStopDate: NSDate?
    var delete: FillWith?
    var insert: InsertPosition?

    // Local data
    var editStart = false
    var editStop = false
    
    // Table and table cells
    var table: UITableView!
    
    let cellStartTime = UITableViewCell(style: .Value1, reuseIdentifier: "EditWork-type1")
    let cellStopTime = UITableViewCell(style: .Value1, reuseIdentifier: "EditWork-type2")
    let cellTask = UITableViewCell(style: .Value1, reuseIdentifier: "EditWork-type3")

    // Hold TaskEntry attributes while editing
    let datePickerStart = UIDatePicker()
    let datePickerStop = UIDatePicker()
    var taskSelected: Task?
    
    let buttonCancel = UIButton(type: .System)
    let buttonSave = UIButton(type: .System)

    //----------------------------------------------------------------
    // TaskEntryPropVC - Lazy properties
    //----------------------------------------------------------------
    
    lazy var appLog : AppLog = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.appLog
        }()

    lazy var logger: AppLogger = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var defaultLogger = appDelegate.getDefaultLogger()
        defaultLogger.datasource = self
        return defaultLogger
    }()

    //---------------------------------------------
    // TaskEntryPropVC - AppLoggerDataSource
    //---------------------------------------------

    func getLogDomain() -> String {
        return "TaskEntryPropVC"
    }

    //---------------------------------------------
    // TaskEntryPropVC - View lifecycle
    //---------------------------------------------

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewWillDisappear")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewDidAppear")
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewDidDisappear")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        logger.datasource = self
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewDidDisappear")
        
        self.edgesForExtendedLayout = .None

        if let s = segue {
            switch s {
                case "AddTaskEntry": 
                    self.title = "Add task entry"
                case "EditTaskEntry": 
                    self.title = "Edit task entry"
                default:
                    self.title = "???"
            }
        }

        let buttonCancel = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancel:")
        self.navigationItem.leftBarButtonItem = buttonCancel
        let buttonSave = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: "save:")
        self.navigationItem.rightBarButtonItem = buttonSave

        table = UITableView(frame: self.view.frame, style: .Grouped)
        table.dataSource = self
        table.delegate = self
        self.view.addSubview(table)
        
        let now = NSDate()
        datePickerStart.date = now
        datePickerStop.date = now
        datePickerStart.addTarget(self, action: "datePickerChanged:", forControlEvents: UIControlEvents.ValueChanged)
        datePickerStop.addTarget(self, action: "datePickerChanged:", forControlEvents: UIControlEvents.ValueChanged)
        datePickerStart.minimumDate = minimumDate
        datePickerStart.maximumDate = maximumDate
        datePickerStop.minimumDate = minimumDate
        datePickerStop.maximumDate = maximumDate
        

        if let t = taskEntryTemplate {
            datePickerStart.date = t.startTime
            datePickerStop.date = t.stopTime
            taskSelected = t.task
        }
        
        initialStartDate = datePickerStart.date
        if let o = isOngoing {
            if !o {
                self.initialStopDate = datePickerStop.date
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewWillAppear")

        if let indexPath = table.indexPathForSelectedRow {
            table.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
    }

    override func viewWillLayoutSubviews() {
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewWillLayoutSubviews")

        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        table.frame = CGRectMake(5, 0, width-10, height)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewDidLayoutSubviews")

        table.separatorInset = UIEdgeInsetsZero
        table.layoutMargins = UIEdgeInsetsZero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        appLog.log(logger, logtype: .ViewLifecycle, message: "didReceiveMemoryWarning")
    }

    // GUI actions

    func cancel(sender: UIButton) {
        performSegueWithIdentifier("CancelTaskEntry", sender: self)
    }
    
    func save(sender: UIButton) {
        if let _ = taskSelected {
            // Must have selected a task to save the task entry
            performSegueWithIdentifier("SaveTaskEntry", sender: self)            
        }
    }
    
    func datePickerChanged(sender: UIDatePicker) {
        if sender == datePickerStart {
            if datePickerStart.date.compare(datePickerStop.date) == .OrderedDescending {
                datePickerStop.date = datePickerStart.date
                cellStopTime.detailTextLabel?.text = UtilitiesDate.getString(datePickerStop.date)
            }
            cellStartTime.detailTextLabel?.text = UtilitiesDate.getString(datePickerStart.date)
        }
        if sender == datePickerStop {
            if datePickerStop.date.compare(datePickerStart.date) == .OrderedAscending {
                datePickerStart.date = datePickerStop.date
                cellStartTime.detailTextLabel?.text = UtilitiesDate.getString(datePickerStart.date)
            }
            cellStopTime.detailTextLabel?.text = UtilitiesDate.getString(datePickerStop.date)
        }
    }
    
    // UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 1:
                if editStart == true {
                    height = 219
                } else {
                    height = 0
                }
            case 3:
                if editStop == true {
                    height = 219
                } else {
                    height = 0
                }
            default: height = 30
            }
        default:
            height = 30
        }

        return height
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        editStart = false
        editStop = false
        
        guard let first = self.isFirst,
                last = self.isLast else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in tableView:didSelectRowAtIndexPath")
            return
        }

        self.table.beginUpdates()
        defer {
            self.table.endUpdates()
        }
    
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                editStart = true
            case 2:
                editStop = true
            default:
                _ = 1
            }
        case 1:
            switch indexPath.row {
            default:
                performSegueWithIdentifier("SelectTask", sender: self)
            }
        case 2:
            // Sama logic as for "cellForRowAtIndexPath"
            switch indexPath.row {
            case 0:
                self.delete = .FillWithPrevious
                if first {
                    self.delete = .FillWithNone
                }
                performSegueWithIdentifier("DeleteTaskEntry", sender: self)
            case 1:
                self.delete = .FillWithNone
                if (first && !last) {
                    self.delete = .FillWithNext
                }
                performSegueWithIdentifier("DeleteTaskEntry", sender: self)
            case 2:
                self.delete = .FillWithNext
                performSegueWithIdentifier("DeleteTaskEntry", sender: self)
            default:
                _ = 1
            }
        case 3:
            switch indexPath.row {
            case 0:
                self.insert = .InsertNewBeforeThis
                performSegueWithIdentifier("InsertNewTaskEntry", sender: self)
            case 1:
                self.insert = .InsertNewAfterThis
                performSegueWithIdentifier("InsertNewTaskEntry", sender: self)
            default:
                _ = 1
            }
        default:
            _ = 1
        }        
    }
    
    // UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let ongoing = self.isOngoing,
            first = self.isFirst,
            last = self.isLast else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in tableView:numberOfRowsInSection")
            return 0
        }

        switch section {
            // Datepickers
        case 0:
            if ongoing {
                return 2
            } else {
                return 4
            }
            // Select task
        case 1:
            return 1
            // Delete
        case 2:
            // Always show "delete"
            var n = 1
            // If not first, show "delete, fill with previous"
            if !first {
                n++
            }
            // If not last, show "delete, fill with next"
            if !last {
                n++
            }
            return n
            // Insert
        case 3:
            // Always show "insert before"
            var n = 1
            // If not ongoing, show "insert after"
            if !ongoing {
                n++
            }
            return n
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell

        guard let first = self.isFirst,
                last = self.isLast else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in tableView:cellForRowAtIndexPath")
            return UITableViewCell()
        }

        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cellStartTime.textLabel?.text = "Start time"
                cellStartTime.detailTextLabel?.text = UtilitiesDate.getString(datePickerStart.date)
                cell = cellStartTime
            case 1:
                cell = UITableViewCell()
                cell.contentView.addSubview(datePickerStart)
                cell.clipsToBounds = true
            case 2:
                cellStopTime.textLabel?.text = "Stop time"
                cellStopTime.detailTextLabel?.text = UtilitiesDate.getString(datePickerStop.date)
                cell = cellStopTime
            case 3:
                cell = UITableViewCell()
                cell.contentView.addSubview(datePickerStop)
                cell.clipsToBounds = true
            default:
                cell = UITableViewCell()
                cell.textLabel?.text = "Configuration error"
            }
        case 1:
            switch indexPath.row {
            case 0:
                cellTask.textLabel?.text = "Task"
                if let t = taskSelected {
                    cellTask.detailTextLabel?.text = t.name
                    
                    if let colorString = t.getProperty("color") {
                        let color = UtilitiesColor.string2color(colorString)
                        
                        cellTask.imageView?.image = UtilitiesImage.getImageWithColor(color, width: 15.0, height: 15.0)
                    }
                    
                }
                cellTask.accessoryType = .DisclosureIndicator
                cell = cellTask
            default:
                cell = UITableViewCell()
                cell.textLabel?.text = "Configuration error"
            }
        case 2:
/*
1 button: 
    0: this 
        first AND last
2 buttons:
    0: fill with prev
    1: this
        !first AND last

    0: this
    1: fill with next
        !last AND first
3 buttons
    0: fill with prev
    1: this
    2: fill with next
        !first AND !last
*/
            cell = UITableViewCell()
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Delete this, fill with previous"
                if first {
                    cell.textLabel?.text = "Delete this"
                }
            case 1:
                cell.textLabel?.text = "Delete this"
                if (first && !last) {
                    cell.textLabel?.text = "Delete this, fill with next"                    
                }
            case 2:
                cell.textLabel?.text = "Delete this, fill with next"
            default:
                cell.textLabel?.text = "Configuration error"
            }
        case 3:
            cell = UITableViewCell()
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Insert new before this"
            case 1:
                cell.textLabel?.text = "Insert new after this"
            default:
                cell.textLabel?.text = "Configuration error"
            }
        default:
            cell = UITableViewCell()
            cell.textLabel?.text = "Configuration error"
        }
        return cell
    }

    // Segue handling

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SelectTask" {
            if let vc = segue.destinationViewController as? TaskSelectVC {
                vc.tasks = taskList
            }
        }
        if segue.identifier == "CancelTaskEntry" {
            // Do nothing
        }
        if segue.identifier == "SaveTaskEntry" {
            // Do nothing
        }
    }

    @IBAction func exitSelectTask(unwindSegue: UIStoryboardSegue ) {
        if unwindSegue.identifier == "DoneSelectTask" {

            guard let vc = unwindSegue.sourceViewController as? TaskSelectVC,
                i = vc.taskIndexSelected else {
                appLog.log(logger, logtype: .Guard, message: "guard fail in exitSelectTask DoneSelectTask 1")
                return
            }

            taskToUse = taskList[i]
            cellTask.detailTextLabel?.text = taskToUse!.name

        /*
            Not needed?
            guard let comment = UtilitiesString.getProperty(taskToUse!.name),
                    let colorString = UtilitiesString.getValue(comment, forTag: "color") else {
                appLog.log(logger, logtype: .Guard, message: "guard fail in exitSelectTask DoneSelectTask 2")
                return
            }
        */

            if let colorString = taskToUse!.getProperty("color") {
                let color = UtilitiesColor.string2color(colorString)
                cellTask.imageView?.image = UtilitiesImage.getImageWithColor(color, width: 15.0, height: 15.0)
            }
        }
    }

}
