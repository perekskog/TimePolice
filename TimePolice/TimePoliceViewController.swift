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

    var logTableView = UITableView(frame: CGRectZero, style: .Plain)

    var sessions: [Session]?
    var selectedSession: Session?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var viewFrame = self.view.frame
        viewFrame.origin.y += 80
        viewFrame.size.height -= 80
        logTableView.frame = viewFrame
        self.view.addSubview(logTableView)
        logTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "TimePoliceSessionCell")
        logTableView.dataSource = self
        logTableView.delegate = self
        let fetchRequest = NSFetchRequest(entityName: "Session")
        if let sessions = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Session] {
            self.sessions = sessions
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TaskPicker" {
            let vc = segue.destinationViewController as TaskPickerViewController
            vc.session = selectedSession
            vc.sourceController = self
        } 
    }

    func exitFromSegue() {
        println("dismissViewController")
    }

    //----------------------------------------
    // TimePoliceViewController - Buttons
    //----------------------------------------
    
    @IBAction func loadDataHome(sender: UIButton) {
        if let moc = self.managedObjectContext {
            TestData.addSessionToHome(moc)
            TimePoliceModelUtils.save(moc)
            TimePoliceModelUtils.dumpAllData(moc)

            let fetchRequest = NSFetchRequest(entityName: "Session")
            if let sessions = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Session] {
                self.sessions = sessions
            }

            logTableView.reloadData()
        }
    }
    
    @IBAction func loadDataWork(sender: UIButton) {
        if let moc = self.managedObjectContext {
            TestData.addSessionToWork(moc)
            TimePoliceModelUtils.save(moc)
            TimePoliceModelUtils.dumpAllData(moc)
            
            let fetchRequest = NSFetchRequest(entityName: "Session")
            if let sessions = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Session] {
                self.sessions = sessions
            }
            
            logTableView.reloadData()
        }
    }
    
    @IBAction func clearAllData(sender: UIButton) {
        if let moc = self.managedObjectContext {
            TimePoliceModelUtils.clearAllData(moc)
            TimePoliceModelUtils.save(moc)
            TimePoliceModelUtils.dumpAllData(moc)

            let fetchRequest = NSFetchRequest(entityName: "Session")
            if let sessions = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Session] {
                self.sessions = sessions
            }

            logTableView.reloadData()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("TimePoliceSessionCell") as UITableViewCell
        cell.textLabel?.text = sessions?[indexPath.row].name
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let session = sessions?[indexPath.row] {
            selectedSession = session
        }
        performSegueWithIdentifier("TaskPicker", sender: self)
    }

    //---------------------------------------
    // TimePoliceViewController - CoreData
    //---------------------------------------

    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
        }()
}
