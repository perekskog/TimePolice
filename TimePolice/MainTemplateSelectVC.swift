//
//  MainTemplateListVC.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-11-22.
//  Copyright © 2015 Per Ekskog. All rights reserved.
//

/*

TODO

- Missing AppLog

*/

import UIKit
import CoreData

class MainTemplateSelectVC: UIViewController,
    UITableViewDataSource,
    UITableViewDelegate {

	// Input data
	var templates: [Session]?

	// Output data
	var templateIndexSelected: Int?


    // Internal
    
    let cellReuseId = "SelectTemplate"
    
    let table = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = .None

        self.title = "Select Template"
        
        let buttonCancel = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancel:")
        self.navigationItem.leftBarButtonItem = buttonCancel

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
        performSegueWithIdentifier("CancelTemplateSelect", sender: self)
    }
    
    // UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        templateIndexSelected = indexPath.row
        performSegueWithIdentifier("DoneTemplateSelect", sender: self)
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

        if let s = templates?[indexPath.row] {
        	cell.textLabel?.text = s.name
        }
    
        return cell
    }
}