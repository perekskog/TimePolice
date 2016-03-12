//
//  TaskSelectVC.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-08-11.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

/*

TODO

- Missing AppLog

*/

import UIKit

class TaskSelectVC: UIViewController,
    UITableViewDataSource,
    UITableViewDelegate,
    AppLoggerDataSource {
    
    // Input data
    var tasks: [Task]?
    
    // Output data
    var taskIndexSelected: Int?
    
    
    // Internal
    
    let cellReuseId = "SelectTask"
    
    let table = UITableView()

    var cell2task: [Int] = []


    //----------------------------------------------------------------
    // TaskSelectVC - Lazy properties
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
    // TaskSelectVC - AppLoggerDataSource
    //---------------------------------------------

    func getLogDomain() -> String {
        return "TaskSelectVC"
    }

    //---------------------------------------------
    // TaskSelectVC - View lifecycle
    //---------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewDidLoad")

        self.edgesForExtendedLayout = .None

        self.title = "Select Task"
        
        table.rowHeight = CGFloat(selectItemTableRowHeight)
        table.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: cellReuseId)
        table.dataSource = self
        table.delegate = self
        self.view.addSubview(table)

        var s = ""
        if let tl = tasks {
            for i in 0...tl.count-1 {
                if tl[i].name != spacerName {
                    cell2task.append(i)
                    s += "\(i)\n"
                }
            }
        }
        appLog.log(logger, logtype: .Debug, message: "cell2task=\n\(s)")
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
    
    // UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cellString = ""
        if let cell = tableView.cellForRowAtIndexPath(indexPath),
            s = cell.textLabel?.text {
                cellString = s
        }

        appLog.log(logger, logtype: .EnterExit, message: "tableView.didSelectRowAtIndexPath")
        appLog.log(logger, logtype: .GUIAction, message: "tableView.didSelectRowAtIndexPath(\(cellString))")

        taskIndexSelected = cell2task[indexPath.row]
        performSegueWithIdentifier("DoneSelectTask", sender: self)
    }
    
    // UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseId, forIndexPath: indexPath)

        let i = cell2task[indexPath.row]
        if let t = tasks?[i] {
            cell.textLabel?.text = t.name
   
            if let colorString = t.getProperty("color") {
                let color = UtilitiesColor.string2color(colorString)
                
                cell.imageView?.image = UtilitiesImage.getImageWithColor(color, width: 15.0, height: 15.0)
            }
        }
    
        return cell
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cell2task.count
    }
    
}
