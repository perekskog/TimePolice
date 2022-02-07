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
    var numberOfSessions: Int? {get set}
    var delegate: TaskEntryCreatorDelegate? { get set }
}

protocol TaskEntryCreatorDelegate {
    func taskEntryCreator(_ taskEntryCreator: TaskEntryCreator, willViewSessionIndex: Int)
}

class TaskEntryCreatorBase:
        UIViewController,
        AppLoggerDataSource,
        TaskEntryCreator {

    var session: Session?
    var sessionIndex: Int?
    var numberOfSessions: Int?
    var delegate: TaskEntryCreatorDelegate?

    var selectedTaskEntryIndex: Int?


	//--------------------------------------------------------
    // TaskEntryCreatorBase - Lazy properties
    //--------------------------------------------------------

    lazy var moc : NSManagedObjectContext = {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()

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
        appLog.log(logger, logtype: .viewLifecycle, message: "(...Base) viewDidLoad")
        
        // Do not extend to full screen
        self.edgesForExtendedLayout = UIRectEdge()
    }



    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "(...Base) viewWillAppear")
        
        guard let i = sessionIndex  else {
            appLog.log(logger, logtype: .guard, message: "(...Base) guard fail in viewWillAppear")
            return
        }

        delegate?.taskEntryCreator(self, willViewSessionIndex: i)
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "(...Base) viewDidAppear")
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "(...Base) viewWillDisappear")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "(...Base) viewDidDisappear")
    }



    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        appLog.log(logger, logtype: .viewLifecycle, message: "(...Base) viewWillLayoutSubviews")
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appLog.log(logger, logtype: .viewLifecycle, message: "(...Base) viewDidLayoutSubviews")
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        appLog.log(logger, logtype: .viewLifecycle, message: "(...Base) didReceiveMemoryWarning")
    }
    



    //---------------------------------------------
    // TaskEntryCreatorBase - Segue handling
    //---------------------------------------------


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        appLog.log(logger, logtype: .enterExit) { "(...Base) prepareForSegue(\(String(describing: segue.identifier)))" }

        if segue.identifier == "ExitVC" {
            appLog.log(logger, logtype: .debug, message: "(...Base) Handle ExitVC... Do nothing")
            // Nothing to prepare
        }


        if segue.identifier == "UseTemplate" {
            appLog.log(logger, logtype: .debug, message: "(...Base) Handle UseTemplate...")

            guard let nvc = segue.destination as? UINavigationController,
                    let vc = nvc.topViewController as? TaskEntryTemplateSelectVC else {
                return
            }
            if let s = session {
                vc.templates = getTemplates(s.name)
            }
        }

        if segue.identifier == "EditTaskEntry" {
            appLog.log(logger, logtype: .debug, message: "(...Base) Handle EditTaskEntry...")

            guard let nvc = segue.destination as? UINavigationController,
                    let vc = nvc.topViewController as? TaskEntryPropVC,
                    let s = session,
                    let tl = s.tasks.array as? [Task],
                    let wl = s.taskEntries.array as? [TaskEntry],
                    let i = selectedTaskEntryIndex else {
                appLog.log(logger, logtype: .guard, message: "(...Base) guard fail in prepareForSegue")
               return
            }
            appLog.log(logger, logtype: .enterExit) { TimePoliceModelUtils.getSessionTaskEntries(s) }

            vc.taskList = tl

            vc.taskEntryTemplate = wl[i]

            // Never set any time into the future
            vc.maximumDate = Date()

            if i > 0 {
                appLog.log(logger, logtype: .debug, message:"\(wl[i-1].startTime.timeIntervalSince1970)")
                appLog.log(logger, logtype: .debug, message:"\(wl[i-1].stopTime.timeIntervalSince1970)")
                appLog.log(logger, logtype: .debug, message:"\(wl[i].startTime.timeIntervalSince1970)")
// te.startTime.timeIntervalSince(previousTaskEntry.stopTime) < 0.5
                // Limit to starttime of previous item, if any
            //if wl[i-1].stopTime == wl[i].startTime {
                if wl[i].startTime.timeIntervalSince(wl[i-1].stopTime) < 0.5 {
                    // No gap => limit to previous item's starttime
                    vc.minimumDate = wl[i-1].startTime
                } else {
                    // A gap => limit to previous item's stoptime
                    vc.minimumDate = wl[i-1].stopTime
                }
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

    @IBAction func exitUseTemplate(_ unwindSegue: UIStoryboardSegue ) {
        appLog.log(logger, logtype: .enterExit, message: "(...Base) exitUseTemplate(unwindsegue=\(String(describing: unwindSegue.identifier)))")

        let vc = unwindSegue.source as! TaskEntryTemplateSelectVC


        if unwindSegue.identifier == "CancelUseTemplate" {
            appLog.log(logger, logtype: .debug, message: "(...Base) Handle CancelUseTemplate... Do nothing")
            // Do nothing
        }

        if unwindSegue.identifier == "DoneUseTemplate" {
            appLog.log(logger, logtype: .debug, message: "(...Base) Handle DoneUseTemplate")
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
                s.version = session.version
                s.properties = session.properties
                s.src = session.src
                
                TimePoliceModelUtils.save(moc)
                appLog.log(logger, logtype: .debug) { TimePoliceModelUtils.getSessionTaskEntries(s) }
                redrawAfterSegue()

            }

        }


    }
        
    @IBAction func exitTaskEntryProp(_ unwindSegue: UIStoryboardSegue ) {
        appLog.log(logger, logtype: .enterExit, message: "e(...Base) exitTaskEntryProp(unwindsegue=\(String(describing: unwindSegue.identifier)))")

        let vc = unwindSegue.source as! TaskEntryPropVC

        if unwindSegue.identifier == "CancelTaskEntry" {
            appLog.log(logger, logtype: .debug, message: "(...Base) Handle CancelTaskEntry... Do nothing")
            // Do nothing
        }

        if unwindSegue.identifier == "SaveTaskEntry" {
            appLog.log(logger, logtype: .debug, message: "(...Base) Handle SaveTaskEntry")

            guard let s = session,
                     let i = selectedTaskEntryIndex  else {
                appLog.log(logger, logtype: .guard, message: "(...Base) guard fail in exitTaskEntryProp SaveTaskEntry")
                return
            }

            defer {
                TimePoliceModelUtils.save(moc)
                appLog.log(logger, logtype: .debug) { TimePoliceModelUtils.getSessionTaskEntries(s) }
                redrawAfterSegue()
            }

            if let t = vc.taskToUse {
                // Change task if this attribute was set
                appLog.log(logger, logtype: .debug, message: "(...Base) EditTaskEntry selected task=\(t.name)")
                if let w = s.getTaskEntry(i) {
                    //w.task = t
                    w.changeTaskTo(t)
                }
            } else {
                appLog.log(logger, logtype: .debug, message: "(...Base) EditTaskEntry no task selected")
            }

            // Default: First adjust starttime, then adjust stoptime.
            var startTimeFirst = true

            // If starttime has been set to a later time than the original stoptime,
            // it may be so that both start- and stoptime has been changed.
            // In this case, adjust stoptime first, then starttime.
            if let initialStopDate = vc.initialStopDate {
                if vc.datePickerStart.date.compare(initialStopDate) == .orderedDescending {
                    startTimeFirst = false
                }
            }

            if startTimeFirst {
                appLog.log(logger, logtype: .debug, message: "(...Base) Will adjust starttime first")

                adjustStartTime(s, i:i, moc: moc, vc: vc)
                adjustStopTime(s, i:i, moc:moc, vc:vc)
            } else {
                appLog.log(logger, logtype: .debug, message: "(...Base) Will adjust stoptime first")

                adjustStopTime(s, i:i, moc:moc, vc:vc)
                adjustStartTime(s, i:i, moc:moc, vc:vc)
            }

        }

        if unwindSegue.identifier == "DeleteTaskEntry" {
            appLog.log(logger, logtype: .debug, message: "(...Base) Handle DeleteTaskEntry")

            guard let s = session,
                     let i = selectedTaskEntryIndex,
                     let delete = vc.delete else {
                appLog.log(logger, logtype: .guard, message: "(...Base) guard fail in exitTaskEntryProp DeleteTaskEntry")
                return
            }

            defer {
                TimePoliceModelUtils.save(moc)
                appLog.log(logger, logtype: .debug) { TimePoliceModelUtils.getSessionTaskEntries(s) }
                redrawAfterSegue()
            }

            switch delete {
            case .fillWithNone: // Nothing, delete task entry
                appLog.log(logger, logtype: .debug, message: "(...Base) Fill with nothing")
                s.deleteTaskEntry(moc, taskEntryIndex: i)
            case .fillWithPrevious: // Previous item, deleteNextTaskEntryAndAlignStop
                appLog.log(logger, logtype: .debug, message: "(...Base) Fill with previous")
                s.deleteNextTaskEntryAndAlignStop(moc, taskEntryIndex: i-1)
            case .fillWithNext: // Next item, deletePreviousTaskEntryAndAlignStart
                appLog.log(logger, logtype: .debug, message: "(...Base) Fill with next")
                s.deletePreviousTaskEntryAndAlignStart(moc, taskEntryIndex: i+1)
            }
        }

        if unwindSegue.identifier == "InsertNewTaskEntry" {

            appLog.log(logger, logtype: .debug, message: "(...Base) Handle InsertNewTaskEntry")

            guard let s = session,
                     let i = selectedTaskEntryIndex,
                     let insert = vc.insert else {
                appLog.log(logger, logtype: .guard, message: "(...Base) guard fail in exitTaskEntryProp InsertNewTaskEntry")
                return
            }

            defer {
                TimePoliceModelUtils.save(moc)
                appLog.log(logger, logtype: .debug) { TimePoliceModelUtils.getSessionTaskEntries(s) }
                redrawAfterSegue()
            }

            switch insert {
            case .insertNewBeforeThis:
                appLog.log(logger, logtype: .debug, message: "(...Base) Insert new before this (index=\(i))")
                _ = TaskEntry.createInMOCBeforeIndex(moc, session: s, index: i)
            case .insertNewAfterThis:
                appLog.log(logger, logtype: .debug, message: "(...Base) Insert new after this (index=\(i))")
                _ = TaskEntry.createInMOCAfterIndex(moc, session: s, index: i)
            }

        }        
    }
    
    func adjustStartTime(_ s: Session, i: Int, moc: NSManagedObjectContext, vc: TaskEntryPropVC) {
        if let initialDate = vc.initialStartDate {
            appLog.log(logger, logtype: .debug, message: "(...Base) EditTaskEntry initial start date=\(UtilitiesDate.getString(initialDate))")
            appLog.log(logger, logtype: .debug, message: "(...Base) EditTaskEntry selected start date=\(UtilitiesDate.getString(vc.datePickerStart.date))")
            
            if initialDate != vc.datePickerStart.date {
                // The initial starttime was changed
                appLog.log(logger, logtype: .debug, message: "(...Base) Selected starttime != initial starttime, setting starttime")
                s.setStartTime(moc, taskEntryIndex: i, desiredStartTime: vc.datePickerStart.date)
            } else {
                appLog.log(logger, logtype: .debug, message: "(...Base) Selected starttime = initial starttime, don't set starttime")
            }
        }
    }
    
    func adjustStopTime(_ s: Session, i: Int, moc: NSManagedObjectContext, vc: TaskEntryPropVC) {
        if let initialDate = vc.initialStopDate {
            appLog.log(logger, logtype: .debug, message: "(...Base) EditTaskEntry initial stop date=\(UtilitiesDate.getString(initialDate))")
            appLog.log(logger, logtype: .debug, message: "(...Base) EditTaskEntry selected stop date=\(UtilitiesDate.getString(vc.datePickerStop.date))")
            
            if initialDate != vc.datePickerStop.date {
                // The initial stoptime was changed
                appLog.log(logger, logtype: .debug, message: "(...Base) Selected stoptime != initial stoptime, setting stoptime")
                s.setStopTime(moc, taskEntryIndex: i, desiredStopTime: vc.datePickerStop.date)
            } else {
                appLog.log(logger, logtype: .debug, message: "(...Base) Selected stoptime = initial stoptime, don't set stoptime")
            }
        }
        
    }


    func redrawAfterSegue() {
        // DO nothing here
    }

    func getTemplates(_ project: String) -> [Session] {
        appLog.log(logger, logtype: .enterExit, message: "getTemplates")

        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Session")
            var templateSessions: [Session] = []
            if let tmpSessions = try moc.fetch(fetchRequest) as? [Session] {
                for session in tmpSessions.sorted(by: { (s1:Session, s2:Session) -> Bool in
                    if s1.name != s2.name {
                        return s1.name < s2.name
                    } else {
                        return s1.version < s2.version
                    }
                    }) {
                    if session.project.name == templateProjectName &&
                        session.name == project {
                        templateSessions.append(session)
                    }
                }
            }
            return templateSessions

        } catch {
            return []
        }
    }


}
