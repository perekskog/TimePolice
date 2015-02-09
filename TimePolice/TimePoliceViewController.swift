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


    var taskList: [Task]?

    override func viewDidLoad() {
        super.viewDidLoad()
        let newProject = Project.createInMOC(self.managedObjectContext!, name: "My project 1")
        save()
        dumpData()

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
    
       taskList = [ Task.createInMOC(self.managedObjectContext!, name: "Dummy") ]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TaskPicker" {
            let vc = segue.destinationViewController as TaskPickerViewController
            vc.taskList = taskList
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
                println("\(project.id)")
            }
        }

        println("Session")
        let fetchRequest2 = NSFetchRequest(entityName: "Session")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest2, error: nil) as? [Session] {
            for session in fetchResults {
                println("\(session.id)")
            }
        }

        println("Work")
        let fetchRequest3 = NSFetchRequest(entityName: "Work")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest3, error: nil) as? [Work] {
            for work in fetchResults {
                println("(work)")
            }
        }

        println("Task")
        let fetchRequest4 = NSFetchRequest(entityName: "Task")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest4, error: nil) as? [Task] {
            for task in fetchResults {
                println("\(task.name)")
            }
        }

    }
}
