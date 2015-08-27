//
//  TaskEntryCreatorBase.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-04-21.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

/* 

TODO

*/

import UIKit
import CoreData

class TaskEntryCreatorBase:
        UIViewController {

    var session: Session?

    var selectedWorkIndex: Int?

	//--------------------------------------------------------
    // TaskEntryCreatorBase - Lazy properties
    //--------------------------------------------------------

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

    lazy var logger: AppLogger = {
        let logger = MultiLog()
        //      logger.logger1 = TextViewLog(textview: statusView!, locator: "WorkListVC")
        logger.logger2 = StringLog(locator: self.getLogDomain())
        logger.logger3 = ApplogLog(locator: self.getLogDomain())
        
        return logger
    }()

    func getLogDomain() -> String {
        return "TaskEntryCreatorBase"
    }

    
    //---------------------------------------------
    // TaskEntryCreatorBase - View lifecycle
    //---------------------------------------------

    // Just once:
    override func viewDidLoad() {
        super.viewDidLoad()        
        appLog.log(logger, logtype: .iOS, message: "viewDidLoad")
    }



    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger, logtype: .iOS, message: "viewWillAppear")
    }


    // Both of these, maybe several times:
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        appLog.log(logger, logtype: .iOS, message: "viewWillLayoutSubviews")
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appLog.log(logger, logtype: .iOS, message: "viewDidLayoutSubviews")
    }


    // Parent: viewDidDisappear, then:
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        appLog.log(logger, logtype: .iOS, message: "viewDidAppear")
    }


    // ...


    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        appLog.log(logger, logtype: .iOS, message: "viewWillDisappear")
    }

    // Parent: viewWillAppear, then:
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        appLog.log(logger, logtype: .iOS, message: "viewDidDisappear")
    }
    // ...then: Child: viewDidAppear




    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        appLog.log(logger, logtype: .iOS, message: "didReceiveMemoryWarning")
    }
    



    //---------------------------------------------
    // TaskEntryCreatorBase - Segue handling
    //---------------------------------------------


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        appLog.log(logger, logtype: .EnterExit) { "prepareForSegue(\(segue.identifier))" }

        if segue.identifier == "EditTaskEntry" {
            if let nvc = segue.destinationViewController as? UINavigationController,
                vc = nvc.topViewController as? TaskEntryPropVC {
                    if let s = session,
                    tl = s.tasks.array as? [Task] {
                        appLog.log(logger, logtype: .EnterExit) { TimePoliceModelUtils.getSessionWork(s) }

                        vc.taskList = tl

                        // Never set any time into the future
                        vc.maximumDate = NSDate()
                        if let wl = s.work.array as? [Work],
                           i = selectedWorkIndex {
                            vc.taskEntryTemplate = wl[i]
                            if i > 0 {
                                // Limit to starttime of previous item, if any
                                vc.minimumDate = wl[i-1].startTime
                            }
                            if i < wl.count-1 && !wl[i+1].isOngoing() {
                                // Limit to stoptime of next item, if any
                                vc.maximumDate = wl[i+1].stopTime
                            }
                            if vc.taskEntryTemplate!.isOngoing() {
                                vc.isOngoing = true
                            } else {
                                vc.isOngoing = false
                            }
                        }

                    }
            }
        }

        if segue.identifier == "ExitVC" {
            // Nothing to prepare
        }

    }

    @IBAction func exitTaskEntryProp(unwindSegue: UIStoryboardSegue ) {
        appLog.log(logger, logtype: .EnterExit, message: "exitEditWork(unwindsegue=\(unwindSegue.identifier))")

        let vc = unwindSegue.sourceViewController as! TaskEntryPropVC

        if unwindSegue.identifier == "CancelTaskEntry" {
            appLog.log(logger, logtype: .Debug, message: "Handle CancelTaskEntry... Do nothing")
            // Do nothing
        }

        if unwindSegue.identifier == "SaveTaskEntry" {
            appLog.log(logger, logtype: .Debug, message: "Handle SaveTaskEntry")

            if let moc = managedObjectContext,
                     s = session,
                     i = selectedWorkIndex {

                if let t = vc.taskToUse {
                    // Change task if this attribute was set
                    appLog.log(logger, logtype: .Debug, message: "EditWork selected task=\(t.name)")
                    s.getWork(i)!.task = t
                } else {
                    appLog.log(logger, logtype: .Debug, message: "EditWork no task selected")
                }
                
                if let initialDate = vc.initialStartDate {
                    appLog.log(logger, logtype: .Debug, message: "EditWork initial start date=\(getString(initialDate))")
                    appLog.log(logger, logtype: .Debug, message: "EditWork selected start date=\(getString(vc.datePickerStart.date))")

                    if initialDate != vc.datePickerStart.date {
                        // The initial starttime was changed
                        appLog.log(logger, logtype: .Debug, message: "Selected starttime != initial starttime, setting starttime")
                        s.setStartTime(moc, workIndex: i, desiredStartTime: vc.datePickerStart.date)
                    } else {
                        appLog.log(logger, logtype: .Debug, message: "Selected starttime = initial starttime, don't set starttime")
                    }
                }

                if let initialDate = vc.initialStopDate {
                    appLog.log(logger, logtype: .Debug, message: "EditWork initial stop date=\(getString(initialDate))")
                    appLog.log(logger, logtype: .Debug, message: "EditWork selected stop date=\(getString(vc.datePickerStop.date))")

                    if initialDate != vc.datePickerStop.date {
                        // The initial stoptime was changed
                        appLog.log(logger, logtype: .Debug, message: "Selected stoptime != initial stoptime, setting stoptime")
                        s.setStopTime(moc, workIndex: i, desiredStopTime: vc.datePickerStop.date)
                    } else {
                        appLog.log(logger, logtype: .Debug, message: "Selected stoptime = initial stoptime, don't set stoptime")
                    }
                }

                TimePoliceModelUtils.save(moc)

                appLog.log(logger, logtype: .Debug) { TimePoliceModelUtils.getSessionWork(s) }
            }
            redrawAfterSegue()
        }


        if unwindSegue.identifier == "DeleteTaskEntry" {
            appLog.log(logger, logtype: .Debug, message: "Handle DeleteTaskEntry")

            if let moc = managedObjectContext,
                     s = session,
                     i = selectedWorkIndex {

                if let delete = vc.delete {
                    switch delete {
                    case .FillWithNone: // Nothing, deleteWork
                        appLog.log(logger, logtype: .Debug, message: "Fill with nothing")
                        s.deleteWork(moc, workIndex: i)
                    case .FillWithPrevious: // Previous item, deleteNextWorkAndAlignStop
                        appLog.log(logger, logtype: .Debug, message: "Fill with previous")
                        s.deleteNextWorkAndAlignStop(moc, workIndex: i-1)
                    case .FillWithNext: // Next item, deletePreviousWorkAndAlignStart
                        appLog.log(logger, logtype: .Debug, message: "Fill with next")
                        s.deletePreviousWorkAndAlignStart(moc, workIndex: i+1)
                    default: // Not handled
                        appLog.log(logger, logtype: .Debug, message: "Not handled")
                    }
                }
                TimePoliceModelUtils.save(moc)
                appLog.log(logger, logtype: .Debug) { TimePoliceModelUtils.getSessionWork(s) }

                redrawAfterSegue()
            }

        }
        
    }

    func redrawAfterSegue() {
        // DO nothing here
    }


}