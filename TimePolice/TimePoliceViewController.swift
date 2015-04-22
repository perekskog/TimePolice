//
//  TimePoliceViewController.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-02-03.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

import UIKit
import CoreData

class TimePoliceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var defaultVC: UISegmentedControl!
    
    var logTableView = UITableView(frame: CGRectZero, style: .Plain)

    var sessions: [Session]?
    var selectedSession: Session?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var viewFrame = self.view.frame
        viewFrame.origin.y += 120
        viewFrame.size.height -= 120
        logTableView.frame = viewFrame
        self.view.addSubview(logTableView)
        
        logTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "TimePoliceSessionCell")
        logTableView.dataSource = self
        logTableView.delegate = self
        self.sessions = getSessions()
        
        defaultVC.addTarget(self, action: "defaultVCChanged:", forControlEvents: .ValueChanged)
        defaultVC.selectedSegmentIndex = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TaskPicker" {
            let vc = segue.destinationViewController as! TaskPickerViewController
            vc.session = selectedSession
            vc.sourceController = self
        } 
        if segue.identifier == "WorkList" {
            let vc = segue.destinationViewController as! WorkListViewController
            vc.session = selectedSession
            vc.sourceController = self
        } 
    }

    func getSessions() -> [Session] {
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
    
    func defaultVCChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            println("TaskSwitcher")
        case 1:
            println("WorkList")
        default:
            println("Some other value (\(sender.selectedSegmentIndex))")
        }
    }


    //----------------------------------------
    // TimePoliceViewController - Buttons
    //----------------------------------------
    
    @IBAction func loadDataHome(sender: UIButton) {
        if let moc = self.managedObjectContext {
            TestData.addSessionToHome(moc)
            TimePoliceModelUtils.save(moc)
            moc.reset()

            let fetchRequest = NSFetchRequest(entityName: "Session")
            if let sessions = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Session] {
                self.sessions = getSessions()
            }

            logTableView.reloadData()
        }
    }
    
    @IBAction func loadDataWork(sender: UIButton) {
        if let moc = self.managedObjectContext {
            TestData.addSessionToWork(moc)
            TimePoliceModelUtils.save(moc)
            moc.reset()
            self.sessions = getSessions()
            logTableView.reloadData()
        }
    }
    
    @IBAction func loadDataDaytime(sender: UIButton) {
        if let moc = self.managedObjectContext {
            TestData.addSessionToDaytime(moc)
            TimePoliceModelUtils.save(moc)
            moc.reset()
            self.sessions = getSessions()
            logTableView.reloadData()
        }
    }
    
    @IBAction func clearAllData(sender: UIButton) {
        if let moc = self.managedObjectContext {
            TimePoliceModelUtils.clearAllData(moc)
            TimePoliceModelUtils.save(moc)
            moc.reset()
            self.sessions = getSessions()
            logTableView.reloadData()
        }
    }

    @IBAction func dumpAllCoreData(sender: UIButton) {
        if let moc = self.managedObjectContext {
            let s = TimePoliceModelUtils.dumpAllData(moc)
            println(s)
            UIPasteboard.generalPasteboard().string = s
        }
    }

    //-----------------------------------------
    // TimePoliceViewController- UITableView
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
        cell.textLabel?.text = sessions?[indexPath.row].name
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let session = sessions?[indexPath.row] {
            selectedSession = session
        }
        switch defaultVC.selectedSegmentIndex {
        case 0:
            performSegueWithIdentifier("TaskPicker", sender: self)
        case 1:
            performSegueWithIdentifier("WorkList", sender: self)
        default:
            println("VC \(defaultVC.selectedSegmentIndex) is not implemented")
        }
    }

    //---------------------------------------
    // TimePoliceViewController - CoreData
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
}
