//
//  WorkListViewController.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-04-21.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

/* TODO

- Scroll to last line in tableview

- Custom table cell with 2 labels? 1 = name, 2 = start/stop

- Height of each cell in tableview (set for prototype cell?)

*/

import UIKit
import CoreData

class WorkListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var session: Session?
    var sourceController: TimePoliceViewController?

    var workListTableView = UITableView(frame: CGRectZero, style: .Plain)

    var statusView: UITextView?
    var sessionLabel: UILabel?

    var selectedWork: Work?
    var selectedWorkIndex: Int?

    var textviewlogger: AppLogger?
    var stringlogger: AppLogger?
    let log = String()


    //---------------------------------------------
    // WorkListViewController - View lifecycle
    //---------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        var sessionLabelRect = self.view.frame
        sessionLabelRect.origin.x = 5
        sessionLabelRect.origin.y = 20
        sessionLabelRect.size.height = 30
        sessionLabelRect.size.width -= 10
        sessionLabel = UILabel(frame: sessionLabelRect)
        sessionLabel!.textColor = UIColor.whiteColor()
        sessionLabel!.text = session?.name
        sessionLabel!.textAlignment = .Center
        sessionLabel!.adjustsFontSizeToFitWidth = true
        self.view.addSubview(sessionLabel!)

        var workListRect = self.view.frame
        workListRect.origin.y += 50
        workListRect.size.height -= 205
        workListTableView.frame = workListRect
        workListTableView.backgroundColor = UIColor(white: 0.4, alpha: 1.0)
        workListTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "WorkListWorkCell")
        workListTableView.dataSource = self
        workListTableView.delegate = self
        self.view.addSubview(workListTableView)
        scrollToEnd()

        var statusRect = self.view.bounds
        statusRect.origin.x = 5
        statusRect.origin.y = statusRect.size.height-110
        statusRect.size.height = 100
        statusRect.size.width -= 10
        statusView = UITextView(frame: statusRect)
        statusView!.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        statusView!.textColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        statusView!.font = UIFont.systemFontOfSize(8)
        statusView!.editable = false
        self.view.addSubview(statusView!)

        let exitRect = CGRect(origin: CGPoint(x: self.view.bounds.size.width - 80, y: self.view.bounds.size.height-45), size: CGSize(width:70, height:30))
        let exitButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        exitButton.frame = exitRect
        exitButton.backgroundColor = UIColor(red: 0.0, green: 0.7, blue: 0.0, alpha: 1.0)
        exitButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        exitButton.setTitle("EXIT", forState: UIControlState.Normal)
        exitButton.addTarget(self, action: "exit:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(exitButton)
        
        let switchOngoingFinishedRect = CGRect(origin: CGPoint(x: 10, y: self.view.bounds.size.height-45), size: CGSize(width:140, height:30))
        let switchOngoingFinishedButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        switchOngoingFinishedButton.frame = switchOngoingFinishedRect
        switchOngoingFinishedButton.backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 0.0, alpha: 1.0)
        switchOngoingFinishedButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        switchOngoingFinishedButton.setTitle("Ongoing/Finished", forState: UIControlState.Normal)
        switchOngoingFinishedButton.addTarget(self, action: "switchOngoingFinished:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(switchOngoingFinishedButton)

        let addButton = UIButton.buttonWithType(.System) as! UIButton
        let addRect = CGRect(origin: CGPoint(x: 5, y: self.view.bounds.size.height-145), size: CGSize(width:self.view.bounds.size.width-10, height:30))
        addButton.frame = addRect
        addButton.backgroundColor = UIColor(red: 0.7, green: 0.0, blue: 0.0, alpha: 1.0)
        addButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        addButton.setTitle("Add/duplicate work", forState: UIControlState.Normal)
        addButton.addTarget(self, action: "addWork:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(addButton)
        
        textviewlogger = TextViewLog(textview: statusView!, locator: "WorkListVC3")
        appLog.log(textviewlogger!, loglevel: .Debug, message: "viewDidLoad")
        appLog.log(textviewlogger!, loglevel: .Debug) { "viewDidLoad2" }
        
        stringlogger = StringLog(logstring: appLog.logString, locator: "WorkListVC4")
        appLog.log(stringlogger!, loglevel: .Debug, message: "viewDidLoad")
        appLog.log(stringlogger!, loglevel: .Debug) { "viewDidLoad2" }
        println(stringlogger!.getContent())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        TextViewLogger.log(statusView!, message: String("\n\(getString(NSDate())) WorkListVC.didReceiveMemoryWarning"))
    }
    

    //-----------------------------------------
    // WorkListViewController- VC button actions
    //-----------------------------------------


    func exit(sender: UIButton) {
        TextViewLogger.log(statusView!, message: "\n\(getString(NSDate())) WorkListVC.exit")
        
        performSegueWithIdentifier("Exit", sender: self)
    }

    func switchOngoingFinished(sender: UIButton) {
        TextViewLogger.log(statusView!, message: "\n\(getString(NSDate())) WorkListVC.signInOut")

        if let w = session?.getLastWork() {
            if w.isOngoing() {
                w.setStoppedAt(NSDate())
            } else {
                w.setAsOngoing()
            }
            workListTableView.reloadData()
            scrollToEnd()
        }

    }
    
    func addWork(sender: UIButton) {
        TextViewLogger.log(statusView!, message: "\n\(getString(NSDate())) WorkListVC.addWork")
        if let moc = managedObjectContext,
                 s = session {
            let now = NSDate()
            var task = s.tasks[0] as! Task
            if let lastWork = s.getLastWork() {
                task = lastWork.task
                if lastWork.isOngoing() {
                    lastWork.setStoppedAt(now)
                }
            }
            Work.createInMOC(moc, name: "", session: s, task: task)
            TimePoliceModelUtils.save(moc)

            workListTableView.reloadData()
            scrollToEnd()
        }
    }

    
    //-----------------------------------------
    // WorkListViewController- UITableView
    //-----------------------------------------

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let w = session?.work {
            return w.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkListWorkCell") as! UITableViewCell
        if let w = session?.work[indexPath.row] as? Work {
            if w.isStopped() {
                let timeForWork = w.stopTime.timeIntervalSinceDate(w.startTime)
                cell.textLabel?.text = "W: \(w.task.name) \(getStringNoDate(w.startTime))->\(getStringNoDate(w.stopTime)) = \(getString(timeForWork))\n"
            } else {
                cell.textLabel?.text = "W: \(w.task.name) \(getStringNoDate(w.startTime))->(ongoing) = ------\n"
            }            
        }
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let w = session?.work[indexPath.row] as? Work {
            selectedWork = w
            selectedWorkIndex = indexPath.row
            
            TextViewLogger.log(statusView!,
                message: String("\n\(getString(NSDate())) WorkListVC.selected(row=\(indexPath.row), work=\(w.task.name))"))

            performSegueWithIdentifier("EditWork", sender: self)
        }
    }

    func scrollToEnd() {
        let numberOfSections = workListTableView.numberOfSections()
        let numberOfRows = workListTableView.numberOfRowsInSection(numberOfSections-1)
        
        if numberOfRows > 0 {
            println(numberOfSections)
            println(numberOfRows)
            let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
            workListTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
        
    }

    //--------------------------------------------------
    // TaskPickerViewController - AppDelegate lazy properties
    //--------------------------------------------------
    
    lazy var managedObjectContext : NSManagedObjectContext? = {

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
        }()

    lazy var appLog : AppLog = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.appLog        
    }()

    //---------------------------------------------
    // WorkListViewController - Segue handling
    //---------------------------------------------


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        TextViewLogger.log(statusView!, message: String("\n\(getString(NSDate())) WorkListVC.prepareForSegue(\(segue.identifier)"))

        if segue.identifier == "EditWork" {
            if let s = session {
                TextViewLogger.log(statusView!, message: TimePoliceModelUtils.getSessionWork(s))
            }

            let vc = segue.destinationViewController as! TaskPickerEditWorkViewController
            
            if let s = session {
                vc.taskList = s.tasks.array as? [Task]
                // Never set any time into the future
                vc.maximumDate = NSDate()
                if let wl = s.work.array as? [Work],
                        i = selectedWorkIndex {
                    vc.work = wl[i]
                    if i > 0 {
                        // Limit to starttime of previous item, if any
                        vc.minimumDate = wl[i-1].startTime
                    }
                    if i < wl.count-1 {
                        // Limit to stoptime of next item, if any
                        vc.maximumDate = wl[i+1].stopTime
                    }
                }
            }
            TextViewLogger.log(statusView!, message: String("\n\(getString(NSDate())) segue input values: \(vc.minimumDate), \(vc.maximumDate)"))
        }

        if segue.identifier == "ExitVC" {
            // Nothing to prepare
        }

    }

    @IBAction func exitEditWork(unwindSegue: UIStoryboardSegue ) {
        TextViewLogger.log(statusView!, message: "\n\(getString(NSDate())) WorkListVC.exitEditWork")

        let vc = unwindSegue.sourceViewController as! TaskPickerEditWorkViewController

        if unwindSegue.identifier == "CancelEditWork" {
            // Do nothing
        }

        if unwindSegue.identifier == "OkEditWork" {

            if let moc = managedObjectContext,
                     s = session,
                     i = selectedWorkIndex {

                if let t = vc.taskToUse {
                    // Change task if this attribute was set
                    TextViewLogger.log(statusView!, message: "\nEditWork selected task=\(t.name)")
                    if let w = session?.getWork(i) {
                        w.task = t
                    }
                } else {
                    TextViewLogger.log(statusView!, message: "\nEditWork no task selected")
                }
                
                if let initialDate = vc.initialDate {
                    TextViewLogger.log(statusView!, message: "\nEditWork initial date=\(getString(initialDate))")
                    TextViewLogger.log(statusView!, message: "\nEditWork selected date=\(getString(vc.datePicker.date))")

                    if initialDate != vc.datePicker.date {
                        // The initial time was changed
                        if let w=s.getLastWork() {
                            if w.isOngoing() {
                                TextViewLogger.log(statusView!, message: "\nSelected time != initial time, work is ongoing, setting starttime")
                                s.setStartTime(moc, workIndex: s.work.count-1, desiredStartTime: vc.datePicker.date)
                            } else {
                                TextViewLogger.log(statusView!, message: "\nSelected time != initial time, work is not ongoing, setting stoptime")
                                s.setStopTime(moc, workIndex: s.work.count-1, desiredStopTime: vc.datePicker.date)
                            }
                        }
                    } else {
                        TextViewLogger.log(statusView!, message: "\nSelected time = initial time, don't set starttime")
                    }
                }

                TimePoliceModelUtils.save(moc)

                TextViewLogger.log(statusView!, message: "\n" + TimePoliceModelUtils.getSessionWork(s))
            }
            
            workListTableView.reloadData()
        }


        if unwindSegue.identifier == "OkEditWork" {

            if let moc = managedObjectContext,
                 i = selectedWorkIndex
                where unwindSegue.identifier == "DeleteWork" {

                let fillEmptySpaceWith = vc.fillEmptySpaceWith.selectedSegmentIndex
                switch fillEmptySpaceWith {
                    case 0: // Nothing, deleteWork
                        println("Fill with nothing")
                        session?.deleteWork(moc, workIndex: i)
                    case 1: // Previous item, deleteNextWorkAndAlignStop
                        println("Fill with previous")
                        session?.deleteNextWorkAndAlignStop(moc, workIndex: i-1)
                    case 2: // Next item, deletePreviousWorkAndAlignStart
                        println("Fill with next")
                        session?.deletePreviousWorkAndAlignStart(moc, workIndex: i+1)
                    default: // Not handled
                        println("Not handled")
                }
                workListTableView.reloadData()
            }
        }

    }



}
