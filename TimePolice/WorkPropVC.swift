//
//  WorkPropVC.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-05-08.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

/*
TODO

- Make sure that starttime <= stoptime, whenever some change is done

- Migrate code to programmatic table

- 3 sections/groups: Datepickers, task, delete buttons

*/

import UIKit

class WorkPropVC: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    // Input data
    var workTemplate: Work?
    var segue: String?
    var taskList: [Task]?
    var minimumDate: NSDate?
    var maximumDate: NSDate?
    var isOngoing: Bool?
    
    // Output data
    var taskToUse: Task?
    var initialStartDate: NSDate?
    var initialStopDate: NSDate?

    // Local data
    var editStart = false
    var editStop = false
    
    // Table and table cells
    var table: UITableView = UITableView(frame: self.view.frame, style: .Grouped)
    
    let cellStartTime = UITableViewCell(style: .Value1, reuseIdentifier: "EditWork-type1")
    let cellStopTime = UITableViewCell(style: .Value1, reuseIdentifier: "EditWork-type2")
    let cellTask = UITableViewCell(style: .Value1, reuseIdentifier: "EditWork-type3")

    // Hold TaskEntry attributes while editing
    let datePickerStart = UIDatePicker()
    let datePickerStop = UIDatePicker()
    var taskSelected: Task?
    
    let buttonCancel = UIButton.buttonWithType(.System) as! UIButton
    let buttonSave = UIButton.buttonWithType(.System) as! UIButton

    //----------------------------------------------------------------
    // EditWorkVC - Lazy properties
    //----------------------------------------------------------------
    
    lazy var appLog : AppLog = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.appLog
        }()

    lazy var logger : AppLogger = {
        return ApplogLog(locator: "EditWorkVC")
    }()


    //---------------------------------------------
    // EditWorkVC - View lifecycle
    //---------------------------------------------

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger, logtype: .iOS, message: "viewWillAppear")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        appLog.log(logger, logtype: .iOS, message: "viewWillDisappear")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        appLog.log(logger, logtype: .iOS, message: "viewDidAppear")
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        appLog.log(logger, logtype: .iOS, message: "viewDidDisappear")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
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

        buttonCancel.setTitleColor(UIColor(red:1.0, green: 0.0, blue: 0.0, alpha: 1.0), forState: UIControlState.Normal)
        buttonCancel.setTitle("Cancel", forState: UIControlState.Normal)
        buttonCancel.addTarget(self, action: "cancel:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(buttonCancel)

        buttonSave.setTitleColor(UIColor(red:1.0, green: 0.0, blue: 0.0, alpha: 1.0), forState: UIControlState.Normal)
        buttonSave.setTitle("Save", forState: UIControlState.Normal)
        buttonSave.titleLabel!.textAlignment = NSTextAlignment.Left
        buttonSave.addTarget(self, action: "save:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(buttonSave)
        
        table.dataSource = self
        table.delegate = self
        self.view.addSubview(table)
        
        let now = NSDate()
        datePickerStart.date = now
        datePickerStop.date = now
        datePickerStart.addTarget(self, action: "datePickerChanged:", forControlEvents: UIControlEvents.ValueChanged)
        datePickerStop.addTarget(self, action: "datePickerChanged:", forControlEvents: UIControlEvents.ValueChanged)

        if let t = taskEntryTemplate {
            datePickerStart.date = t.starttime
            datePickerStop.date = t.stoptime
            taskSelected = t.task
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger, logtype: .iOS, message: "viewWillAppear")

        if let indexPath = table.indexPathForSelectedRow() {
            table.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
    }

    override func viewWillLayoutSubviews() {
        appLog.log(logger, logtype: .iOS, message: "viewWillLayoutSubviews")

        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        var lastview: UIView

        buttonCancel.frame = CGRectMake(10, 0, 80, 20)
        lastview = buttonCancel

        buttonSave.frame = CGRectMake(width-10-80, 0, 80, 20)
        lastview = buttonSave

        table.frame = CGRectMake(5,CGRectGetMaxY(lastview.frame), width-10, height-CGRectGetMaxY(lastview.frame))
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appLog.log(logger, logtype: .iOS, message: "viewDidLayoutSubviews")

        tableTask.separatorInset = UIEdgeInsetsZero
        tableTask.layoutMargins = UIEdgeInsetsZero
    }
    




    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        appLog.log(logger, logtype: .iOS, message: "didReceiveMemoryWarning")
    }

    // GUI actions

    func cancel(sender: UIButton) {
        performSegueWithIdentifier("CancelTaskEntry", sender: self)
    }
    
    func save(sender: UIButton) {
        if let t = taskSelected {
            // Must have selected a task to save the task entry
            performSegueWithIdentifier("SaveTaskEntry", sender: self)            
        }
    }
    
    func datePickerChanged(sender: UIDatePicker) {
        if sender == datePickerStart {
            if datePickerStart.date.compare(datePickerStop.date) == .OrderedDescending {
                datePickerStop.date = datePickerStart.date
                cellStopTime.detailTextLabel?.text = getString(datePickerStop.date)
            }
            cellStartTime.detailTextLabel?.text = getString(datePickerStart.date)
        }
        if sender == datePickerStop {
            if datePickerStop.date.compare(datePickerStart.date) == .OrderedAscending {
                datePickerStart.date = datePickerStop.date
                cellStartTime.detailTextLabel?.text = getString(datePickerStart.date)
            }
            cellStopTime.detailTextLabel?.text = getString(datePickerStop.date)
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
        
        self.table.beginUpdates()
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                editStart = true
            case 2:
                editStop = true
            default:
                let x = 1
            }
        case 1:
            switch indexPath.row {
            default: 
                performSegueWithIdentifier("SelectTask", sender: self)
            }
        default:
            let x = 1
        }
        
        self.table.endUpdates()
    }
    
    // UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cellStartTime.textLabel?.text = "Start time"
                cellStartTime.detailTextLabel?.text = getString(datePickerStart.date)
                cell = cellStartTime
            case 1:
                cell = UITableViewCell()
                cell.contentView.addSubview(datePickerStart)
                cell.clipsToBounds = true
            case 2:
                cellStopTime.textLabel?.text = "Stop time"
                cellStopTime.detailTextLabel?.text = getString(datePickerStop.date)
                cell = cellStopTime
            case 3:
                cell = UITableViewCell()
                let datepicker = UIDatePicker()
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
                }
                cellTask.accessoryType = .DisclosureIndicator
                cell = cellTask
            default:
                cell = UITableViewCell()
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
            if let vc = segue.destinationViewController as? SelectTaskVC {
                vc.tasks = tasks
            }
        }
        if segue.identifier == "CancelTaskEntry" {
            // Do nothing
        }
        if segue.identifier == "SaveTaskEntry" {
            // Fill in TaskEntryResult
            taskEntryResult = TaskEntry(
                starttime: datePickerStart.date, 
                stoptime: datePickerStop.date,
                task: taskSelected!,
                description: "description...")

        }
    }
    
    @IBAction func exitSelectTask(unwindSegue: UIStoryboardSegue ) {
        if unwindSegue.identifier == "DoneSelectTask" {
            if let vc = unwindSegue.sourceViewController as? SelectTaskVC,
                i = vc.taskIndexSelected {
                taskSelected = tasks[i]
                cellTask.detailTextLabel?.text = taskSelected!.name
            }
        }
    }

