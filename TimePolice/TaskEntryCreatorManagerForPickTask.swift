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
    	guard let s = dataSource?.taskEntryCreatorManager(self, sessionForIndex: index) else {
            appLog.log(logger, logtype: .Guard, message: "guard fail in pageViewControllerAtIndex(\(index))")
            return nil
        }
        
	    let storyBoard = UIStoryboard(name: "Main",
	        bundle: NSBundle.mainBundle())
        if let newVc = storyBoard.instantiateViewControllerWithIdentifier("TaskEntryCreatorByPickTask") as? TaskEntryCreatorBase {
	        newVc.sessionIndex = index
            newVc.session = s
            newVc.delegate = self
	        
	        return newVc
	    }

	    return nil
    }
    
}
