//
//  EditWorkVC.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-05-08.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

/*
TODO

- Make sure that starttime <= stoptime, whenever some change is done

*/

import UIKit

class EditWorkVC: UIViewController, UITableViewDataSource, UITableViewDelegate  {

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

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        appLog.log(logger, logtype: .iOS, message: "viewWillLayoutSubviews")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appLog.log(logger, logtype: .iOS, message: "viewDidLayoutSubviews")
    }

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
        labelTitleChange.frame = CGRectMake(0, 20, width, 20)
        scrollView.addSubview(labelTitleChange)
        lastview = labelTitleChange

        // Starttime

        let labelStart = UILabel()
        labelStart.attributedText = NSMutableAttributedString(string: "Start", attributes: attributesBody)
        labelStart.textAlignment = NSTextAlignment.Center
        labelStart.frame = CGRectMake(0, CGRectGetMaxY(lastview.frame) + 20, width, 20)
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
            labelStop.textAlignment = NSTextAlignment.Center
            labelStop.frame = CGRectMake(0, CGRectGetMaxY(lastview.frame), width, 20)
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
        labelTask.textAlignment = NSTextAlignment.Center
        labelTask.frame = CGRectMake(0, CGRectGetMaxY(lastview.frame), width, 20)
        scrollView.addSubview(labelTask)
        lastview = labelTask

        let tableTask = UITableView()
        tableTask.frame = CGRectMake(0, CGRectGetMaxY(lastview.frame), width, 150)
        tableTask.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "EditWorkVCCell")
        tableTask.dataSource = self
        tableTask.delegate = self
        tableTask.rowHeight = 20
        scrollView.addSubview(tableTask)
        lastview = tableTask
        
        let buttonCancel = UIButton.buttonWithType(.System) as! UIButton
        buttonCancel.frame.size = CGSize(width: 140, height:30)
        buttonCancel.frame.origin.y = CGRectGetMaxY(lastview.frame)+10
        buttonCancel.center.x = width/4
        buttonCancel.backgroundColor = UIColor(red: 0.7, green: 0.0, blue: 0.0, alpha: 1.0)
        buttonCancel.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buttonCancel.setTitle("Cancel", forState: UIControlState.Normal)
        buttonCancel.addTarget(self, action: "cancelEditWork:", forControlEvents: UIControlEvents.TouchUpInside)
        scrollView.addSubview(buttonCancel)
        lastview = buttonCancel

        let buttonSave = UIButton.buttonWithType(.System) as! UIButton
        buttonSave.frame.size = CGSize(width: 140, height:30)
        buttonSave.frame.origin.y = lastview.frame.origin.y
        buttonSave.center.x = width/4*3
        buttonSave.backgroundColor = UIColor(red: 0.7, green: 0.0, blue: 0.0, alpha: 1.0)
        buttonSave.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buttonSave.setTitle("Save", forState: UIControlState.Normal)
        buttonSave.addTarget(self, action: "saveEditWork:", forControlEvents: UIControlEvents.TouchUpInside)
        scrollView.addSubview(buttonSave)
        lastview = buttonSave

        

        // Delete work section
        
        let labelTitleDelete = UILabel()
        labelTitleDelete.attributedText = NSMutableAttributedString(string: "Delete workitem", attributes: attributesTitle)
        labelTitleDelete.textAlignment = NSTextAlignment.Center
        labelTitleDelete.frame = CGRectMake(0, CGRectGetMaxY(lastview.frame) + 30, width, 20)
        scrollView.addSubview(labelTitleDelete)
        lastview = labelTitleDelete

        let labelFillWith = UILabel()
        labelFillWith.attributedText = NSMutableAttributedString(string: "Fill empty space with", attributes: attributesBody)
        labelFillWith.textAlignment = NSTextAlignment.Center
        labelFillWith.frame = CGRectMake(0, CGRectGetMaxY(lastview.frame) + 20, width, 20)
        scrollView.addSubview(labelFillWith)
        lastview = labelFillWith
        
        fillEmptySpaceWith = UISegmentedControl(items: ["None", "Previous", "Next"])
        fillEmptySpaceWith!.frame = CGRectMake(0, CGRectGetMaxY(lastview.frame) + 10, width/3*2, 30)
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
        buttonDelete.setTitle("Delete work", forState: UIControlState.Normal)
        buttonDelete.addTarget(self, action: "deleteWork:", forControlEvents: UIControlEvents.TouchUpInside)
        scrollView.addSubview(buttonDelete)
        lastview = buttonDelete
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        appLog.log(logger, logtype: .iOS, message: "didReceiveMemoryWarning")
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
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let task = taskList?[indexPath.row] {
            taskToUse = task
        }
    }
}