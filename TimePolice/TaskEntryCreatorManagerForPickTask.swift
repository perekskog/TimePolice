//
//  SessionManagerForPickTask.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-09-13.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

import UIKit

class TaskEntryCreatorManagerForPickTask: TaskEntryCreatorManagerBase {

    //---------------------------------------------
    // TaskEntryCreatorManagerBase - AppLoggerDataSource
    //---------------------------------------------

    override func getLogDomain() -> String {
        return "TaskEntryCreatorManagerForPickTask"
    }



    /////////////////////////
    // UIPageViewControllerDataSource
    /////////////////////////

    override
    func pageViewControllerAtIndex(index: Int) -> TaskEntryCreatorBase? {
    	if let s = dataSource?.taskEntryCreatorManager(self, sessionForIndex: index) {
        
	        let storyBoard = UIStoryboard(name: "Main",
	            bundle: NSBundle.mainBundle())
	        if let newVc = storyBoard.instantiateViewControllerWithIdentifier("TaskEntryCreatorByPickTask") as? TaskEntryCreatorByPickTaskVC {
	        	newVc.sessionIndex = index
		        newVc.session = s
		        newVc.delegate = self
	        
		        return newVc
		    }
		}

	    return nil
    }
    
}
