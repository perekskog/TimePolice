//
//  TaskEntryTemplateSelectVC.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-11-27.
//  Copyright © 2015 Per Ekskog. All rights reserved.
//

/*

TODO

- Missing AppLog

*/

import UIKit
import CoreData

class TaskEntryTemplateSelectVC: UIViewController,
    UITableViewDataSource,
    UITableViewDelegate,
    AppLoggerDataSource {

	// Input data
	var templates: [Session]?

	// Output data
	var templateIndexSelected: Int?


    // Internal
    
    let cellReuseId = "SelectTemplate"
    
    let table = UITableView()

    //----------------------------------------------------------------
    // TaskEntryTemplateSelectVC - Lazy properties
    //----------------------------------------------------------------
    
    lazy var appLog : AppLog = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.appLog
        }()

    lazy var logger: AppLogger = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var defaultLogger = appDelegate.getDefaultLogger()
        defaultLogger.datasource = self
        return defaultLogger
    }()

    //---------------------------------------------
    // TaskEntryTemplateSelectVC - AppLoggerDataSource
    //---------------------------------------------

    func getLogDomain() -> String {
        return "TaskEntryTemplateSelectVC"
    }

    //---------------------------------------------
    // TaskEntryTemplateSelectVC - View lifecycle
    //---------------------------------------------


    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = .None

        self.title = "Select Template"
        
        let buttonCancel = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(TaskEntryTemplateSelectVC.cancel(_:)))
        self.navigationItem.leftBarButtonItem = buttonCancel

        table.rowHeight = CGFloat(selectItemTableRowHeight)
        table.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: cellReuseId)
        table.dataSource = self
        table.delegate = self
        self.view.addSubview(table)
    }

    override func viewWillAppear(animated: Bool) {
        if let indexPath = table.indexPathForSelectedRow {
            table.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

    override func viewWillLayoutSubviews() {
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        table.frame = CGRectMake(5, 0, width-10, height-25)        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // GUI actions

    func cancel(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "cancel")
        appLog.log(logger, logtype: .GUIAction, message: "cancel")

        performSegueWithIdentifier("CancelUseTemplate", sender: self)
    }
    
    // UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cellString = ""
        if let cell = tableView.cellForRowAtIndexPath(indexPath),
            s = cell.textLabel?.text {
                cellString = s
        }

        appLog.log(logger, logtype: .EnterExit, message: "tableView.didSelectRowAtIndexPath")
        appLog.log(logger, logtype: .GUIAction, message: "tableView.didSelectRowAtIndexPath(\(cellString))")

        templateIndexSelected = indexPath.row
        performSegueWithIdentifier("DoneUseTemplate", sender: self)
    }
    
    // UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let t = templates {
            return t.count
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseId, forIndexPath: indexPath)

        if let s = templates
        where indexPath.row >= 0 && indexPath.row <= s.count {
            let session = s[indexPath.row]
            cell.textLabel?.text = session.getDisplayName()
        }

        return cell
    }
}