//
//  EditWorkScrollableViewCOntroller.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-05-08.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

import UIKit

class EditWorkScrollableViewCOntroller: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    // Input values
    var work: Work?
    var minimumDate: NSDate?
    var maximumDate: NSDate?
    var taskList: [Task]?

    // Output values
    var taskToUse: Task?
    var initialDate: NSDate?
    
    var logger: AppLogger?

    override func viewDidLoad() {
        super.viewDidLoad()

        logger = ApplogLog(locator: "EditWorkScrollableVC")
        
        appLog.log(logger!, logtype: .EnterExit, message: "viewDidLoad")
        
        var lastview: UIView
        var viewrect: CGRect

        let width = CGRectGetWidth(self.view.frame)
        
        let font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        let textColor = UIColor(red: 0.175, green: 0.458, blue: 0.831, alpha: 1)
        let attributes = [
            NSForegroundColorAttributeName : textColor,
//            NSFontAttributeName : font,
            NSTextEffectAttributeName : NSTextEffectLetterpressStyle
        ]

        var scrollViewRect = self.view.frame
        scrollViewRect.origin.y += 10
        scrollViewRect.size.height -= 150
        let scrollView = UIScrollView()
        scrollView.frame = scrollViewRect
        scrollView.contentSize = CGSizeMake(width, 2000)
        self.view.addSubview(scrollView)

        // Change work section

        let labelTitleChange = UILabel()
        labelTitleChange.attributedText = NSMutableAttributedString(string: "Change workitem", attributes: attributes)
        labelTitleChange.textAlignment = NSTextAlignment.Center
        labelTitleChange.frame = CGRectMake(0, 20, width, 30)
        scrollView.addSubview(labelTitleChange)
        lastview = labelTitleChange

        // Starttime

        let labelStart = UILabel()
        labelStart.text = "Start"
        labelStart.textAlignment = NSTextAlignment.Center
        labelStart.frame = CGRectMake(0, CGRectGetMaxY(lastview.frame), width, 30)
        scrollView.addSubview(labelStart)
        lastview = labelStart

        let datepickerStart = UIDatePicker()
        datepickerStart.frame.origin = CGPoint(x: 0, y: CGRectGetMaxY(lastview.frame))
        datepickerStart.frame.size.height = 162
        scrollView.addSubview(datepickerStart)
        lastview = datepickerStart

        // Stoptime

        let labelStop = UILabel()
        labelStop.text = "Stop"
        labelStop.textAlignment = NSTextAlignment.Center
        labelStop.frame = CGRectMake(0, CGRectGetMaxY(lastview.frame), width, 30)
        scrollView.addSubview(labelStop)
        lastview = labelStop

        let datepickerStop = UIDatePicker()
        datepickerStop.frame.origin = CGPoint(x: 0, y: CGRectGetMaxY(lastview.frame))
        datepickerStop.frame.size.height = 162
        scrollView.addSubview(datepickerStop)
        lastview = datepickerStop

        // Task

        let labelTask = UILabel()
        labelTask.text = "Task"
        labelTask.textAlignment = NSTextAlignment.Center
        labelTask.frame = CGRectMake(0, CGRectGetMaxY(lastview.frame), width, 30)
        scrollView.addSubview(labelTask)
        lastview = labelTask

        // A table

        let tableTask = UITableView()
        tableTask.frame = CGRectMake(0, CGRectGetMaxY(lastview.frame), width, 150)
        tableTask.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "EditWorkScrollableCell")
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
        labelTitleDelete.attributedText = NSMutableAttributedString(string: "Delete workitem", attributes: attributes)
        labelTitleDelete.textAlignment = NSTextAlignment.Center
        labelTitleDelete.frame = CGRectMake(0, CGRectGetMaxY(lastview.frame), width, 30)
        scrollView.addSubview(labelTitleDelete)
        lastview = labelTitleDelete

        let labelFillWith = UILabel()
        labelFillWith.text = "Fill empty space with"
        labelFillWith.textAlignment = NSTextAlignment.Center
        labelFillWith.frame = CGRectMake(0, CGRectGetMaxY(lastview.frame), width, 30)
        scrollView.addSubview(labelFillWith)
        lastview = labelFillWith
        
        let segmentedFillWith = UISegmentedControl(items: ["None", "Previous", "Next"])
        segmentedFillWith.frame = CGRectMake(0, CGRectGetMaxY(lastview.frame), width/3*2, 30)
        segmentedFillWith.center.x = width/2
        segmentedFillWith.selectedSegmentIndex = 0
        scrollView.addSubview(segmentedFillWith)
        lastview = segmentedFillWith
        

        let buttonDelete = UIButton.buttonWithType(.System) as! UIButton
        buttonDelete.frame.size = CGSize(width: 140, height:30)
        buttonDelete.frame.origin.y = CGRectGetMaxY(lastview.frame)+10
        buttonDelete.center.x = width/2
        buttonDelete.backgroundColor = UIColor(red: 0.7, green: 0.0, blue: 0.0, alpha: 1.0)
        buttonDelete.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        buttonDelete.setTitle("Delete work", forState: UIControlState.Normal)
        buttonDelete.addTarget(self, action: "deleteWork:", forControlEvents: UIControlEvents.TouchUpInside)
        scrollView.addSubview(buttonDelete)
        lastview = segmentedFillWith

    
    
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        appLog.log(logger!, logtype: .EnterExit, message: "didReceiveMemoryWarning")
    }

    //-----------------------------------------
    // EditWorkScrollableViewController- VC button actions
    //-----------------------------------------


    func cancelEditWork(sender: UIButton) {
        appLog.log(logger!, logtype: .EnterExit, message: "cancelEditWork")
        
        performSegueWithIdentifier("CancelEditWork", sender: self)
    }

    func saveEditWork(sender: UIButton) {
        appLog.log(logger!, logtype: .EnterExit, message: "saveEditWork")
        
        performSegueWithIdentifier("OkEditWork", sender: self)
    }

    func deleteWork(sender: UIButton) {
        appLog.log(logger!, logtype: .EnterExit, message: "deleteWork")
        
        performSegueWithIdentifier("DeleteWork", sender: self)
    }

    //-----------------------------------------
    // EditWorkScrollableViewController- UITableView
    //-----------------------------------------
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let t = taskList {
            return t.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EditWorkScrollableCell") as! UITableViewCell
        cell.textLabel?.text = taskList?[indexPath.row].name
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let task = taskList?[indexPath.row] {
            taskToUse = task
        }
    }
    

    
    //----------------------------------------------------------------
    // EditWorkScrollableViewController - AppDelegate lazy properties
    //----------------------------------------------------------------
    
    lazy var appLog : AppLog = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.appLog
        }()

}
