//
//  MainSessionsVC.swift
//  MainSessions
//
//  Created by Per Ekskog on 2015-02-03.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

/*

TODO

*/


import UIKit
import CoreData

class MainSessionListVC: UIViewController,
    UITableViewDataSource, 
    UITableViewDelegate,
    UIGestureRecognizerDelegate,
    AppLoggerDataSource,
    ToolbarInfoDelegate,
    TaskEntryCreatorManagerDataSource,
    TaskEntryCreatorManagerDelegate {

    // Input data
    var templateProjectName: String?

    // Internal data
    var selectedSessionIndex: Int?
    var taskEntryCreatorManagers: [UIViewController]?
    var nonTemplateSessions: [Session]?
    var templateSessions: [Session]?

    // GUI
    var sessionTableView = UITableView(frame: CGRect.zero, style: .plain)
    let exitButton = UIButton(type: UIButtonType.system)
    let sessionNameView = TaskEntriesToolView()
    let sessionSelectionControl = UISegmentedControl(frame: CGRect.zero)
    let sessionListBGView = TaskEntriesBGView()
    let addView = TaskEntriesToolView()
    let theme = BlackGreenTheme()


    //---------------------------------------
    // MainSessionListVC - Lazy properties
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
    // MainSessionListVC - AppLoggerDataSource
    //---------------------------------------------

    func getLogDomain() -> String {
        return "MainSessionListVC"
    }



    //---------------------------------------------
    // MainSessionListVC - View lifecycle
    //---------------------------------------------

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

    override func viewDidLoad() {
        super.viewDidLoad()
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidLoad")

        (self.view as! TimePoliceBGView).theme = theme

        exitButton.backgroundColor = UIColor(red: 0.0, green: 0.4, blue: 0.0, alpha: 1.0)
        exitButton.setTitleColor(UIColor.white, for: UIControlState())
        exitButton.setTitle("EXIT", for: UIControlState())
        exitButton.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(themeBigTextSize))
        exitButton.addTarget(self, action: #selector(MainSessionListVC.exit(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(exitButton)

        sessionNameView.theme = theme
        sessionNameView.tool = .sessionName
        sessionNameView.toolbarInfoDelegate = self
        self.view.addSubview(sessionNameView)

        sessionListBGView.theme = theme
        self.view.addSubview(sessionListBGView)

        sessionTableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "SessionList")
        sessionTableView.dataSource = self
        sessionTableView.delegate = self
        sessionTableView.rowHeight = CGFloat(selectItemTableRowHeight)
        sessionTableView.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
        sessionTableView.separatorColor = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MainSessionListVC.handleLongPressTableView(_:)))
        sessionTableView.addGestureRecognizer(longPressRecognizer)
        sessionListBGView.addSubview(sessionTableView)

        sessionSelectionControl.insertSegment(withTitle: "Active", at: 0, animated: false)
        sessionSelectionControl.insertSegment(withTitle: "Archived", at: 0, animated: false)
        sessionSelectionControl.insertSegment(withTitle: "All", at: 0, animated: false)
        sessionSelectionControl.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        sessionSelectionControl.tintColor = UIColor(red:0.1, green:0.6, blue:0.1, alpha: 1.0)
        sessionSelectionControl.addTarget(self, action: #selector(MainSessionListVC.selectSessions(_:)), for: .valueChanged)
        sessionSelectionControl.selectedSegmentIndex = 2
        sessionListBGView.addSubview(sessionSelectionControl)

        addView.theme = theme
        addView.toolbarInfoDelegate = self
        addView.tool = .add
        let recognizer = UITapGestureRecognizer(target:self, action:#selector(MainSessionListVC.addSession(_:)))
        recognizer.delegate = self
        addView.addGestureRecognizer(recognizer)
        sessionListBGView.addSubview(addView)
        
        redrawAll(true)
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewWillAppear")

        if let indexPath = sessionTableView.indexPathForSelectedRow {
            sessionTableView.deselectRow(at: indexPath, animated: true)
        }

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        appLog.log(logger, logtype: .viewLifecycle, message: "viewWillLayoutSubviews")

        var width = self.view.frame.width
        var height = self.view.frame.height

        var lastview: UIView

        exitButton.frame = CGRect(x: 0, y: 25, width: 70, height: CGFloat(minimumComponentHeight))
        lastview = exitButton

        sessionNameView.frame = CGRect(x: 70, y: 25, width: width-70, height: CGFloat(minimumComponentHeight))
        lastview = sessionNameView

        sessionListBGView.frame = CGRect(x: 0, y: 25+CGFloat(minimumComponentHeight), width: width, height: height - 25 - CGFloat(minimumComponentHeight))
        lastview = sessionListBGView

        width = sessionListBGView.frame.width
        height = sessionListBGView.frame.height
        let padding = 1

        sessionSelectionControl.frame = CGRect(x: 0, y: 0, width: width, height: CGFloat(segmentControlHeight))

        sessionTableView.frame = CGRect(x: CGFloat(padding), y: CGFloat(segmentControlHeight), width: width - 2*CGFloat(padding), height: height - CGFloat(segmentControlHeight) - CGFloat(minimumComponentHeight) - CGFloat(padding))
        lastview = sessionTableView

        addView.frame = CGRect(x: CGFloat(padding), y: lastview.frame.maxY + CGFloat(padding), width: width - 2*CGFloat(padding), height: CGFloat(minimumComponentHeight) - CGFloat(padding))
        lastview = addView
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidLayoutSubviews")
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        appLog.log(logger, logtype: .viewLifecycle, message: "didReceiveMemoryWarning")
    }

    //---------------------------------------------
    // MainSessionListVC - Data and GUI updates
    //---------------------------------------------

    func redrawAll(_ refreshCoreData: Bool) {
        if refreshCoreData==true {
            var s1, s2: [Session]
            let x = sessionSelectionControl.selectedSegmentIndex
            switch  x {
            case 0: (s1, s2) = getSessions(true, archived: true)
            case 1: (s1, s2) = getSessions(false, archived: true)
            case 2: (s1, s2) = getSessions(true, archived: false)
            default: (s1, s2) = getSessions(false, archived: false)
            }
            self.nonTemplateSessions = s1
            self.templateSessions = s2
        }
        sessionTableView.reloadData()
    }
    
    func getSessions(_ active: Bool, archived: Bool) -> ([Session], [Session]) {
        appLog.log(logger, logtype: .enterExit, message: "getSessions")

        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Session")

            var nonTemplateSessions: [Session] = []
            var templateSessions: [Session] = []
            
            if let tmpSessions = try moc.fetch(fetchRequest) as? [Session] {
//                for session in tmpSessions {
                for session in tmpSessions.sorted(by: { $0.created.compare($1.created) == .orderedAscending }) {
                    if session.project.name != templateProjectName {
                        if active==true && session.archived==false {
                            nonTemplateSessions.append(session)
                        }
                        if archived==true && session.archived==true {
                            nonTemplateSessions.append(session)
                        }
                    }
                }
                for session in tmpSessions.sorted(by: { (s1:Session, s2:Session) -> Bool in
                    if s1.name != s2.name {
                        return s1.name < s2.name
                    } else {
                        return s1.version < s2.version
                    }
                })
                    {
                        if session.project.name == templateProjectName {
                            templateSessions.append(session)
                    }
                }
            }
            return (nonTemplateSessions, templateSessions)

        } catch {
            return ([], [])
        }
    }
    
    @objc func selectSessions(_ sender: UISegmentedControl) {
        appLog.log(logger, logtype: .enterExit, message: "selectSessions")
        redrawAll(true)
    }
    
    //---------------------------------------------
    // MainSessionListVC - GUI actions
    //---------------------------------------------

    @IBAction func exit(_ sender: UIButton) {
        appLog.log(logger, logtype: .enterExit, message: "exit")
        appLog.log(logger, logtype: .guiAction, message: "exit")

        performSegue(withIdentifier: "Exit", sender: self)
    }

    @IBAction func addSession(_ sender: UIButton) {
        appLog.log(logger, logtype: .enterExit, message: "addSession")
        appLog.log(logger, logtype: .guiAction, message: "addSession")

        performSegue(withIdentifier: "AddSession", sender: self)
    }

    @objc func handleLongPressTableView(_ sender: UILongPressGestureRecognizer) {
        appLog.log(logger, logtype: .enterExit, message: "handleLongPressTableView")

        if sender.state != UIGestureRecognizerState.began {
            return
        }

        let locationInView = sender.location(in: sessionTableView)
        let indexPath = sessionTableView.indexPathForRow(at: locationInView)

        guard let i = indexPath?.row,
            let s = nonTemplateSessions?[i] else {
            appLog.log(logger, logtype: .guard, message: "guard fail in nonTemplateSessions[indexPath.row]")
            return
        }

        appLog.log(logger, logtype: .guiAction, message: "handleLongPressTableView(\(s.name))")

        var title = "Archive session?"
        if s.archived==true {
            title = "Unarchive session?"
        }

        let alertContoller = UIAlertController(title: title, message: nil,
            preferredStyle: .alert)
        
        let actionYes = UIAlertAction(title: "Yes", style: .default,
            handler: { action in
                if s.archived==true {
                    s.setArchivedTo(false)
                    self.appLog.log(self.logger, logtype: .guiAction, message: "handleLongPressTableView(set to non archived)")
                } else {
                    s.setArchivedTo(true)
                    self.appLog.log(self.logger, logtype: .guiAction, message: "handleLongPressTableView(set to archived)")
                }
                self.appLog.log(self.logger, logtype: .debug, message: "Did \(title)")
                self.redrawAll(true)
            })
        alertContoller.addAction(actionYes)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel,
            handler: { action in
                self.appLog.log(self.logger, logtype: .guiAction, message: "handleLongPressTableView(cancel)")
        })
        alertContoller.addAction(cancel)
        
        present(alertContoller, animated: true, completion: nil)

    }

    //---------------------------------------------
    // MainSessionListVC - Segue handling
    //---------------------------------------------

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        appLog.log(logger, logtype: .enterExit, message: "prepareForSegue")

        if segue.identifier == "TaskEntryCreatorManagers" {
            if let tbvc = segue.destination as? UITabBarController {
                if let vcs = tbvc.viewControllers,
                    let i = selectedSessionIndex,
                    let s = nonTemplateSessions {
                        let tb = tbvc.tabBar
                        tb.tintColor = UIColor.init(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
                        taskEntryCreatorManagers = vcs
                        for vc in vcs {
                            if var tecm = vc as? TaskEntryCreatorManager {
                                tecm.dataSource = self
                                tecm.delegate = self
                                tecm.currentSessionIndex = i
                                tecm.numberOfSessions = s.count
                            }
                        }
                }
            }
        }
        if segue.identifier == "Exit" {
            // Nothing to prepare
        }
        if segue.identifier == "AddSession" {
            if let nvc = segue.destination as? UINavigationController,
                    let vc = nvc.topViewController as? MainTemplateSelectVC {
                vc.templates = templateSessions
            }
        }
    }

    @IBAction func exitVC(_ unwindSegue: UIStoryboardSegue ) {
        appLog.log(logger, logtype: .enterExit, message: "exitVC")

        taskEntryCreatorManagers = nil
        
        redrawAll(false)
    }

    @IBAction func exitSelectTemplate(_ unwindSegue: UIStoryboardSegue ) {
        appLog.log(logger, logtype: .enterExit, message: "exitSelectTemplate(unwindsegue=\(String(describing: unwindSegue.identifier)))")

        if unwindSegue.identifier == "DoneTemplateSelect" {
            if let vc = unwindSegue.source as? MainTemplateSelectVC,
                let i = vc.templateIndexSelected,
                let s = templateSessions?[i] {
                    TimePoliceModelUtils.cloneSession(moc, projectName: s.name, sessionName: s.name, sessionVersion: s.version)
                    TimePoliceModelUtils.save(moc)
                    moc.reset()
                    redrawAll(true)
            }
        }
        if unwindSegue.identifier == "CancelTemplateSelect" {
            // Do nothing
        }
    }


    //-----------------------------------------
    // MainSessionListVC - UITableViewDataSource
    //-----------------------------------------

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let s = nonTemplateSessions {
            return s.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionList", for: indexPath)

        if let s = nonTemplateSessions, indexPath.row >= 0 && indexPath.row <= s.count {
            let session = s[indexPath.row]

            let name = session.getDisplayNameWithSuffix()

            var taskName = "(empty)"
            if let taskEntry = session.getLastTaskEntry() {
                if taskEntry.isOngoing() {
                    taskName = "(\(taskEntry.task.name))"
                } else {
                    taskName = "(stopped)"
                }
            }
            cell.textLabel?.text = "\(name) \(taskName)"
        }

        cell.backgroundColor = UIColor(white:0.3, alpha:1.0)
        cell.textLabel?.textColor = UIColor(white: 1.0, alpha: 1.0)
        cell.textLabel?.adjustsFontSizeToFitWidth = true

//        cell.separatorInset = UIEdgeInsetsZero
//        cell.layoutMargins = UIEdgeInsetsZero

        return cell
    }
    

    //-----------------------------------------
    // MainSessionListVC - UITableViewDelegate
    //-----------------------------------------

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var cellString = ""
        if let cell = tableView.cellForRow(at: indexPath),
            let s = cell.textLabel?.text {
                cellString = s
        }

        appLog.log(logger, logtype: .enterExit, message: "tableView.didSelectRowAtIndexPath")
        appLog.log(logger, logtype: .guiAction, message: "tableView.didSelectRowAtIndexPath(\(cellString))")

        if let s = nonTemplateSessions, indexPath.row >= 0 && indexPath.row < s.count {
            selectedSessionIndex = indexPath.row
            performSegue(withIdentifier: "TaskEntryCreatorManagers", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        var cellString = ""
        if let cell = tableView.cellForRow(at: indexPath),
            let s = cell.textLabel?.text {
                cellString = s
        }

        appLog.log(logger, logtype: .enterExit, message: "tableView.commitEditingStyle")
        appLog.log(logger, logtype: .guiAction, message: "tableView.commitEditingStyle(\(cellString))")

        if (editingStyle == UITableViewCellEditingStyle.delete) {
            if let session = nonTemplateSessions?[indexPath.row] {
                appLog.log(logger, logtype: .debug, message: "Delete row \(indexPath.row)")
                Session.deleteObject(session)
                TimePoliceModelUtils.save(moc)
                moc.reset()

                redrawAll(true)
            }
        }
    }


    //----------------------------------------------
    //  MainSessionListVC - ToolbarInfoDelegate
    //----------------------------------------------
    
    func getToolbarInfo() -> ToolbarInfo {
        appLog.log(logger, logtype: .periodicCallback, message: "getToolbarInfo")
        
        let toolbarInfo = ToolbarInfo(
            signedIn: false,
            totalTimesActivatedForSession: 0,
            totalTimeActiveForSession: 0,
            sessionName: "Sessions",
            numberOfPages: 0,
            currentPage: 0)
        
        return toolbarInfo
    }


    //-----------------------------------------
    // MainSessionListVC - TaskEntryCreatorManagerDataSource
    //-----------------------------------------


    func taskEntryCreatorManager(_ sessionManager: TaskEntryCreatorManager, willChangeActiveSessionTo: Int) {
        appLog.log(logger, logtype: .enterExit, message: "willChangeActiveSession to \(willChangeActiveSessionTo)")

        guard let s = nonTemplateSessions,
                let tecms =  taskEntryCreatorManagers else {
            appLog.log(logger, logtype: .guard, message: "guard fail in taskEntryCreatorManager willChangeActiveSessionTo(\(willChangeActiveSessionTo)")
            return
        }

        if willChangeActiveSessionTo >= 0 && willChangeActiveSessionTo < s.count {
            selectedSessionIndex = willChangeActiveSessionTo

            for vc in tecms {
                if let tecm = vc as? TaskEntryCreatorManager {
                    appLog.log(logger, logtype: .debug, message: "MainSessionsVC: switchTo(\(willChangeActiveSessionTo))")
                    tecm.switchTo(willChangeActiveSessionTo)
                }
            }
        }
    }

    func taskEntryCreatorManager(_ taskEntryCreatorManager: TaskEntryCreatorManager, sessionForIndex: Int) -> Session? {
        appLog.log(logger, logtype: .enterExit, message: "sessionForIndex(\(sessionForIndex))")

        guard let s = nonTemplateSessions, sessionForIndex >= 0 && sessionForIndex < s.count else {
            appLog.log(logger, logtype: .guard, message: "guard fail in taskEntryCreatorManager sessionForIndex(\(sessionForIndex))")
            return nil
        }
        
        return s[sessionForIndex]
    }

}
