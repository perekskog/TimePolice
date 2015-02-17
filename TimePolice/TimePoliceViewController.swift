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

    var project1: Project?
    var session11: Session?
    var taskListHome: [Task]?

    var project2: Project?
    var session21: Session?
    var session22: Session?
    var taskListWork: [Task]?

    var logTableView = UITableView(frame: CGRectZero, style: .Plain)

    var sessions: [Session]?
    var selectedTaskList: [Task]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        project1 = Project.createInMOC(self.managedObjectContext!, name: "Home")
        project2 = Project.createInMOC(self.managedObjectContext!, name: "Work")

        session11 = Session.createInMOC(self.managedObjectContext!, name: "Home 1")
        session11!.project = project1!
        project1!.sessions = NSSet(array: [session11!])

        session21 = Session.createInMOC(self.managedObjectContext!, name: "Work 1")
        session21!.project = project2!
        session22 = Session.createInMOC(self.managedObjectContext!, name: "Work 2")
        session22!.project = project2!
        project2!.sessions = NSSet(array:[session21!, session22!])

        // Personal
        taskListHome = [ 
            Task.createInMOC(self.managedObjectContext!, name: "I F2F"),
            Task.createInMOC(self.managedObjectContext!, name: "---"),
            Task.createInMOC(self.managedObjectContext!, name: "I Chat"),

            Task.createInMOC(self.managedObjectContext!, name: "I Email"),
            Task.createInMOC(self.managedObjectContext!, name: "---"),
            Task.createInMOC(self.managedObjectContext!, name: "I Blixt"),

            Task.createInMOC(self.managedObjectContext!, name: "P OF"),
            Task.createInMOC(self.managedObjectContext!, name: "---"),
            Task.createInMOC(self.managedObjectContext!, name: "P Lista"),

            Task.createInMOC(self.managedObjectContext!, name: "P Hushåll"),
            Task.createInMOC(self.managedObjectContext!, name: "---"),
            Task.createInMOC(self.managedObjectContext!, name: "P Other"),

            Task.createInMOC(self.managedObjectContext!, name: "N Waste"),
            Task.createInMOC(self.managedObjectContext!, name: "---"),
            Task.createInMOC(self.managedObjectContext!, name: "N Work"),

            Task.createInMOC(self.managedObjectContext!, name: "N Connect"),
            Task.createInMOC(self.managedObjectContext!, name: "N Down"),
            Task.createInMOC(self.managedObjectContext!, name: "N Time-in"),

            Task.createInMOC(self.managedObjectContext!, name: "N Physical"),
            Task.createInMOC(self.managedObjectContext!, name: "N Coffe/WC"),
            Task.createInMOC(self.managedObjectContext!, name: "N Other"),
        ]

        session11!.tasks = NSOrderedSet(array: taskListHome!)

        // Work
        taskListWork = [ 
            Task.createInMOC(self.managedObjectContext!, name: "I F2F"),
            Task.createInMOC(self.managedObjectContext!, name: "---"),
            Task.createInMOC(self.managedObjectContext!, name: "I Lync"),

            Task.createInMOC(self.managedObjectContext!, name: "I Email"),
            Task.createInMOC(self.managedObjectContext!, name: "I Ticket"),
            Task.createInMOC(self.managedObjectContext!, name: "I Blixt"),

            Task.createInMOC(self.managedObjectContext!, name: "P OF"),
            Task.createInMOC(self.managedObjectContext!, name: "P Task"),
            Task.createInMOC(self.managedObjectContext!, name: "P Ticket"),

            Task.createInMOC(self.managedObjectContext!, name: "P US"),
            Task.createInMOC(self.managedObjectContext!, name: "P Meeting"),
            Task.createInMOC(self.managedObjectContext!, name: "P Other"),

            Task.createInMOC(self.managedObjectContext!, name: "N Waste"),
            Task.createInMOC(self.managedObjectContext!, name: "---"),
            Task.createInMOC(self.managedObjectContext!, name: "N Not work"),

            Task.createInMOC(self.managedObjectContext!, name: "N Connect"),
            Task.createInMOC(self.managedObjectContext!, name: "N Down"),
            Task.createInMOC(self.managedObjectContext!, name: "N Time-in"),

            Task.createInMOC(self.managedObjectContext!, name: "N Physical"),
            Task.createInMOC(self.managedObjectContext!, name: "N Coffe/WC"),
            Task.createInMOC(self.managedObjectContext!, name: "N Other"),
        ]

        session21!.tasks = NSOrderedSet(array: taskListWork!)
        session22!.tasks = NSOrderedSet(array: taskListWork!)
    
        //save()
        dumpData()

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
            vc.taskList = selectedTaskList
            for task in selectedTaskList! {
                print("\(task.name)   ")
            }
            // vc.currentWork = session.currentWork
            // vc.previousTask = session.previousTask
        } 
    }
    
    /////////////////////
    // UITableView

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
            selectedTaskList = session.tasks.array as [Task]
        }
        performSegueWithIdentifier("TaskPicker", sender: self)
    }

    /////////////////////
    // CoreData

    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
        }()

    func save() {
       var error : NSError?
        if(managedObjectContext!.save(&error) ) {
            println("Save: error(\(error?.localizedDescription))")
        }
    }

    func dumpData() {
        var fetchRequest: NSFetchRequest

        println("---------------------------")
        println("----------Project----------\n")
        fetchRequest = NSFetchRequest(entityName: "Project")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Project] {
            for project in fetchResults {
                println("P: \(project.name)-\(project.id)")
                for session in project.sessions {
                    println("    S: \(session.name)-\(session.id)")
                    println("        P: \(session.project.name)-\(session.project.id)")
                }
            }
        }

        println("\n---------------------------")
        println("----------Session----------\n")
        fetchRequest = NSFetchRequest(entityName: "Session")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Session] {
            for session in fetchResults {
                println("S: \(session.name)-\(session.id)")
                println("    P: \(session.project.name)-\(session.project.id)")
                session.work.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
                    let work = elem as Work
                    println("    W: \(work.task.name)")
                }
                session.tasks.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
                    let task = elem as Task
                    println("    T: \(task.name)")
                }
            }
        }

        println("\n------------------------")
        println("----------Work----------\n")
        fetchRequest = NSFetchRequest(entityName: "Work")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Work] {
            for work in fetchResults {
                print("W: \(work.task.name)"   )
            }
        }

        println("\n------------------------")
        println("----------Task----------\n")
        fetchRequest = NSFetchRequest(entityName: "Task")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Task] {
            for task in fetchResults {
                print("T: \(task.name)")
            }
        }

    }
}
