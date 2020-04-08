//
//  MainTemplateListVC.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-11-16.
//  Copyright © 2015 Per Ekskog. All rights reserved.
//

/*

TODO

*/

import UIKit
import CoreData

class MainTemplateListVC: UIViewController,
    AppLoggerDataSource,
    ToolbarInfoDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    UIGestureRecognizerDelegate {

    // Input data
    var templateProjectName: String?

    // Internal data
    var templateSessions: [Session]?
    var selectedTemplateIndex: Int?

    // GUI
    var templateTableView = UITableView(frame: CGRect.zero, style: .plain)
    let exitButton = UIButton(type: UIButton.ButtonType.system)
    let sessionNameView = TaskEntriesToolView()
    let templateListBGView = TaskEntriesBGView()
    let addView = TaskEntriesToolView()
    let theme = BlackGreenTheme()



    //---------------------------------------
    // MainTemplateListVC - Lazy properties
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
    // MainTemplateListVC - AppLoggerDataSource
    //---------------------------------------------

    func getLogDomain() -> String {
        return "MainTemplateListVC"
    }



    //---------------------------------------------
    // MainTemplateListVC - View lifecycle
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

        self.edgesForExtendedLayout = UIRectEdge()

        exitButton.backgroundColor = UIColor(red: 0.0, green: 0.4, blue: 0.0, alpha: 1.0)
        exitButton.setTitleColor(UIColor.white, for: UIControl.State())
        exitButton.setTitle("EXIT", for: UIControl.State())
        exitButton.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(themeBigTextSize))
        exitButton.addTarget(self, action: #selector(MainTemplateListVC.exit(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(exitButton)

        sessionNameView.theme = theme
        sessionNameView.tool = .sessionName
        sessionNameView.toolbarInfoDelegate = self
        self.view.addSubview(sessionNameView)

        templateListBGView.theme = theme
        self.view.addSubview(templateListBGView)

        templateTableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "TemplateList")
        templateTableView.dataSource = self
        templateTableView.delegate = self
        templateTableView.rowHeight = CGFloat(selectItemTableRowHeight)
        templateTableView.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
        templateTableView.separatorColor = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
        templateListBGView.addSubview(templateTableView)                

        addView.theme = theme
        addView.toolbarInfoDelegate = self
        addView.tool = .add
        let recognizer = UITapGestureRecognizer(target:self, action:#selector(MainTemplateListVC.addTemplate(_:)))
        recognizer.delegate = self
        addView.addGestureRecognizer(recognizer)
        templateListBGView.addSubview(addView)

        redrawAll(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewWillAppear")

        if let indexPath = templateTableView.indexPathForSelectedRow {
            templateTableView.deselectRow(at: indexPath, animated: true)
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

        templateListBGView.frame = CGRect(x: 0, y: 25+CGFloat(minimumComponentHeight), width: width, height: height - 25 - CGFloat(minimumComponentHeight))
        lastview = templateListBGView

        width = templateListBGView.frame.width
        height = templateListBGView.frame.height
        let padding = 1

        templateTableView.frame = CGRect(x: CGFloat(padding), y: CGFloat(padding), width: width - 2*CGFloat(padding), height: height - CGFloat(minimumComponentHeight) - CGFloat(padding))
        lastview = templateTableView

        addView.frame = CGRect(x: CGFloat(padding), y: lastview.frame.maxY + CGFloat(padding), width: width - 2*CGFloat(padding), height: CGFloat(minimumComponentHeight) - 2*CGFloat(padding))
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
    // MainTemplateListVC - Data and GUI updates
    //---------------------------------------------

    func redrawAll(_ refreshCoreData: Bool) {
        if refreshCoreData==true {
            templateSessions = getTemplates()
        }
        templateTableView.reloadData()
    }

    func getTemplates() -> [Session] {
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
                    if session.project.name == templateProjectName {
                        templateSessions.append(session)
                    }
                }
            }
            return templateSessions

        } catch {
            return []
        }
    }


    //---------------------------------------------
    // MainTemplateListVC - GUI actions
    //---------------------------------------------

    @IBAction func exit(_ sender: UIButton) {
        appLog.log(logger, logtype: .enterExit, message: "exit")
        appLog.log(logger, logtype: .guiAction, message: "exit")

        performSegue(withIdentifier: "Exit", sender: self)
    }

    @IBAction func addTemplate(_ sender: UIButton) {
        appLog.log(logger, logtype: .enterExit, message: "addTemplate")
        appLog.log(logger, logtype: .guiAction, message: "addTemplate")

        performSegue(withIdentifier: "AddTemplate", sender: self)
    }


    //----------------------------------------------
    //  MainTemplateListVC - Segue handling
    //----------------------------------------------

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        appLog.log(logger, logtype: .enterExit) { "prepareForSegue(\(String(describing: segue.identifier)))" }

        if segue.identifier == "AddTemplate" {
            if let nvc = segue.destination as? UINavigationController,
                    let vc = nvc.topViewController as? MainTemplatePropVC {
                vc.segue = "AddTemplate"
            }
        }
        if segue.identifier == "EditTemplate" {
            if let nvc = segue.destination as? UINavigationController,
                    let vc = nvc.topViewController as? MainTemplatePropVC,
                    let i = selectedTemplateIndex,
                    let s = templateSessions?[i] {
                vc.segue = "EditTemplate"
                vc.template = s.src
            }
        }
    }

    @IBAction func exitTemplateProp(_ unwindSegue: UIStoryboardSegue ) {
        appLog.log(logger, logtype: .enterExit, message: "exitTemplateProp(unwindsegue=\(String(describing: unwindSegue.identifier)))")

        if unwindSegue.identifier == "CancelTemplateProp" {
            redrawAll(true)
        }
        if unwindSegue.identifier == "SaveTemplateProp" {
            // Update template
            if let vc = unwindSegue.source as? MainTemplatePropVC,
                let newSrc = vc.updatedTemplateSrc,
                let st = vc.parsedUpdatedTemplate {
                    appLog.log(logger, logtype: .guiAction, message: "SaveTemplate(\(st.session))")
                    let (reuseTasksFromProject, _, _) = st.session
                    TimePoliceModelUtils.storeTemplate(moc, reuseTasksFromProject: reuseTasksFromProject, session: st.session, tasks: st.tasks, src: newSrc)
            }
            redrawAll(true)
        }
    }

    //---------------------------------------------
    // MainTemplateListVC - UITableViewDataSource
    //---------------------------------------------
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let s = templateSessions {
            return s.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = templateTableView.dequeueReusableCell(withIdentifier: "TemplateList", for: indexPath)

        if let s = templateSessions, indexPath.row >= 0 && indexPath.row <= s.count {
            let session = s[indexPath.row]
            cell.textLabel?.text = session.getDisplayName()
        }

        cell.backgroundColor = UIColor(white:0.3, alpha:1.0)
        cell.textLabel?.textColor = UIColor(white: 1.0, alpha: 1.0)
        cell.textLabel?.adjustsFontSizeToFitWidth = true

//        cell.separatorInset = UIEdgeInsetsZero
//        cell.layoutMargins = UIEdgeInsetsZero
    
        return cell
    }

    //-----------------------------------------
    // MainTemplateListVC - UITableViewDelegate
    //-----------------------------------------

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var cellString = ""
        if let cell = tableView.cellForRow(at: indexPath),
            let s = cell.textLabel?.text {
                cellString = s
        }

        appLog.log(logger, logtype: .enterExit, message: "tableView.didSelectRowAtIndexPath")
        appLog.log(logger, logtype: .guiAction, message: "tableView.didSelectRowAtIndexPath(\(cellString))")

        if let s = templateSessions, indexPath.row >= 0 && indexPath.row < s.count {
            selectedTemplateIndex = indexPath.row
            performSegue(withIdentifier: "EditTemplate", sender: self)
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        var cellString = ""
        if let cell = tableView.cellForRow(at: indexPath),
            let s = cell.textLabel?.text {
                cellString = s
        }

        appLog.log(logger, logtype: .enterExit, message: "tableView.commitEditingStyle")
        appLog.log(logger, logtype: .guiAction, message: "tableView.commitEditingStyle(\(cellString))")

        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            if let session = templateSessions?[indexPath.row] {
                appLog.log(logger, logtype: .debug, message: "Delete row \(indexPath.row)")
                Session.deleteObject(session)
                TimePoliceModelUtils.save(moc)
                moc.reset()

                redrawAll(true)
            }
        }
    }

    //----------------------------------------------
    //  MainTemplateListVC - ToolbarInfoDelegate
    //----------------------------------------------
    
    func getToolbarInfo() -> ToolbarInfo {
        appLog.log(logger, logtype: .periodicCallback, message: "getToolbarInfo")
        
        let toolbarInfo = ToolbarInfo(
            signedIn: false,
            totalTimesActivatedForSession: 0,
            totalTimeActiveForSession: 0,
            sessionName: templateProjectName!,
            numberOfPages: 0,
            currentPage: 0)
        
        return toolbarInfo
    }

}
