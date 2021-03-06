//
//  MainExportVC.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-11-16.
//  Copyright © 2015 Per Ekskog. All rights reserved.
//

import UIKit
import CoreData

class MainExportVC: UIViewController,
    AppLoggerDataSource {


    @IBOutlet var exitButton: UIButton!
    @IBOutlet var exportLabel: UILabel!
    @IBOutlet var exportInstructionLabel: UILabel!
    @IBOutlet var sessionSelectionControl: UISegmentedControl!
    @IBOutlet var sessionSummaryButton: UIButton!
    @IBOutlet var sessionDetailsButton: UIButton!
    @IBOutlet var dataStructuresButton: UIButton!
    @IBOutlet var applogButton: UIButton!

    let theme = BlackGreenTheme()

    //---------------------------------------
    // MainExportVC - Lazy properties
    //---------------------------------------

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
    // MainExportVC - AppLoggerDataSource
    //---------------------------------------------

    func getLogDomain() -> String {
        return "MainExportVC"
    }



    //---------------------------------------------
    // MainExportVC - View lifecycle
    //---------------------------------------------

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewWillAppear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewWillDisappear")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidAppear")

        let (shouldPopupAlert, message) = TimePoliceModelUtils.verifyConstraints(moc)
        if shouldPopupAlert == true {
            let alertController = TimePoliceModelUtils.getConsistencyAlert(message, moc: moc)
            present(alertController, animated: true, completion: nil)
        }

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidDisappear")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        appLog.log(logger, logtype: .viewLifecycle, message: "viewWillLayoutSubviews")

        let width = self.view.frame.width
        let height = self.view.frame.height

        exitButton.frame.size.height = CGFloat(minimumComponentHeight)

        var textRect = CGRect(x: 0, y: height/4, width: width, height: 50)
        exportLabel.frame = textRect

        textRect.origin.y += max(height/13, CGFloat(minimumComponentSpacing))
        textRect.origin.x = width*0.1
        textRect.size.width = width * 0.8
        exportInstructionLabel.frame = textRect

        textRect.origin.y += height/5
        sessionSelectionControl.frame.origin.y = textRect.origin.y
        sessionSelectionControl.frame.origin.x = width*0.15
        sessionSelectionControl.frame.size.width = width*0.7
        sessionSelectionControl.frame.size.height = CGFloat(segmentControlHeight)
        textRect.origin.y += max(height/15, CGFloat(minimumComponentSpacing))
        sessionSummaryButton.frame = textRect
        textRect.origin.y += max(height/15, CGFloat(minimumComponentSpacing))
        sessionDetailsButton.frame = textRect

        dataStructuresButton.frame.origin.y = height - dataStructuresButton.frame.size.height
        dataStructuresButton.frame.origin.x = width*0.05

        applogButton.frame.origin.y = dataStructuresButton.frame.origin.y
        applogButton.frame.origin.x = width - applogButton.frame.size.width - width*0.05
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidLayoutSubviews")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidLoad")

        (self.view as! TimePoliceBGView).theme = theme

        exitButton.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(themeBigTextSize))

        exportLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(textTitleSize))
        exportInstructionLabel.font = UIFont.italicSystemFont(ofSize: CGFloat(textBodySize))

        sessionSelectionControl.removeAllSegments()
        sessionSelectionControl.insertSegment(withTitle: "Active", at: 0, animated: false)
        sessionSelectionControl.insertSegment(withTitle: "Archived", at: 0, animated: false)
        sessionSelectionControl.insertSegment(withTitle: "All", at: 0, animated: false)
        sessionSelectionControl.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        sessionSelectionControl.tintColor = UIColor(red:0.1, green:0.6, blue:0.1, alpha: 1.0)
        sessionSelectionControl.selectedSegmentIndex = 0


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        appLog.log(logger, logtype: .viewLifecycle, message: "didReceiveMemoryWarning")
    }

    //---------------------------------------------
    // MainExportVC - GUI actions
    //---------------------------------------------

    @IBAction func exit(_ sender: UIButton) {
        appLog.log(logger, logtype: .enterExit, message: "exit")
        appLog.log(logger, logtype: .guiAction, message: "exit")

        performSegue(withIdentifier: "Exit", sender: self)
    }



    //----------------------------------------
    // MainExportVC - Buttons
    //----------------------------------------

    @IBAction func dumpCoreData(_ sender: UIButton) {
        appLog.log(logger, logtype: .enterExit, message: "dumpAllCoreData")
        appLog.log(logger, logtype: .guiAction, message: "dumpCoreData")

        let s = MainExportVC.dumpAllData(moc)
        print(s)
        UIPasteboard.general.string = s
    }

    @IBAction func dumpApplog(_ sender: UIButton) {
        appLog.log(logger, logtype: .enterExit, message: "dumpApplog")
        appLog.log(logger, logtype: .guiAction, message: "dumpApplog")

        let s = appLog.logString
        print(s)
        UIPasteboard.general.string = s
    }

    @IBAction func dumpSessionDetails(_ sender: UIButton) {
        appLog.log(logger, logtype: .enterExit, message: "dumpSessionDetails")
        appLog.log(logger, logtype: .guiAction, message: "dumpSessionDetails")

        /*
        for each project p {
            projectDetails = [session: ([TaskEntry], [Int])
            var maxLength = 0
            for each session in p {
                taskEntries = session.taskEntries
                gap2taskEntry = TaskEntryCreatorAddToList::getGap2TaskEntry(taskEntries)
                projectDetails[session] = (taskEntries, gap2taskEntry)
                maxLength = max(maxLength, gap2taskEntry.count)
                print session heading
            }
            for row = 0...maxLength {
                for each session in projectDetails {
                    if entry exists for this session: print entry
                    else print "\t"
                }
            }
        }
        */

        guard let projects = Project.findInMOC(moc) else {
            return
        }

        var str = ""

        for project in projects.sorted(by: { $0.created.compare($1.created) == .orderedAscending }) {
            if project.name == templateProjectName {
                continue
            }

            var heading = ""
            var maxNumberOfTaskEntries = 0
            var projectDetails: [Session: ([TaskEntry], [Int])] = [:]
            var finished: [Session: Bool] = [:]

            for session in project.sessions {
                if let s = session as? Session {
                    var includeSession = true
                    if s.archived==true && sessionSelectionControl.selectedSegmentIndex==2
                    || s.archived==false && sessionSelectionControl.selectedSegmentIndex==1 {
                        includeSession = false
                    }
                    if includeSession {
                        let taskEntries = s.taskEntries
                        if let taskEntryList = taskEntries.array as? [TaskEntry] {
                            let gap2taskEntry = TimePoliceModelUtils.getGap2TaskEntry(taskEntryList)
                            maxNumberOfTaskEntries = max(maxNumberOfTaskEntries, gap2taskEntry.count)
                            projectDetails[s] = (taskEntryList, gap2taskEntry)
                            finished[s] = false

                            if let te = s.getLastTaskEntry() {
                                if te.isOngoing() {
                                    heading += "* "
                                }
                            }
                            var sessionNameSuffix = ""
                            if let e = s.getProperty(sessionExtensionAttribute) {
                                sessionNameSuffix = UtilitiesDate.getStringWithFormat(s.created, format: e)
                            }
                            heading += "\(s.name) \(sessionNameSuffix)\t\t"
                        }
                    }
                }
            }
            str += "\(heading)\n"


            // Stop iteration at maxNumberOfTaskEntries (instead of maxNUmberOfTaskEntries-1)
            // to always printout end time of last task entry
            for i in 0...maxNumberOfTaskEntries {
                for s in projectDetails.keys.sorted(by: { $0.created.compare($1.created) == .orderedAscending }) {
                    if let (taskEntries, gap2taskEntry) = projectDetails[s] {
                        if gap2taskEntry.count == 0 {
                            finished[s] = true
                        }
                        if i < gap2taskEntry.count {
                            if gap2taskEntry[i] == -1 {
                                let previousTaskEntry = taskEntries[gap2taskEntry[i-1]]
                                str += "\t\(UtilitiesDate.getStringNoDate(previousTaskEntry.stopTime))\t"
                            } else {
                                let te = taskEntries[gap2taskEntry[i]]
                                if te.isStopped() {
                                    str += "\(te.task.name)\t\(UtilitiesDate.getStringNoDate(te.startTime))\t"
                                } else {
                                    str += "\(te.task.name)\t\(UtilitiesDate.getStringNoDate(te.startTime))\t"
                                }
                            }
                        } else {
                            if finished[s] == true {
                                str += "\t\t"
                            } else {
                                let previousTaskEntry = taskEntries[gap2taskEntry[i-1]]
                                if previousTaskEntry.isOngoing() {
                                    str += "\t...\t"
                                } else {
                                    str += "\t\(UtilitiesDate.getStringNoDate(previousTaskEntry.stopTime))\t"
                                }
                                finished[s] = true
                            }
                        }
                    }
                }
                str += "\n"
            }
        }
        print(str)
        UIPasteboard.general.string = str
    }

    @IBAction func dumpSessionSummary(_ sender: UIButton) {
        appLog.log(logger, logtype: .enterExit, message: "dumpSessionSummary")
        appLog.log(logger, logtype: .guiAction, message: "dumpSessionSummary")

        /*
        for each project p {
            projectSummary = [session: [Task:NSTimeInterval] ]
            setOfTasks = []
            for each session in p {
                get sessionSummary -> [Task: NSTieInterval]
                for each task in sessionSummary {
                    setOfTasks.add(task)
                }
                projectSummary[session] = sessionSummary
            }
            for each session in projectSummary {
                print session heading
            }
            for each task in setOfTasks {
                print task heading
                for each session in projectSummary {
                    print time for task
                }
            }
        }
        */

        guard let projects = Project.findInMOC(moc) else {
            return
        }

        var s = ""
        var sessionNameSuffix = ""

        for project in projects.sorted(by: { $0.created.compare($1.created) == .orderedAscending }) {
            if project.name == templateProjectName {
                continue
            }
            var projectSummary: [Session: [Task: (Int, TimeInterval)]] = [:]
            var setOfTasks = Set<Task>()
            for session in project.sessions {
                if let s = session as? Session {
                    var includeSession = true
                    if s.archived==true && sessionSelectionControl.selectedSegmentIndex==2
                    || s.archived==false && sessionSelectionControl.selectedSegmentIndex==1 {
                        includeSession = false
                    }
                    if includeSession {
                        let sessionSummary = s.getSessionTaskSummary(true)
                        for (task, _) in sessionSummary {
                            setOfTasks.insert(task)
                        }
                        projectSummary[s] = sessionSummary
                    }
                }
            }
            if projectSummary.isEmpty {
                // No sessions in current selection active/archived
                continue
            }

            var heading = "\t"
            for session in projectSummary.keys.sorted(by: { $0.created.compare($1.created) == .orderedAscending }) {
                if let w = session.getLastTaskEntry() {
                    if w.isOngoing() {
                        heading += "* "
                    }
                }
                sessionNameSuffix = ""
                if let e = session.getProperty(sessionExtensionAttribute) {
                    sessionNameSuffix = UtilitiesDate.getStringWithFormat(session.created, format: e)
                }

                heading += "\(session.name) \(sessionNameSuffix)\t"
            }
            s += "\(heading)\n"

            var taskRow = ""
            var sessionTotal: [Session: TimeInterval] = [:]
            for task in setOfTasks.sorted(by: { $0.name < $1.name }) {
                taskRow = "\(task.name)\t"
                for session in projectSummary.keys.sorted(by: { $0.created.compare($1.created) == .orderedAscending }) {
                    if let sessionSummary = projectSummary[session] {
                        if let (_, time) = sessionSummary[task] {
                            taskRow += "\(UtilitiesDate.getString(time))\t"
                            var total: TimeInterval = 0
                            if let t = sessionTotal[session] {
                                total = t
                            }
                            total += time
                            sessionTotal[session] = total
                        } else {
                            taskRow += "---\t"
                        }
                    }
                }
                s += "\(taskRow)\n"
            }
            var summaryRow = "Total\t"
            for session in projectSummary.keys.sorted(by: { $0.created.compare($1.created) == .orderedAscending }) {
                if let total = sessionTotal[session] {
                    summaryRow += "\(UtilitiesDate.getString(total))\t"
                } else {
                    summaryRow += "0:00:00\t"
                }
            }
            s += summaryRow
            s += "\n"
        }
        print(s)
        UIPasteboard.general.string = s
    }


    //---------------------------------------------
    // MainExportVC - dumpAllData
    //---------------------------------------------

    class func dumpAllData(_ moc: NSManagedObjectContext) -> String {
        var fetchRequest: NSFetchRequest<NSFetchRequestResult>
        var s: String

        do {
            s = ("---------------------------\n")
            s += ("----------Project----------\n\n")
            fetchRequest = NSFetchRequest(entityName: "Project")
            if let fetchResults = try moc.fetch(fetchRequest) as? [Project] {
                s += "[Project container size=\(fetchResults.count)]\n"
                for project in fetchResults {
                    s += ("P: \(project.name) @ \(UtilitiesDate.getString(project.created)) - \(project.id)\n")
                    for (key, value) in project.properties as! [String: String] {
                        s += "[\(key)]=[\(value)]\n"
                    }
                    if project.sessions.count==0 {
                        s += "???orphaned???\n"
                    }
                    s += "    [Session container size=\(project.sessions.count)]\n"
                    for session in project.sessions {
                        if let se = session as? Session {
                            s += "    S: \(se.getDisplayNameWithSuffix()) @ \(UtilitiesDate.getString(se.created))\n"
                        }
                    }
                }
            }
        } catch {
            print("Can't fetch projects")
        }

        do {
            s += "\n"
            s += ("---------------------------\n")
            s += ("----------Session----------\n\n")
            fetchRequest = NSFetchRequest(entityName: "Session")
            if let fetchResults = try moc.fetch(fetchRequest) as? [Session] {
                s += "[Session container size=\(fetchResults.count)]\n"
                for session in fetchResults {
                    s += ("S: \(session.getDisplayNameWithSuffix()) @ \(UtilitiesDate.getString(session.created)) - \(session.id)\n")
                    for (key, value) in session.properties as! [String: String] {
                        s += "[\(key)]=[\(value)]\n"
                    }
//                    s += "src=\(session.src)\n"
                    if session.archived==true {
                        s += "archived=true\n"
                    } else {
                        s += "archived=false\n"
                    }
                    s += ("    P: \(session.project.name) @ \(UtilitiesDate.getString(session.project.created))\n")
                    s += "    [TaskEntry container size=\(session.taskEntries.count)]\n"
                    session.taskEntries.enumerateObjects({ (elem, idx, stop) -> Void in
                        let taskEntry = elem as! TaskEntry
                        if taskEntry.isStopped() {
                            let timeForTaskEntry = taskEntry.stopTime.timeIntervalSince(taskEntry.startTime)
                            s += "    TE: \(taskEntry.task.name) \(UtilitiesDate.getString(taskEntry.startTime))->\(UtilitiesDate.getStringNoDate(taskEntry.stopTime)) = \(UtilitiesDate.getString(timeForTaskEntry))\n"
                        } else {
                            s += "    TE: \(taskEntry.task.name) \(UtilitiesDate.getString(taskEntry.startTime))->(ongoing) = ------\n"
                        }
                    })
                    s += "    [Task container size=\(session.tasks.count)]\n"
                    session.tasks.enumerateObjects({ (elem, idx, stop) -> Void in
                        let task = elem as! Task
                        s += "    T: \(task.name) @ \(UtilitiesDate.getString(task.created))\n"
                    })
                }
            }
        } catch {
            print("Can't fetch sessions")
        }


        do {
            s += "\n"
            s += ("------------------------\n")
            s += ("----------TaskEntry----------\n\n")
            fetchRequest = NSFetchRequest(entityName: "TaskEntry")
            if let fetchResults = try moc.fetch(fetchRequest) as? [TaskEntry] {
                s += "[TaskEntry container size=\(fetchResults.count)]\n"
                for taskEntry in fetchResults {
                    if taskEntry.isStopped() {
                        let timeForTaskEntry = taskEntry.stopTime.timeIntervalSince(taskEntry.startTime)
                        s += "TE: \(taskEntry.task.name) \(UtilitiesDate.getString(taskEntry.startTime))->\(UtilitiesDate.getStringNoDate(taskEntry.stopTime)) = \(UtilitiesDate.getString(timeForTaskEntry)) - \(taskEntry.id)\n"
                    } else {
                        s += "TE: \(taskEntry.task.name) \(UtilitiesDate.getString(taskEntry.startTime))->(ongoing) = ------ - \(taskEntry.id)\n"
                    }
                    for (key, value) in taskEntry.properties as! [String: String] {
                        s += "[\(key)]=[\(value)]\n"
                    }
                    s += "    S: \(taskEntry.session.getDisplayNameWithSuffix()) @ \(UtilitiesDate.getString(taskEntry.session.created))\n"
                    s += "    T: \(taskEntry.task.name) @ \(UtilitiesDate.getString(taskEntry.task.created))\n"
                }
            }
        } catch {
            print("Can't fetch taskEntry")
        }

        do {
            s += "\n"
            s += ("------------------------\n")
            s += ("----------Task----------\n\n")
            fetchRequest = NSFetchRequest(entityName: "Task")
            if let fetchResults = try moc.fetch(fetchRequest) as? [Task] {
                s += "[Task container size=\(fetchResults.count)]\n"
                for task in fetchResults {
                    s += ("T: \(task.name) @ \(UtilitiesDate.getString(task.created)) - \(task.id)\n")
                    for (key, value) in task.properties as! [String: String] {
                        s += "[\(key)]=[\(value)]\n"
                    }
                    if task.sessions.count==0 && task.taskEntries.count==0 {
                        s += "???orphaned???\n"
                    }
                    s += "    [Session container size=\(task.sessions.count)]\n"
                    for session in task.sessions {
                        if let se = session as? Session {
                            if se.project.name == templateProjectName {
                                s += ("    S: [\(se.getDisplayNameWithSuffix())] @ \(UtilitiesDate.getString(se.created))\n")
                            } else {
                                s += ("    S: \(se.getDisplayNameWithSuffix()) @ \(UtilitiesDate.getString(se.created))\n")
                            }
                        }
                    }
                    s += "    [TaskEntry container size=\(task.taskEntries.count)]\n"
                    task.taskEntries.enumerateObjects({ (elem, idx, stop) -> Void in
                        let taskEntry = elem as! TaskEntry
                        if taskEntry.isStopped() {
                            let timeForTaskEntry = taskEntry.stopTime.timeIntervalSince(taskEntry.startTime)
                            s += "    TE: \(taskEntry.task.name) \(UtilitiesDate.getString(taskEntry.startTime))->\(UtilitiesDate.getStringNoDate(taskEntry.stopTime)) = \(UtilitiesDate.getString(timeForTaskEntry))\n"
                        } else {
                            s += "    TE: \(taskEntry.task.name) \(UtilitiesDate.getString(taskEntry.startTime))->(ongoing) = ------\n"
                        }
                    })
                }
            }

        } catch {
            print("Can't fetch tasks")
        }

        return s
    }


}
