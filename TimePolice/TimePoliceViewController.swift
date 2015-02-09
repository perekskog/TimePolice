    //
//  TimePoliceViewController.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-02-03.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

import UIKit
import CoreData

class TimePoliceViewController: UIViewController {

    var project1: Project?
    var session1: Session?
    var taskListHome: [Task]?

    var project2: Project?
    var session2: Session?
    var taskListWork: [Task]?

    override func viewDidLoad() {
        super.viewDidLoad()

        project1 = Project.createInMOC(self.managedObjectContext!, name: "Home")
        project2 = Project.createInMOC(self.managedObjectContext!, name: "Work")

        session1 = Session.createInMOC(self.managedObjectContext!, name: "Session 1.1")
        session1!.project = project1!

        session2 = Session.createInMOC(self.managedObjectContext!, name: "Session 2.1")
        session2!.project = project2!

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

        session1!.taskList = NSOrderedSet(array: taskListHome!)

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

            Task.createInMOC(self.managedObjectContext!, name: "N Walking"),
            Task.createInMOC(self.managedObjectContext!, name: "N Coffe/WC"),
            Task.createInMOC(self.managedObjectContext!, name: "N Other"),
        ]
        
        session2!.taskList = NSOrderedSet(array: taskListWork!)

        /*
        taskList = [
            Task(name: "I F2F"), Task(name: "---"), Task(name: "I Lync"),
            Task(name: "I Email"), Task(name: "I Ticket"), Task(name: "I Blixt"),
            Task(name: "P OF"), Task(name: "P Task"), Task(name: "P Ticket"),
            Task(name: "P US"), Task(name: "P Meeting"), Task(name: "P Other"),
            Task(name: "N Waste"), Task(name: "---"), Task(name: "N Not work"),
            Task(name: "N Connect"), Task(name: "N Down"), Task(name: "N Time in"),
            Task(name: "N Walking"), Task(name: "N Coffee/WC"),  Task(name: "N Other"),
        ]

*/
/*
        let taskList = [
            Task(name: "I F2F"), Task(name: "---"), Task(name: "I Chat"),
            Task(name: "I Email"), Task(name: "---"), Task(name: "I Blixt"),
            Task(name: "P OF"), Task(name: "---"), Task(name: "P Lista"),
            Task(name: "P Hushåll"), Task(name: "---"), Task(name: "P Other"),
            Task(name: "N Waste"), Task(name: "---"), Task(name: "N Work"),
            Task(name: "N Connect"), Task(name: "N Down"), Task(name: "N Time in"),
            Task(name: "---"), Task(name: "N Coffee/WC"),  Task(name: "N Other"),
        ]
  */
    

        //save()
        dumpData()


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TaskPicker" {
            let vc = segue.destinationViewController as TaskPickerViewController
            vc.taskList = taskListHome
            // vc.currentWork = session.currentWork
            // vc.previousTask = session.previousTask
        } 
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
        println("Project")
        let fetchRequest1 = NSFetchRequest(entityName: "Project")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest1, error: nil) as? [Project] {
            for project in fetchResults {
                println("P: \(project.id)")
                for session in project.sessions {
                    println("    S: \(session.id)")
                    println("        P: \(session.project.id)")
                }
            }
        }

        println("Session")
        let fetchRequest2 = NSFetchRequest(entityName: "Session")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest2, error: nil) as? [Session] {
            for session in fetchResults {
                println("S: \(session.id)")
                println("    P:\(session.project.id)")
                session.workDone.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
                    let work = elem as Work
                    println("    W: \(work.task.name)")
                }
                session.taskList.enumerateObjectsUsingBlock { (elem, idx, stop) -> Void in
                    let task = elem as Task
                    println("    T: \(task.name)")
                }
            }
        }

        println("Work")
        let fetchRequest3 = NSFetchRequest(entityName: "Work")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest3, error: nil) as? [Work] {
            for work in fetchResults {
                println("W: \(work.task.name)")
            }
        }

        println("Task")
        let fetchRequest4 = NSFetchRequest(entityName: "Task")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest4, error: nil) as? [Task] {
            for task in fetchResults {
                println("T: \(task.name)")
            }
        }

    }
}
