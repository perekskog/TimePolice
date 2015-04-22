//
//  WorkListViewController.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-04-21.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

/* TODO

- Are both these lines needed? (func exit)
        sourceController?.exitFromSegue()
        self.navigationController?.popViewControllerAnimated(true)

*/

import UIKit
import CoreData

class WorkListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var session: Session?
    var sourceController: TimePoliceViewController?

    var workListTableView = UITableView(frame: CGRectZero, style: .Plain)

    var statusView: UITextView?

    var selectedWork: Work?

    override func viewDidLoad() {
        super.viewDidLoad()

        var workListRect = self.view.frame
        workListRect.origin.y += 50
        workListRect.size.height -= 200
        workListTableView.frame = workListRect
        workListTableView.backgroundColor = UIColor(white: 0.4, alpha: 1.0)

        self.view.addSubview(workListTableView)
        
        workListTableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "WorkListWorkCell")
        workListTableView.dataSource = self
        workListTableView.delegate = self

        var statusRect = self.view.bounds
        statusRect.origin.x = 5
        statusRect.origin.y = statusRect.size.height-110
        statusRect.size.height = 100
        statusRect.size.width -= 10
        statusView = UITextView(frame: statusRect)
        statusView!.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        statusView!.textColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        statusView!.font = UIFont.systemFontOfSize(8)
        statusView!.editable = false
        self.view.addSubview(statusView!)

        let exitRect = CGRect(origin: CGPoint(x: self.view.bounds.size.width - 80, y: self.view.bounds.size.height-45), size: CGSize(width:70, height:30))
        let exitButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        exitButton.frame = exitRect
        exitButton.backgroundColor = UIColor(red: 0.0, green: 0.7, blue: 0.0, alpha: 1.0)
        exitButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        exitButton.setTitle("EXIT", forState: UIControlState.Normal)
        exitButton.addTarget(self, action: "exit:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(exitButton)
        

        let addButton = UIButton.buttonWithType(.System) as! UIButton
        let addRect = CGRect(origin: CGPoint(x: 5, y: self.view.bounds.size.height-145), size: CGSize(width:self.view.bounds.size.width-10, height:30))
        addButton.frame = addRect
        addButton.backgroundColor = UIColor(red: 0.7, green: 0.0, blue: 0.0, alpha: 1.0)
        addButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        addButton.setTitle("Add work", forState: UIControlState.Normal)
        addButton.addTarget(self, action: "addWork:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(addButton)

        TextViewLogger.log(statusView!, message: String("\n\(getString(NSDate())) WorkListVC.viewDidLoad"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        TextViewLogger.log(statusView!, message: String("\n\(getString(NSDate())) WorkListVC.didReceiveMemoryWarning"))
    }
    

    
    //-----------------------------------------
    // WorkListViewController- UITableView
    //-----------------------------------------

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let w = session?.work {
            return w.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkListWorkCell") as! UITableViewCell
        if let w = session?.work[indexPath.row] as? Work {
            cell.textLabel?.text = "\(indexPath.row) - " + w.task.name
        }
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let w = session?.work[indexPath.row] as? Work {
            selectedWork = w
            TextViewLogger.log(statusView!,
                message: String("\n\(getString(NSDate())) WorkListVC.selected(row=\(indexPath.row), work=\(w.task.name))"))
        }
    }

    func addWork(sender: UIButton) {
        TextViewLogger.log(statusView!, message: "\n\(getString(NSDate())) WorkListVC.addWork")
        if let moc = managedObjectContext,
                 s = session {
            let now = NSDate()
            var task = s.tasks[0] as! Task
            if let lastWork = s.getLastWork() {
                task = lastWork.task
                if lastWork.isOngoing() {
                    lastWork.setStoppedAt(now)
                }
            }
            Work.createInMOC(moc, name: "", session: s, task: task)

            workListTableView.reloadData()
        }
    }


    //--------------------------------------------------
    // TaskPickerViewController - CoreData MOC
    //--------------------------------------------------
    
    lazy var managedObjectContext : NSManagedObjectContext? = {

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
        }()


    //---------------------------------------------
    // WorkListViewController - Segue handling
    //---------------------------------------------


    func exit(sender: UIButton) {
        TextViewLogger.log(statusView!, message: "\n\(getString(NSDate())) WorkListVC.exit")

        self.navigationController?.popViewControllerAnimated(true)
    }
    


}
