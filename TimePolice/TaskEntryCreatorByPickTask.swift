//
//  TaskEntryCreatorByPickTaskVC.swift
//  TimePolice
//
//  Created by Per Ekskog on 2014-11-04.
//  Copyright (c) 2014 Per Ekskog. All rights reserved.
//


/* 

TODO

*/

import UIKit
import CoreData

//==================================================
//==================================================
//  TaskEntryCreatorByPickTask
//==================================================

class TaskEntryCreatorByPickTaskVC:
        TaskEntryCreatorBase,
        ToolbarInfoDelegate,
        SelectionAreaInfoDelegate,
        UIGestureRecognizerDelegate
	{

    let exitButton = UIButton(type: UIButton.ButtonType.system)
    let sessionNameView = TaskPickerToolView()
    let pageIndicatorView = TaskPickerPageIndicatorView()
    let signInSignOutView = TaskPickerToolView()
    let infoAreaView = TaskPickerToolView()

    let taskPickerBGView = TaskPickerBGView()

    var layout: Layout?

    var sessionTaskSummary: [Task: (Int, TimeInterval)] = [:]

    var recognizers: [UIGestureRecognizer: Int] = [:]
    var taskbuttonviews: [Int: TaskPickerButtonView] = [:]

    var updateActiveActivityTimer: Timer?
    
    let theme = BlackGreenTheme()
//        let theme = BasicTheme()

    let taskSelectionStrategy = TaskSelectAny()


    //---------------------------------------------
    // TaskEntryCreatorByPickTask - AppLoggerDataSource
    //---------------------------------------------

    override
    func getLogDomain() -> String {
        return "TaskEntryCreatorByPickTask"
    }


    //---------------------------------------------
    // TaskEntryCreatorByPickTask - View lifecycle
    //---------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        logger.datasource = self
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidLoad")

        (self.view as! TimePoliceBGView).theme = theme

        exitButton.backgroundColor = UIColor(red: 0.0, green: 0.4, blue: 0.0, alpha: 1.0)
        exitButton.setTitleColor(UIColor.white, for: UIControl.State())
        exitButton.setTitle("EXIT", for: UIControl.State())
        exitButton.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(themeBigTextSize))
        exitButton.addTarget(self, action: #selector(TaskEntryCreatorByPickTaskVC.exit(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(exitButton)

        sessionNameView.theme = theme
        sessionNameView.tool = .sessionName
        var recognizer = UITapGestureRecognizer(target:self, action:#selector(TaskEntryCreatorByPickTaskVC.useTemplate(_:)))
        recognizer.delegate = self
        sessionNameView.addGestureRecognizer(recognizer)
        self.view.addSubview(sessionNameView)

        pageIndicatorView.theme = theme
        self.view.addSubview(pageIndicatorView)
                
        taskPickerBGView.theme = theme
        self.view.addSubview(taskPickerBGView)

        signInSignOutView.theme = theme
        signInSignOutView.toolbarInfoDelegate = self
        signInSignOutView.tool = .signInSignOut
        recognizer = UITapGestureRecognizer(target:self, action:#selector(TaskEntryCreatorByPickTaskVC.handleTapSigninSignout(_:)))
        signInSignOutView.addGestureRecognizer(recognizer)
        taskPickerBGView.addSubview(signInSignOutView)
            
        infoAreaView.theme = theme
        infoAreaView.toolbarInfoDelegate = self
        infoAreaView.tool = .infoArea
        taskPickerBGView.addSubview(infoAreaView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewWillAppear")

        for (_, v) in taskbuttonviews {
            if let rr = v.gestureRecognizers {
                for r in rr {
                    v.removeGestureRecognizer(r)
                }
            }
            v.removeFromSuperview()
        }

        recognizers = [:]
        taskbuttonviews = [:]

        guard let s = session else {
            appLog.log(logger, logtype: .guard, message: "guard fail in viewWillAppear")
            return
        }

        let padding: CGFloat = 1
        let toolHeight: CGFloat = CGFloat(minimumComponentHeight)

        var columns: Int = 1 + s.tasks.count/10

        if let cols = s.getProperty("columns"),
            let c = Int(cols) {
                columns = c
        }

        var rows: Int = s.tasks.count/columns
        if s.tasks.count % columns > 0 {
            rows += 1
        }

        layout = GridLayout(rows: rows, columns: columns, padding: padding, toolHeight: toolHeight)
        
        self.sessionTaskSummary = s.getSessionTaskSummary(false)

        guard let tl = s.tasks.array as? [Task],
            let l = layout else {
            appLog.log(logger, logtype: .guard, message: "guard fail in viewWillAppear 2")
            return
        }

        let numberOfButtonsToDraw = l.numberOfSelectionAreas()
        let numberOfTasksInSession = tl.count
        for i in 0..<numberOfButtonsToDraw {
            let view = TaskPickerButtonView()
            view.theme = theme
            view.frame = l.getViewRect(taskPickerBGView.frame, buttonNumber: i)


            view.selectionAreaInfoDelegate = self
            view.taskPosition = i

            if i < numberOfTasksInSession {

                if tl[i].name != spacerName {
                
                    let tapRecognizer = UITapGestureRecognizer(target:self, action:#selector(TaskEntryCreatorByPickTaskVC.handleTapTask(_:)))
                    tapRecognizer.delegate = self
                    view.addGestureRecognizer(tapRecognizer)
                    recognizers[tapRecognizer] = i
                    
                    let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(TaskEntryCreatorByPickTaskVC.handleLongPressTask(_:)))
                    tapRecognizer.delegate = self
                    view.addGestureRecognizer(longPressRecognizer)
                    recognizers[longPressRecognizer] = i
                }
            }
                
            taskbuttonviews[i] = view
            taskPickerBGView.addSubview(view)
        }

        redrawAfterSegue()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidAppear")

        // This was originally in viewWillAppear, but it seems that viewWillAppear will be called
        // when changing session (PageController) and then, when changing TabBar, it will NOT
        // be called. 
        // viewDidAppear is always called.

        updateActiveActivityTimer = Timer.scheduledTimer(timeInterval: 1,
            target: self,
            selector: #selector(TaskEntryCreatorByPickTaskVC.updateActiveTask(_:)),
            userInfo: nil,
            repeats: true)

        appLog.log(logger, logtype: .resource, message: "starting timer \(String(describing:updateActiveActivityTimer))")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewWillDisappear")
    }


    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidDisappear")

        appLog.log(logger, logtype: .resource, message: "stopping timer \(String(describing:updateActiveActivityTimer))")

        updateActiveActivityTimer?.invalidate()
    }


    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        appLog.log(logger, logtype: .viewLifecycle, message: "viewWillLayoutSubviews")

        let width = self.view.frame.width
        let height = self.view.frame.height - 50

        exitButton.frame = CGRect(x: 0, y: 30, width: 70, height: CGFloat(minimumComponentHeight))
        
        sessionNameView.frame = CGRect(x: 70, y: 30, width: width-70, height: CGFloat(minimumComponentHeight) - 5)
        sessionNameView.toolbarInfoDelegate = self

        pageIndicatorView.frame = CGRect(x: 70, y: 30 + CGFloat(minimumComponentHeight) - 5, width: width-70, height: 5)
        pageIndicatorView.toolbarInfoDelegate = self

        taskPickerBGView.frame = CGRect(x: 0, y: 30 + CGFloat(minimumComponentHeight), width: width, height: height - 30 - CGFloat(minimumComponentHeight) - 33)

        guard let l = layout else {
            appLog.log(logger, logtype: .guard, message: "guard fail in viewWillLayoutSubviews")
            return
        }

        let numberOfButtonsToDraw = l.numberOfSelectionAreas()
        for i in 0..<numberOfButtonsToDraw {
            if let v = taskbuttonviews[i] {
                v.frame = l.getViewRect(taskPickerBGView.frame, buttonNumber: i)
            }
        }

        signInSignOutView.frame = l.getViewRectSignInSignOut(taskPickerBGView.frame)
        infoAreaView.frame = l.getViewRectInfo(taskPickerBGView.frame)

    }




    //---------------------------------------------
    // TaskEntryCreatorByPickTask - GUI actions
    //---------------------------------------------

    @objc func exit(_ sender: UIButton) {
        appLog.log(logger, logtype: .enterExit, message: "exit")
        appLog.log(logger, logtype: .guiAction, message: "exit")

        updateActiveActivityTimer?.invalidate()
        performSegue(withIdentifier: "Exit", sender: self)
    }

    @objc func useTemplate(_ sender: UIButton) {
        appLog.log(logger, logtype: .enterExit, message: "useTemplate")
        appLog.log(logger, logtype: .guiAction, message: "useTemplate")

        performSegue(withIdentifier: "UseTemplate", sender: self)
    }

    @objc func handleTapSigninSignout(_ sender: UITapGestureRecognizer) {
        appLog.log(logger, logtype: .enterExit, message: "handleTapSigninSignout")
        appLog.log(logger, logtype: .guiAction, message: "handleTapSigninSignout")

        signInSignOutView.setNeedsDisplay()
        infoAreaView.setNeedsDisplay()

        guard let s = session,
                let taskList = s.tasks.array as? [Task],
                let taskEntry = s.getLastTaskEntry() else {
            appLog.log(logger, logtype: .guard, message: "guard fail in handleTapSigninSignout")
            return
        }

        if taskEntry.isOngoing() {
            setLastTaskEntryAsFinished()
        } else {
            setLastTaskEntryAsOngoing()
        }
        if let taskIndex = taskList.firstIndex(of: taskEntry.task as Task) {
            taskbuttonviews[taskIndex]?.setNeedsDisplay()
        }

        appLog.log(logger, logtype: .enterExit) { TimePoliceModelUtils.getSessionTaskEntries(s) }
    }

    @objc func handleTapTask(_ sender: UITapGestureRecognizer) {
        appLog.log(logger, logtype: .enterExit, message: "handleTap")

        signInSignOutView.setNeedsDisplay()
        infoAreaView.setNeedsDisplay()

        guard let s = session,
                let taskList = s.tasks.array as? [Task] else {
            appLog.log(logger, logtype: .guard, message: "guard fail in handleTapTask")
            return
        }

        // Handle ongoing task
        if let taskEntry = s.getLastTaskEntry() {
            if let taskIndex = taskList.firstIndex(of: taskEntry.task as Task) {
                taskbuttonviews[taskIndex]?.setNeedsDisplay()
            }

            if taskEntry.isOngoing() {
                setLastTaskEntryAsFinished()
            }
        }

        // Handle new task
        let taskIndex = recognizers[sender]
        let task = taskList[taskIndex!]
        
        appLog.log(logger, logtype: .guiAction, message: "handleTap(\(task.name))")

        addNewTaskEntry(task)
        taskbuttonviews[taskIndex!]?.setNeedsDisplay()

        appLog.log(logger, logtype: .coreDataSnapshot) { TimePoliceModelUtils.getSessionTaskEntries(s) }
    }

    @objc func handleLongPressTask(_ sender: UILongPressGestureRecognizer) {
        appLog.log(logger, logtype: .enterExit, message: "handleLongPressTask")
        appLog.log(logger, logtype: .guiAction, message: "handleLongPressTask")

        if sender.state != UIGestureRecognizer.State.began {
            return
        }

        guard let s = session,
                let taskList = session?.tasks.array as? [Task] else {
            appLog.log(logger, logtype: .guard, message: "guard fail in handleLongPress 1")
            return
        }
        
        guard let taskEntry = s.getLastTaskEntry() else {
            appLog.log(logger, logtype: .enterExit, message: "No last taskentry")
            appLog.log(logger, logtype: .guard, message: "guard fail in handleLongPress 2")
            return
        }
        
        let taskPressedIndex = recognizers[sender]
        let taskPressed = taskList[taskPressedIndex!]
        if taskEntry.isOngoing() && taskEntry.task != taskPressed {
            appLog.log(logger, logtype: .enterExit, message: "TaskEntry is ongoing, LongPress on inactive task")
            return
        }

        selectedTaskEntryIndex = s.taskEntries.count - 1

        performSegue(withIdentifier: "EditTaskEntry", sender: self)
    }

    
    //---------------------------------------------
    // TaskEntryCreatorByPickTask - Segue handling (from base class)
    //---------------------------------------------
    
    override func redrawAfterSegue() {
        appLog.log(logger, logtype: .enterExit, message: "redraw")

        if let s = session?.getSessionTaskSummary(false) {
            sessionTaskSummary = s
        }

        signInSignOutView.setNeedsDisplay()
        infoAreaView.setNeedsDisplay()
        sessionNameView.setNeedsDisplay()
        pageIndicatorView.setNeedsDisplay()

        for (_, view) in taskbuttonviews {
            view.setNeedsDisplay()
        }
    }

    //---------------------------------------------
    // TaskEntryCreatorByPickTask - GestureRecognizerDelegate
    //---------------------------------------------

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch) -> Bool {
            return true
            /*
            if let taskNumber = recognizers[gestureRecognizer] {
                return true //taskIsSelectable(taskNumber)
            } else {
                return true
            }
            */
    }


    //----------------------------------------------
    //  TaskEntryCreatorByPickTask - SelectionAreaInfoDelegate
    //----------------------------------------------

	func getSelectionAreaInfo(_ selectionArea: Int) -> SelectionAreaInfo {
        appLog.log(logger, logtype: .periodicCallback) { "getSelectionAreaInfo\(selectionArea)"}

        // This will only be called when there are selection areas setup 
        //  => there _is_ a session
        //  => There _is_ a task in the taskList
        
        let sai = SelectionAreaInfo()
        
        guard let s = session,
            let taskList = s.tasks.array as? [Task] else {
            appLog.log(logger, logtype: .guard, message: "guard fail in getSelectionAreaInfo 1")
            return sai
        }

        if selectionArea >= 0 && selectionArea < taskList.count {
            let task = taskList[selectionArea]
            sai.task = task
            if let t = sessionTaskSummary[task] {
                let (numberOfTimesActivated, totalTimeActive) = t
                sai.numberOfTimesActivated = numberOfTimesActivated
                sai.totalTimeActive = totalTimeActive
            }
        }
        
        guard let taskEntry = s.getLastTaskEntry() else {
            appLog.log(logger, logtype: .guard, message: "guard fail in getSelectionAreaInfo getLastTaskEntry")
            return sai
        }

        if selectionArea >= 0 && selectionArea < taskList.count {
            if taskList[selectionArea] == taskEntry.task {
                sai.active = true
                sai.activatedAt = taskEntry.startTime
                if taskEntry.isOngoing() {
                    sai.ongoing = true
                } else {
                    sai.ongoing = false
                }
            } else {
                sai.active = false
                sai.ongoing = false
            }
        }
        
        return sai
	}

    //----------------------------------------------
    //  TaskEntryCreatorByPickTask - ToolbarInfoDelegate
    //----------------------------------------------

    func getToolbarInfo() -> ToolbarInfo {
        appLog.log(logger, logtype: .periodicCallback, message: "getToolbarInfo")
        
        var totalActivations: Int = 0 // The first task is active when first selected
        var totalTime: TimeInterval = 0
        
        for (_, (activations, time)) in sessionTaskSummary {
            totalActivations += activations
            totalTime += time
        }
        
        var signedIn = false
        if let taskEntry = session?.getLastTaskEntry() {
            if taskEntry.isOngoing() {
                signedIn = true
                
                let now = Date()
                if(now.compare(taskEntry.startTime) == .orderedDescending) {
                    let timeForActiveTask = Date().timeIntervalSince(taskEntry.startTime)
                    totalTime += timeForActiveTask
                }
            }
        }
        
        var sessionName = "---"
        if let s = session {
            sessionName = s.getDisplayNameWithSuffix()
        }

        var currentPage = 0
        if let n = sessionIndex {
            currentPage = n
        }

        var numberOfPages = 1
        if let n = numberOfSessions {
            numberOfPages = n
        }

        let toolbarInfo = ToolbarInfo(
            signedIn: signedIn,
            totalTimesActivatedForSession: totalActivations,
            totalTimeActiveForSession: totalTime,
            sessionName: sessionName,
            numberOfPages: numberOfPages,
            currentPage: currentPage)
        
        return toolbarInfo
    }

    //--------------------------------------------
    //  TaskEntryCreatorByPickTask - Sign int/out, add new taskEntry
    //--------------------------------------------

    func addNewTaskEntry(_ task: Task) {
        appLog.log(logger, logtype: .enterExit, message: "addTaskEntry")

        if let s = session {
            _ = TaskEntry.createInMOC(moc, name: "", session: s, task: task)
            TimePoliceModelUtils.save(moc)
        }
    }

    func setLastTaskEntryAsFinished() {
        appLog.log(logger, logtype: .enterExit, message: "setLastTaskEntryFinished")

        guard let taskEntry = session?.getLastTaskEntry() else {
            appLog.log(logger, logtype: .debug, message: "no taskentry in list")
            appLog.log(logger, logtype: .guard, message: "guard fail in setLastTaskEntryAsFinished")
            return
        }
        
        if taskEntry.isOngoing() {
            taskEntry.setStoppedAt(Date())

            var taskSummary: (Int, TimeInterval) = (0, 0)
            if let t = sessionTaskSummary[taskEntry.task] {
                taskSummary = t
            }
            var (numberOfTimesActivated, totalTimeActive) = taskSummary
            numberOfTimesActivated += 1
            totalTimeActive += taskEntry.stopTime.timeIntervalSince(taskEntry.startTime)
            sessionTaskSummary[taskEntry.task] = (numberOfTimesActivated, totalTimeActive)

            TimePoliceModelUtils.save(moc)
        } else {
            appLog.log(logger, logtype: .enterExit, message: "last taskentry not ongoing")
        }
    }

    func setLastTaskEntryAsOngoing() {
        appLog.log(logger, logtype: .enterExit, message: "setLastTaskEntryOngoing")

        guard let taskEntry = session?.getLastTaskEntry() else {
            appLog.log(logger, logtype: .debug, message: "no taskEntry in list")
            appLog.log(logger, logtype: .guard, message: "guard fail in setLastTaskEntryAsOngoing")
            return
        }
        if !taskEntry.isOngoing() {
            var taskSummary: (Int, TimeInterval) = (0, 0)
            if let t = sessionTaskSummary[taskEntry.task] {
                taskSummary = t
            }
            var (numberOfTimesActivated, totalTimeActive) = taskSummary
            numberOfTimesActivated -= 1
            totalTimeActive -= taskEntry.stopTime.timeIntervalSince(taskEntry.startTime)
            sessionTaskSummary[taskEntry.task] = (numberOfTimesActivated, totalTimeActive)

            taskEntry.setAsOngoing()

            TimePoliceModelUtils.save(moc)
        } else {
            appLog.log(logger, logtype: .enterExit, message: "last taskEntry not finished")
        }
    }



    //--------------------------------------------------------------
    // TaskEntryCreatorByPickTask - Periodic update of views, triggered by timeout
    //--------------------------------------------------------------

    var updateN = 0

    @objc
    func updateActiveTask(_ timer: Timer) {
        appLog.log(logger, logtype: .periodicCallback, message: "updateActiveTask")

        guard let s = session else {
            appLog.log(logger, logtype: .guard, message: "guard fail in updateActiveTask session")
            return
        }
            
        guard let taskEntry = s.getLastTaskEntry() else {
// Commented out, too frequent...
//                appLog.log(logger, logtype: .Guard, message: "guard fail in updateActiveTask lasttaskentry")
                return
        }
        
        guard let taskList = s.tasks.array as? [Task] else {
                appLog.log(logger, logtype: .guard, message: "guard fail in updateActiveTask tasklist")
                return
        }
        
        guard let taskIndex = taskList.firstIndex(of: taskEntry.task as Task) else {
                appLog.log(logger, logtype: .guard, message: "guard fail in updateActiveTask taskindex")
                return
        }
        
        taskbuttonviews[taskIndex]?.setNeedsDisplay()
        infoAreaView.setNeedsDisplay()
    }

}
