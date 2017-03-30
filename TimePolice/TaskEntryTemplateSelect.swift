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

        self.edgesForExtendedLayout = UIRectEdge()

        self.title = "Select Template"
        
        let buttonCancel = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(TaskEntryTemplateSelectVC.cancel(_:)))
        self.navigationItem.leftBarButtonItem = buttonCancel

        table.rowHeight = CGFloat(selectItemTableRowHeight)
        table.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: cellReuseId)
        table.dataSource = self
        table.delegate = self
        self.view.addSubview(table)
    }

    override func viewWillAppear(_ animated: Bool) {
        if let indexPath = table.indexPathForSelectedRow {
            table.deselectRow(at: indexPath, animated: true)
        }
    }

    override func viewWillLayoutSubviews() {
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        table.frame = CGRect(x: 5, y: 0, width: width-10, height: height-25)        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // GUI actions

    func cancel(_ sender: UIButton) {
        appLog.log(logger, logtype: .enterExit, message: "cancel")
        appLog.log(logger, logtype: .guiAction, message: "cancel")

        performSegue(withIdentifier: "CancelUseTemplate", sender: self)
    }
    
    // UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var cellString = ""
        if let cell = tableView.cellForRow(at: indexPath),
            let s = cell.textLabel?.text {
                cellString = s
        }

        appLog.log(logger, logtype: .enterExit, message: "tableView.didSelectRowAtIndexPath")
        appLog.log(logger, logtype: .guiAction, message: "tableView.didSelectRowAtIndexPath(\(cellString))")

        templateIndexSelected = indexPath.row
        performSegue(withIdentifier: "DoneUseTemplate", sender: self)
    }
    
    // UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let t = templates {
            return t.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId, for: indexPath)

        if let s = templates, indexPath.row >= 0 && indexPath.row <= s.count {
            let session = s[indexPath.row]
            cell.textLabel?.text = session.getDisplayName()
        }

        return cell
    }
}