/****************************************

    // UI elements
    var datepickerStart: UIDatePicker?
    var datepickerStop: UIDatePicker?
    var fillEmptySpaceWith: UISegmentedControl?

    // Input values
    var work: Work!
    var minimumDate: NSDate?
    var maximumDate: NSDate?
    var taskList: [Task]?
    var isOngoing: Bool?

    // Output values
    var taskToUse: Task?
    var initialStartDate: NSDate?
    var initialStopDate: NSDate?

    var tableTask = UITableView()
    

>>>>>>>>>>


    override func viewDidLoad() {
        super.viewDidLoad()

        appLog.log(logger, logtype: .iOS, message: "viewDidLoad")
        appLog.log(logger, logtype: .Debug, message: "work=\(work.task.name)|\(getString(work.startTime))|\(getString(work.stopTime))")
        var d1 = "---"
        var d2 = "---"
        if let d = minimumDate {
            d1 = getString(d)
        }
        if let d = maximumDate {
            d2 = getString(d)
        }
        appLog.log(logger, logtype: .Debug, message: "minimumDate=\(d1)|maximumDate=\(d2)")
        appLog.log(logger, logtype: .Debug, message: "isOngoing=\(isOngoing)")
        
        var lastview: UIView

        let width = CGRectGetWidth(self.view.frame)
        
        let font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        let attributesTitle = [
            NSForegroundColorAttributeName : UIColor(red: 0.175, green: 0.458, blue: 0.831, alpha: 1),
            NSFontAttributeName : font,
            NSTextEffectAttributeName : NSTextEffectLetterpressStyle
        ]
        let attributesBody = [
            NSForegroundColorAttributeName : UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1),
            NSTextEffectAttributeName : NSTextEffectLetterpressStyle
        ]

        var scrollViewRect = self.view.frame
        scrollViewRect.origin.y += 10
        scrollViewRect.size.height -= 10
        let scrollView = UIScrollView()
        scrollView.frame = scrollViewRect
        scrollView.contentSize = CGSizeMake(width, 2000)
        self.view.addSubview(scrollView)

        // Change work section

        let labelTitleChange = UILabel()
        labelTitleChange.attributedText = NSMutableAttributedString(string: "Change workitem", attributes: attributesTitle)
        labelTitleChange.textAlignment = NSTextAlignment.Center
        labelTitleChange.frame = CGRectMake(00, 20, width, 20)
        scrollView.addSubview(labelTitleChange)
        lastview = labelTitleChange

        // Starttime

        let buttonCancel = UIButton.buttonWithType(.System) as! UIButton
        buttonCancel.frame = CGRectMake(10, 20, 80, 20)
        buttonCancel.setTitleColor(UIColor(red:1.0, green: 0.0, blue: 0.0, alpha: 1.0), forState: UIControlState.Normal)
        buttonCancel.setTitle("Cancel", forState: UIControlState.Normal)
        buttonCancel.addTarget(self, action: "cancelEditWork:", forControlEvents: UIControlEvents.TouchUpInside)
        scrollView.addSubview(buttonCancel)
        lastview = buttonCancel

        let buttonSave = UIButton.buttonWithType(.System) as! UIButton
        buttonSave.frame = CGRectMake(width-10-80, 20, 80, 20)
        buttonSave.setTitleColor(UIColor(red:1.0, green: 0.0, blue: 0.0, alpha: 1.0), forState: UIControlState.Normal)
        buttonSave.setTitle("Save", forState: UIControlState.Normal)
        buttonSave.titleLabel!.textAlignment = NSTextAlignment.Left
        buttonSave.addTarget(self, action: "saveEditWork:", forControlEvents: UIControlEvents.TouchUpInside)
        scrollView.addSubview(buttonSave)
        lastview = buttonSave

        let labelStart = UILabel()
        labelStart.attributedText = NSMutableAttributedString(string: "Start", attributes: attributesBody)
        labelStart.textAlignment = NSTextAlignment.Left
        labelStart.frame = CGRectMake(10, CGRectGetMaxY(lastview.frame) + 20, width-10, 20)
        scrollView.addSubview(labelStart)
        lastview = labelStart

        datepickerStart = UIDatePicker()
        datepickerStart!.frame.origin = CGPoint(x: 0, y: CGRectGetMaxY(lastview.frame))
        datepickerStart!.frame.size.height = 162
        datepickerStart!.minimumDate = self.minimumDate
        datepickerStart!.maximumDate = self.maximumDate
        datepickerStart!.date = work.startTime
        datepickerStart!.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        initialStartDate = work.startTime
        scrollView.addSubview(datepickerStart!)
        lastview = datepickerStart!



        // Stoptime

        if isOngoing == false {

            let labelStop = UILabel()
            labelStop.attributedText = NSMutableAttributedString(string: "Stop", attributes: attributesBody)
            labelStop.textAlignment = NSTextAlignment.Left
            labelStop.frame = CGRectMake(10, CGRectGetMaxY(lastview.frame), width-10, 20)
            scrollView.addSubview(labelStop)
            lastview = labelStop

            datepickerStop = UIDatePicker()
            datepickerStop!.frame.origin = CGPoint(x: 0, y: CGRectGetMaxY(lastview.frame))
            datepickerStop!.frame.size.height = 162
            datepickerStop!.minimumDate = self.minimumDate
            datepickerStop!.maximumDate = self.maximumDate
            datepickerStop!.date = work.stopTime
            datepickerStop!.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
            initialStopDate = work.stopTime
            scrollView.addSubview(datepickerStop!)
            lastview = datepickerStop!

        }

        // Task

        let labelTask = UILabel()
        labelTask.attributedText = NSMutableAttributedString(string: "Task", attributes: attributesBody)
        labelTask.textAlignment = NSTextAlignment.Left
        labelTask.frame = CGRectMake(10, CGRectGetMaxY(lastview.frame), width-10, 20)
        scrollView.addSubview(labelTask)
        lastview = labelTask

        tableTask.frame = CGRectMake(0, CGRectGetMaxY(lastview.frame) + 10, width, 150)
        tableTask.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "EditWorkVCCell")
        tableTask.dataSource = self
        tableTask.delegate = self
        tableTask.rowHeight = 20
        scrollView.addSubview(tableTask)
        lastview = tableTask
        

        

        // Delete work section
        
        let labelTitleDelete = UILabel()
        labelTitleDelete.attributedText = NSMutableAttributedString(string: "Delete workitem", attributes: attributesTitle)
        labelTitleDelete.textAlignment = NSTextAlignment.Center
        labelTitleDelete.frame = CGRectMake(10, CGRectGetMaxY(lastview.frame) + 30, width-10, 20)
        scrollView.addSubview(labelTitleDelete)
        lastview = labelTitleDelete

        let labelFillWith = UILabel()
        labelFillWith.attributedText = NSMutableAttributedString(string: "Fill empty space with", attributes: attributesBody)
        labelFillWith.textAlignment = NSTextAlignment.Left
        labelFillWith.frame = CGRectMake(10, CGRectGetMaxY(lastview.frame) + 20, width-10, 20)
        scrollView.addSubview(labelFillWith)
        lastview = labelFillWith
        
        fillEmptySpaceWith = UISegmentedControl(items: ["None", "Previous", "Next"])
        fillEmptySpaceWith!.frame = CGRectMake(10, CGRectGetMaxY(lastview.frame) + 10, width/3*2, 30)
        fillEmptySpaceWith!.center.x = width/2
        fillEmptySpaceWith!.selectedSegmentIndex = 0
        scrollView.addSubview(fillEmptySpaceWith!)
        lastview = fillEmptySpaceWith!
        

        let buttonDelete = UIButton.buttonWithType(.System) as! UIButton
        buttonDelete.frame.size = CGSize(width: 140, height:30)
        buttonDelete.frame.origin.y = CGRectGetMaxY(lastview.frame)+10
        buttonDelete.center.x = width/2
        buttonDelete.backgroundColor = UIColor(red: 0.7, green: 0.0, blue: 0.0, alpha: 1.0)
        buttonDelete.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buttonDelete.setTitle("Delete workitem", forState: UIControlState.Normal)
        buttonDelete.addTarget(self, action: "deleteWork:", forControlEvents: UIControlEvents.TouchUpInside)
        scrollView.addSubview(buttonDelete)
        lastview = buttonDelete
    }

    //-----------------------------------------
    // EditWorkVC- Segue handling
    //-----------------------------------------

    @IBAction func exitSelectTask(unwindSegue: UIStoryboardSegue) {
        if unwindSegue.identifier == "DoneSelectTask" {
            
        }
    }
    
    //-----------------------------------------
    // EditWorkVC- VC button actions
    //-----------------------------------------


    func cancelEditWork(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "cancelEditWork")
        
        performSegueWithIdentifier("CancelEditWork", sender: self)
    }

    func saveEditWork(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "saveEditWork")
        
        performSegueWithIdentifier("OkEditWork", sender: self)
    }

    func deleteWork(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "deleteWork")
        
        performSegueWithIdentifier("DeleteWork", sender: self)
    }

    func datePickerChanged(sender: UIDatePicker) {
        if isOngoing == true {
            // Only one datepicker shown, othig to keep in sync
            return
        }
        if sender == datepickerStart {
            if datepickerStart!.date.compare(datepickerStop!.date) == .OrderedDescending {
                datepickerStop!.date = datepickerStart!.date
            }
        }
        if sender == datepickerStop {
            if datepickerStop!.date.compare(datepickerStart!.date) == .OrderedAscending {
                datepickerStart!.date = datepickerStop!.date
            }
        }
    }

    //-----------------------------------------
    // EditWorkVC - UITableView
    //-----------------------------------------
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let t = taskList {
            return t.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EditWorkVCCell") as! UITableViewCell
        cell.textLabel?.text = taskList?[indexPath.row].name

        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let task = taskList?[indexPath.row] {
            taskToUse = task
        }
    }

************************/

}
