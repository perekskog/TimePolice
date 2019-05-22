//
//  TaskEntryPropVC.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-05-08.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

/*

TODO

- Redigera TaskEntry.name. Behöver bara vara synligt i TaskEntryProp (så jag kan kolla i efterhand varför jag valde en diverse-task)

*/

import UIKit

enum FillWith: Int {
    case fillWithNone, fillWithPrevious, fillWithNext
}

enum InsertPosition: Int {
    case insertNewBeforeThis, insertNewAfterThis
}

class TaskEntryPropVC: 
    UIViewController, 
    UITableViewDataSource, 
    UITableViewDelegate,
    AppLoggerDataSource  {

    // Input data
    var taskEntryTemplate: TaskEntry?
    var segue: String?
    var taskList: [Task] = []
    var minimumDate: Date?
    var maximumDate: Date?
    var isOngoing: Bool?
    var isFirst: Bool?
    var isLast: Bool?
    
    // Output data
    var taskToUse: Task?
    var initialStartDate: Date?
    var initialStopDate: Date?
    var delete: FillWith?
    var insert: InsertPosition?

    // Local data
    var editStart = false
    var editStop = false
    
    // Table and table cells
    var table: UITableView!
    
    let cellStartTime = UITableViewCell(style: .value1, reuseIdentifier: "EditTaskEntry-type1")
    let cellStopTime = UITableViewCell(style: .value1, reuseIdentifier: "EditTaskEntry-type2")
    let cellTask = UITableViewCell(style: .value1, reuseIdentifier: "EditTaskEntry-type3")

    // Hold TaskEntry attributes while editing
    let datePickerStart = UIDatePicker()
    let datePickerStop = UIDatePicker()
    var taskSelected: Task?
    
    let buttonCancel = UIButton(type: .system)
    let buttonSave = UIButton(type: .system)

    //----------------------------------------------------------------
    // TaskEntryPropVC - Lazy properties
    //----------------------------------------------------------------
    
    lazy var appLog : AppLog = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.appLog
        }()

    lazy var logger: AppLogger = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewWillDisappear")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidAppear")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidDisappear")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        logger.datasource = self
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidDisappear")
        
        self.edgesForExtendedLayout = UIRectEdge()

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

        let buttonCancel = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(TaskEntryPropVC.cancel(_:)))
        self.navigationItem.leftBarButtonItem = buttonCancel
        let buttonSave = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(TaskEntryPropVC.save(_:)))
        self.navigationItem.rightBarButtonItem = buttonSave

        table = UITableView(frame: self.view.frame, style: .grouped)
        table.dataSource = self
        table.delegate = self
        self.view.addSubview(table)
        
        let now = Date()
        datePickerStart.date = now
        datePickerStop.date = now
        datePickerStart.addTarget(self, action: #selector(TaskEntryPropVC.datePickerChanged(_:)), for: UIControl.Event.valueChanged)
        datePickerStop.addTarget(self, action: #selector(TaskEntryPropVC.datePickerChanged(_:)), for: UIControl.Event.valueChanged)
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewWillAppear")

        if let indexPath = table.indexPathForSelectedRow {
            table.deselectRow(at: indexPath, animated: true)
        }
        
    }

    override func viewWillLayoutSubviews() {
        appLog.log(logger, logtype: .viewLifecycle, message: "viewWillLayoutSubviews")

        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        table.frame = CGRect(x: 5, y: 0, width: width-10, height: height)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidLayoutSubviews")

        table.separatorInset = UIEdgeInsets.zero
        table.layoutMargins = UIEdgeInsets.zero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        appLog.log(logger, logtype: .viewLifecycle, message: "didReceiveMemoryWarning")
    }

    // GUI actions

    @objc func cancel(_ sender: UIButton) {
        appLog.log(logger, logtype: .enterExit, message: "cancel")
        appLog.log(logger, logtype: .guiAction, message: "cancel")

        performSegue(withIdentifier: "CancelTaskEntry", sender: self)
    }
    
    @objc func save(_ sender: UIButton) {
        appLog.log(logger, logtype: .enterExit, message: "save")
        appLog.log(logger, logtype: .guiAction, message: "save")

        if let _ = taskSelected {
            // Must have selected a task to save the task entry
            performSegue(withIdentifier: "SaveTaskEntry", sender: self)            
        }
    }
    
    @objc func datePickerChanged(_ sender: UIDatePicker) {
        if sender == datePickerStart {
            if datePickerStart.date.compare(datePickerStop.date) == .orderedDescending {
                datePickerStop.date = datePickerStart.date
                cellStopTime.detailTextLabel?.text = UtilitiesDate.getString(datePickerStop.date)
            }
            cellStartTime.detailTextLabel?.text = UtilitiesDate.getString(datePickerStart.date)
        }
        if sender == datePickerStop {
            if datePickerStop.date.compare(datePickerStart.date) == .orderedAscending {
                datePickerStart.date = datePickerStop.date
                cellStartTime.detailTextLabel?.text = UtilitiesDate.getString(datePickerStart.date)
            }
            cellStopTime.detailTextLabel?.text = UtilitiesDate.getString(datePickerStop.date)
        }
    }
    
    // UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
            default: height = CGFloat(selectItemTableRowHeight)
            }
        default:
            height = CGFloat(selectItemTableRowHeight)
        }

        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var cellString = ""
        if let cell = tableView.cellForRow(at: indexPath),
            let s = cell.textLabel?.text {
                cellString = s
        }

        appLog.log(logger, logtype: .enterExit, message: "tableView.didSelectRowAtIndexPath")
        appLog.log(logger, logtype: .guiAction, message: "tableView.didSelectRowAtIndexPath(\(cellString))")

        editStart = false
        editStop = false
        
        guard let first = self.isFirst,
                let last = self.isLast else {
            appLog.log(logger, logtype: .guard, message: "guard fail in tableView:didSelectRowAtIndexPath")
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
                performSegue(withIdentifier: "SelectTask", sender: self)
            }
        case 2:
            // Sama logic as for "cellForRowAtIndexPath"
            switch indexPath.row {
            case 0:
                self.delete = .fillWithPrevious
                if first {
                    self.delete = .fillWithNone
                }
                performSegue(withIdentifier: "DeleteTaskEntry", sender: self)
            case 1:
                self.delete = .fillWithNone
                if (first && !last) {
                    self.delete = .fillWithNext
                }
                performSegue(withIdentifier: "DeleteTaskEntry", sender: self)
            case 2:
                self.delete = .fillWithNext
                performSegue(withIdentifier: "DeleteTaskEntry", sender: self)
            default:
                _ = 1
            }
        case 3:
            switch indexPath.row {
            case 0:
                self.insert = .insertNewBeforeThis
                performSegue(withIdentifier: "InsertNewTaskEntry", sender: self)
            case 1:
                self.insert = .insertNewAfterThis
                performSegue(withIdentifier: "InsertNewTaskEntry", sender: self)
            default:
                _ = 1
            }
        default:
            _ = 1
        }        
    }
    
    // UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let ongoing = self.isOngoing,
            let first = self.isFirst,
            let last = self.isLast else {
            appLog.log(logger, logtype: .guard, message: "guard fail in tableView:numberOfRowsInSection")
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
                n += 1
            }
            // If not last, show "delete, fill with next"
            if !last {
                n += 1
            }
            return n
            // Insert
        case 3:
            // Always show "insert before"
            var n = 1
            // If not ongoing, show "insert after"
            if !ongoing {
                n += 1
            }
            return n
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell

        guard let first = self.isFirst,
                let last = self.isLast else {
            appLog.log(logger, logtype: .guard, message: "guard fail in tableView:cellForRowAtIndexPath")
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
                cellTask.accessoryType = .disclosureIndicator
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectTask" {
            if let vc = segue.destination as? TaskSelectVC {
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

    @IBAction func exitSelectTask(_ unwindSegue: UIStoryboardSegue ) {
        if unwindSegue.identifier == "DoneSelectTask" {

            guard let vc = unwindSegue.source as? TaskSelectVC,
                let i = vc.taskIndexSelected else {
                appLog.log(logger, logtype: .guard, message: "guard fail in exitSelectTask DoneSelectTask 1")
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
