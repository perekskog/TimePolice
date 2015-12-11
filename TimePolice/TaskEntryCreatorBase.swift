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

protocol TaskEntryCreator {
    var session: Session? { get set }
    var sessionIndex: Int? { get set }
    var delegate: TaskEntryCreatorDelegate? { get set }
}

protocol TaskEntryCreatorDelegate {
    func taskEntryCreator(taskEntryCreator: TaskEntryCreator, willViewSessionIndex: Int)
}

class TaskEntryCreatorBase:
        UIViewController,
        AppLoggerDataSource,
        TaskEntryCreator {

    var session: Session?
    var sessionIndex: Int?
    var delegate: TaskEntryCreatorDelegate?

    var selectedWorkIndex: Int?


	//--------------------------------------------------------
    // TaskEntryCreatorBase - Lazy properties
    //--------------------------------------------------------

    lazy var moc : NSManagedObjectContext = {

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()

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
    // TaskEntryCreatorBase - AppLoggerDataSource
    //---------------------------------------------

    func getLogDomain() -> String {
        return "TaskEntryCreatorBase"
    }

    
    //---------------------------------------------
    // TaskEntryCreatorBase - View lifecycle
    //---------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        logger.datasource = self
        appLog.log(logger, logtype: .ViewLifecycle, message: "(...Base) viewDidLoad")
        
        // Do not extend to full screen
        self.edgesForExtendedLayout = .None
    }



    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "(...Base) viewWillAppear")
        
        guard let i = sessionIndex  else {
            appLog.log(logger, logtype: .Guard, message: "(...Base) guard fail in viewWillAppear")
            return
        }

        delegate?.taskEntryCreator(self, willViewSessionIndex: i)
    }


    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "(...Base) viewDidAppear")
    }


    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "(...Base) viewWillDisappear")
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "(...Base) viewDidDisappear")
    }



    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        appLog.log(logger, logtype: .ViewLifecycle, message: "(...Base) viewWillLayoutSubviews")
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appLog.log(logger, logtype: .ViewLifecycle, message: "(...Base) viewDidLayoutSubviews")
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        appLog.log(logger, logtype: .ViewLifecycle, message: "(...Base) didReceiveMemoryWarning")
    }
    



    //---------------------------------------------
    // TaskEntryCreatorBase - Segue handling
    //---------------------------------------------


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        appLog.log(logger, logtype: .EnterExit) { "(...Base) prepareForSegue(\(segue.identifier))" }

        if segue.identifier == "ExitVC" {
            appLog.log(logger, logtype: .Debug, message: "(...Base) Handle ExitVC... Do nothing")
            // Nothing to prepare
        }


        if segue.identifier == "UseTemplate" {
            appLog.log(logger, logtype: .Debug, message: "(...Base) Handle UseTemplate... Do nothing")

            guard let nvc = segue.destinationViewController as? UINavigationController,
                    let vc = nvc.topViewController as? TaskEntryTemplateSelectVC,
                    let projects = Project.findInMOC(moc, name: "Templates")
                    where projects.count >= 1 else {
                return
            }
            let p = projects[0]
            vc.templates = p.sessions.array as? [Session]
        }

        if segue.identifier == "EditTaskEntry" {
            appLog.log(logger, logtype: .Debug, message: "(...Base) Handle EditTaskEntry... Do nothing")

            guard let nvc = segue.destinationViewController as? UINavigationController,
                    let vc = nvc.topViewController as? TaskEntryPropVC,
                    let s = session,
                    let tl = s.tasks.array as? [Task],
                    let wl = s.work.array as? [Work],
                    let i = selectedWorkIndex else {
                appLog.log(logger, logtype: .Guard, message: "(...Base) guard fail in prepareForSegue")
               return
            }
            appLog.log(logger, logtype: .EnterExit) { TimePoliceModelUtils.getSessionWork(s) }

            vc.taskList = tl

            vc.taskEntryTemplate = wl[i]

            // Never set any time into the future
            vc.maximumDate = NSDate()

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
            if i == 0 {
                vc.isFirst = true
            } else {
                vc.isFirst = false
            }
            if i == wl.count-1 {
                vc.isLast = true
            } else {
                vc.isLast = false
            }
        }

    }
    @IBAction func exitUseTemplate(unwindSegue: UIStoryboardSegue ) {
        appLog.log(logger, logtype: .EnterExit, message: "(...Base) exitUseTemplate(unwindsegue=\(unwindSegue.identifier))")

        let vc = unwindSegue.sourceViewController as! TaskEntryTemplateSelectVC


        if unwindSegue.identifier == "CancelUseTemplate" {
            appLog.log(logger, logtype: .Debug, message: "(...Base) Handle CancelUseTemplate... Do nothing")
            // Do nothing
        }

        if unwindSegue.identifier == "DoneUseTemplate" {
            appLog.log(logger, logtype: .Debug, message: "(...Base) Handle DoneUseTemplate")
            // Replace tasks for current session
            guard let i = vc.templateIndexSelected,
                let session = vc.templates?[i] else {
                    return
            }

            if let s = self.session {
                //s.tasks = session.tasks
                if let tasks = session.tasks.array as? [Task] {
                    s.replaceTasksWith(tasks)
                }

                // Use new properties and src
                s.properties = session.properties
                s.src = session.src
                
                TimePoliceModelUtils.save(moc)
                appLog.log(logger, logtype: .Debug) { TimePoliceModelUtils.getSessionWork(s) }
                redrawAfterSegue()

            }

        }


    }
        
    @IBAction func exitTaskEntryProp(unwindSegue: UIStoryboardSegue ) {
        appLog.log(logger, logtype: .EnterExit, message: "e(...Base) exitTaskEntryProp(unwindsegue=\(unwindSegue.identifier))")

        let vc = unwindSegue.sourceViewController as! TaskEntryPropVC

        if unwindSegue.identifier == "CancelTaskEntry" {
            appLog.log(logger, logtype: .Debug, message: "(...Base) Handle CancelTaskEntry... Do nothing")
            // Do nothing
        }

        if unwindSegue.identifier == "SaveTaskEntry" {
            appLog.log(logger, logtype: .Debug, message: "(...Base) Handle SaveTaskEntry")

            guard let s = session,
                     i = selectedWorkIndex  else {
                appLog.log(logger, logtype: .Guard, message: "(...Base) guard fail in exitTaskEntryProp SaveTaskEntry")
                return
            }

            defer {
                TimePoliceModelUtils.save(moc)
                appLog.log(logger, logtype: .Debug) { TimePoliceModelUtils.getSessionWork(s) }
                redrawAfterSegue()
            }

            if let t = vc.taskToUse {
                // Change task if this attribute was set
                appLog.log(logger, logtype: .Debug, message: "(...Base) EditWork selected task=\(t.name)")
                if let w = s.getWork(i) {
                    w.task = t
                }
            } else {
                appLog.log(logger, logtype: .Debug, message: "(...Base) EditWork no task selected")
            }

            // Default: First adjust starttime, then adjust stoptime.
            var startTimeFirst = true

            // If starttime has been set to a later time than the original stoptime,
            // it may be so that both start- and stoptime has been changed.
            // In this case, adjust stoptime first, then starttime.
            if let initialStopDate = vc.initialStopDate {
                if vc.datePickerStart.date.compare(initialStopDate) == .OrderedDescending {
                    startTimeFirst = false
                }
            }

            if startTimeFirst {
                appLog.log(logger, logtype: .Debug, message: "(...Base) Will adjust starttime first")

                adjustStartTime(s, i:i, moc: moc, vc: vc)
                adjustStopTime(s, i:i, moc:moc, vc:vc)
            } else {
                appLog.log(logger, logtype: .Debug, message: "(...Base) Will adjust stoptime first")

                adjustStopTime(s, i:i, moc:moc, vc:vc)
                adjustStartTime(s, i:i, moc:moc, vc:vc)
            }

        }

        if unwindSegue.identifier == "DeleteTaskEntry" {
            appLog.log(logger, logtype: .Debug, message: "(...Base) Handle DeleteTaskEntry")

            guard let s = session,
                     i = selectedWorkIndex,
                     delete = vc.delete else {
                appLog.log(logger, logtype: .Guard, message: "(...Base) guard fail in exitTaskEntryProp DeleteTaskEntry")
                return
            }

            defer {
                TimePoliceModelUtils.save(moc)
                appLog.log(logger, logtype: .Debug) { TimePoliceModelUtils.getSessionWork(s) }
                redrawAfterSegue()
            }

            switch delete {
            case .FillWithNone: // Nothing, deleteWork
                appLog.log(logger, logtype: .Debug, message: "(...Base) Fill with nothing")
                s.deleteWork(moc, workIndex: i)
            case .FillWithPrevious: // Previous item, deleteNextWorkAndAlignStop
                appLog.log(logger, logtype: .Debug, message: "(...Base) Fill with previous")
                s.deleteNextWorkAndAlignStop(moc, workIndex: i-1)
            case .FillWithNext: // Next item, deletePreviousWorkAndAlignStart
                appLog.log(logger, logtype: .Debug, message: "(...Base) Fill with next")
                s.deletePreviousWorkAndAlignStart(moc, workIndex: i+1)
            }
        }

        if unwindSegue.identifier == "InsertNewTaskEntry" {

            appLog.log(logger, logtype: .Debug, message: "(...Base) Handle InsertNewTaskEntry")

            guard let s = session,
                     i = selectedWorkIndex,
                     insert = vc.insert else {
                appLog.log(logger, logtype: .Guard, message: "(...Base) guard fail in exitTaskEntryProp InsertNewTaskEntry")
                return
            }

            defer {
                TimePoliceModelUtils.save(moc)
                appLog.log(logger, logtype: .Debug) { TimePoliceModelUtils.getSessionWork(s) }
                redrawAfterSegue()
            }

            switch insert {
            case .InsertNewBeforeThis:
                appLog.log(logger, logtype: .Debug, message: "(...Base) Insert new before this (index=\(i))")
                Work.createInMOCBeforeIndex(moc, session: s, index: i)
            case .InsertNewAfterThis:
                appLog.log(logger, logtype: .Debug, message: "(...Base) Insert new after this (index=\(i))")
                Work.createInMOCAfterIndex(moc, session: s, index: i)
            }

        }        
    }
    
    func adjustStartTime(s: Session, i: Int, moc: NSManagedObjectContext, vc: TaskEntryPropVC) {
        if let initialDate = vc.initialStartDate {
            appLog.log(logger, logtype: .Debug, message: "(...Base) EditWork initial start date=\(UtilitiesDate.getString(initialDate))")
            appLog.log(logger, logtype: .Debug, message: "(...Base) EditWork selected start date=\(UtilitiesDate.getString(vc.datePickerStart.date))")
            
            if initialDate != vc.datePickerStart.date {
                // The initial starttime was changed
                appLog.log(logger, logtype: .Debug, message: "(...Base) Selected starttime != initial starttime, setting starttime")
                s.setStartTime(moc, workIndex: i, desiredStartTime: vc.datePickerStart.date)
            } else {
                appLog.log(logger, logtype: .Debug, message: "(...Base) Selected starttime = initial starttime, don't set starttime")
            }
        }
    }
    
    func adjustStopTime(s: Session, i: Int, moc: NSManagedObjectContext, vc: TaskEntryPropVC) {
        if let initialDate = vc.initialStopDate {
            appLog.log(logger, logtype: .Debug, message: "(...Base) EditWork initial stop date=\(UtilitiesDate.getString(initialDate))")
            appLog.log(logger, logtype: .Debug, message: "(...Base) EditWork selected stop date=\(UtilitiesDate.getString(vc.datePickerStop.date))")
            
            if initialDate != vc.datePickerStop.date {
                // The initial stoptime was changed
                appLog.log(logger, logtype: .Debug, message: "(...Base) Selected stoptime != initial stoptime, setting stoptime")
                s.setStopTime(moc, workIndex: i, desiredStopTime: vc.datePickerStop.date)
            } else {
                appLog.log(logger, logtype: .Debug, message: "(...Base) Selected stoptime = initial stoptime, don't set stoptime")
            }
        }
        
    }


    func redrawAfterSegue() {
        // DO nothing here
    }


}