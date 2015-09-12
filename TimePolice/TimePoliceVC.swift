//
//  TimePoliceVC.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-02-03.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

import UIKit
import CoreData

class TimePoliceVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var defaultVC: UISegmentedControl!
    @IBOutlet var appLogSize: UILabel!
    
    var logTableView = UITableView(frame: CGRectZero, style: .Plain)

    var sessions: [Session]?
    var selectedSession: Session?

    //---------------------------------------
    // TimePoliceVC - Lazy properties
    //---------------------------------------

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
        return ApplogLog(locator: "TimePoliceVC")
    }()


    //---------------------------------------------
    // TimePoliceVC - View lifecycle
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

        var viewFrame = self.view.frame
        viewFrame.origin.y += 200
        viewFrame.size.height -= 200
        logTableView.frame = viewFrame
        self.view.addSubview(logTableView)
        
        logTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "TimePoliceSessionCell")
        logTableView.dataSource = self
        logTableView.delegate = self
        
        defaultVC.addTarget(self, action: "defaultVCChanged:", forControlEvents: .ValueChanged)

        redrawAll(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        appLog.log(logger, logtype: .iOS, message: "didReceiveMemoryWarning")
    }

    //---------------------------------------------
    // TimePoliceVC - Data and GUI updates
    //---------------------------------------------

    func getSessions() -> [Session] {
        appLog.log(logger, logtype: .EnterExit, message: "getSessions")

        let fetchRequest = NSFetchRequest(entityName: "Session")
        if let tmpSessions = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Session] {
            var nonTemplateSessions: [Session] = []
            for session in tmpSessions {
                if session.project.name != "Templates" {
                    nonTemplateSessions.append(session)
                }
            }
            return nonTemplateSessions
        }
        return []
    }
    
    func redrawAll(refreshCoreData: Bool) {
        if refreshCoreData==true {
            self.sessions = getSessions()
        }
        appLogSize.text = "\(count(appLog.logString))"
        logTableView.reloadData()
    }
    
    //---------------------------------------------
    // TimePoliceVC - Segue handling
    //---------------------------------------------

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        appLog.log(logger, logtype: .EnterExit, message: "prepareForSegue")

        if segue.identifier == "TaskEntryCreatorByPickTask" {
            let vc = segue.destinationViewController as! TaskEntryCreatorByPickTaskVC
            vc.session = selectedSession
        }
        if segue.identifier == "TaskEntryCreatorByAddToList" {
            let vc = segue.destinationViewController as! TaskEntryCreatorByAddToListVC
            vc.session = selectedSession
        } 
        if segue.identifier == "TaskEntryCreators" {
            let tbvc = segue.destinationViewController as! UITabBarController
            if let vcs = tbvc.viewControllers as? [TaskEntryCreatorBase] {
                for vc in vcs {
                    vc.session = selectedSession
                }
            }
        }
    }

    @IBAction func exitVC(unwindSegue: UIStoryboardSegue ) {
        appLog.log(logger, logtype: .EnterExit, message: "exitVC")

        redrawAll(false)
    }


    //----------------------------------------
    // TimePoliceVC - Buttons
    //----------------------------------------
    
    func defaultVCChanged(sender: UISegmentedControl) {
        appLog.log(logger, logtype: .EnterExit, message: "defaultVCChanged")

        switch sender.selectedSegmentIndex {
        case 0:
            appLog.log(logger, logtype: .Debug, message: "TaskSwitcher")
        case 1:
            appLog.log(logger, logtype: .Debug, message: "WorkList")
        default:
            appLog.log(logger, logtype: .Debug, message: "Some other value (\(sender.selectedSegmentIndex))")
        }
    }


    @IBAction func loadDataPrivate(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "loadDataPrivate")

        if let moc = self.managedObjectContext {
            TestData.addSessionToPrivate(moc)
            TimePoliceModelUtils.save(moc)
            moc.reset()

            redrawAll(true)
        }
    }
    
    @IBAction func loadDataWork(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "loadDataWork")

        if let moc = self.managedObjectContext {
            TestData.addSessionToWork(moc)
            TimePoliceModelUtils.save(moc)
            moc.reset()

            redrawAll(true)
        }
    }
    
    @IBAction func loadDataDaytime(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "loadDataDaytime")

        if let moc = self.managedObjectContext {
            TestData.addSessionToDaytime(moc)
            TimePoliceModelUtils.save(moc)
            moc.reset()

            redrawAll(true)
        }
    }
    
    @IBAction func loadDataTest(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "loadDataTest")

        if let moc = self.managedObjectContext {
            TestData.addSessionToTest(moc)
            TimePoliceModelUtils.save(moc)
            moc.reset()

            redrawAll(true)
        }
    }
    
    @IBAction func clearCoreData(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "clearAllData")

        if let moc = self.managedObjectContext {
            TimePoliceModelUtils.clearAllData(moc)
            TimePoliceModelUtils.save(moc)
            moc.reset()

            redrawAll(true)
        }
    }

    @IBAction func clearApplog(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "clearApplog")
        appLog.logString = ""
        appLogSize.text = "\(count(appLog.logString))"
    }

    @IBAction func dumpCoreData(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "dumpAllCoreData")

        if let moc = self.managedObjectContext {
            let s = TimePoliceModelUtils.dumpAllData(moc)
            println(s)
            UIPasteboard.generalPasteboard().string = s
        }
    }

    @IBAction func dumpApplog(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "dumpApplog")

        let s = appLog.logString
        println(s)
        UIPasteboard.generalPasteboard().string = s
    }

    //-----------------------------------------
    // TimePoliceVC- UITableView
    //-----------------------------------------

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let s = sessions {
            return s.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TimePoliceSessionCell") as! UITableViewCell
        if let session = sessions?[indexPath.row] {
            if let work = session.getLastWork() {
                if work.isOngoing() {
                    let taskName = ThemeUtilities.getWithoutComment(work.task.name)
                    cell.textLabel?.text = "\(session.name) (\(taskName))"
                } else {
                    cell.textLabel?.text = "\(session.name) (---)"
                }
            } else {
                cell.textLabel?.text = "\(session.name) (empty)"                
            }
        }
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let session = sessions?[indexPath.row] {
            selectedSession = session
        }
        /*
        switch defaultVC.selectedSegmentIndex {
        case 0:
            appLog.log(logger, logtype: .Debug, message: "performSegue TaskPicker")
            performSegueWithIdentifier("TaskEntryCreatorByPickTask", sender: self)
        case 1:
            appLog.log(logger, logtype: .Debug, message: "performSegue WorkList")
            performSegueWithIdentifier("TaskEntryCreatorByAddToList", sender: self)
        default:
            appLog.log(logger, logtype: .Debug, message: "VC \(defaultVC.selectedSegmentIndex) is not implemented")
        }
        */
        performSegueWithIdentifier("TaskEntryCreators", sender: self)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            if let moc = self.managedObjectContext,
               session = sessions?[indexPath.row] {
                appLog.log(logger, logtype: .Debug, message: "Delete row \(indexPath.row)")
                Session.deleteInMOC(moc, session: session)
                TimePoliceModelUtils.save(moc)
                moc.reset()

                redrawAll(true)
            }
        }
    }
}
