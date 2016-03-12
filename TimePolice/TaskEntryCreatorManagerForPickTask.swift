//
//  TaskEntryCreatorManagerForPickTask.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-09-13.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

/* 

TODO

*/


import UIKit

class TaskEntryCreatorManagerForPickTask: TaskEntryCreatorManagerBase {

    //---------------------------------------------
    // TaskEntryCreatorManagerForPickTask - AppLoggerDataSource
    //---------------------------------------------

    override func getLogDomain() -> String {
        return "TaskEntryCreatorManagerForPickTask"
    }

    /////////////////////////
    // UIPageViewControllerDataSource
    /////////////////////////

    override
    func pageViewControllerAtIndex(index: Int) -> TaskEntryCreatorBase? {
        appLog.log(logger, logtype: .EnterExit, message: "pageViewControllerAtIndex(index=\(index)")

    	guard let s = dataSource?.taskEntryCreatorManager(self, sessionForIndex: index) else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in pageViewControllerAtIndex(\(index))")
            return nil
        }
        
	    let storyBoard = UIStoryboard(name: "Main",
	        bundle: NSBundle.mainBundle())
        if let newVC = storyBoard.instantiateViewControllerWithIdentifier("TaskEntryCreatorByPickTask") as? TaskEntryCreatorBase {
	        newVC.sessionIndex = index
            newVC.numberOfSessions = self.numberOfSessions
            newVC.session = s
            newVC.delegate = self
	        
	        return newVC
	    }

	    return nil
    }
    
}
