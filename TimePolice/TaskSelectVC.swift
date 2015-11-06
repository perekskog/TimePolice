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

class TaskSelectVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Input data
    var tasks: [Task]?
    
    // Output data
    var taskIndexSelected: Int?
    
    
    // Internal
    
    let cellReuseId = "SelectTask"
    
    let table = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = .None

        self.title = "Select Task"
        
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
    
    // UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        taskIndexSelected = indexPath.row
        performSegueWithIdentifier("DoneSelectTask", sender: self)
    }
    
    // UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseId, forIndexPath: indexPath)

        if let t = tasks?[indexPath.row] {
            let withoutComment = UtilitiesString.getWithoutProperties(t.name)

            if withoutComment != "" {
                cell.textLabel?.text = withoutComment
                
                if let comment = UtilitiesString.getProperty(t.name) {
                    if let colorString = UtilitiesString.getValue(comment, forTag: "color") {
                        let color = UtilitiesColor.string2color(colorString)
                                                
                        cell.imageView?.image = UtilitiesImage.getImageWithColor(color, width: 15.0, height: 15.0)
                    }
                }
            } else {
                cell.textLabel?.text = "(spacer)"
                cell.imageView?.image = nil
            }
        }
    
        return cell
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let t = tasks {
            return t.count
        } else {
            return 0
        }
    }
    
}
