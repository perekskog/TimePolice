//
//  TaskEntryCreatorManagerForAddToList.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-09-13.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

/* 

TODO

*/


import UIKit

class TaskEntryCreatorManagerForAddToList: TaskEntryCreatorManagerBase {

    //---------------------------------------------
    // TaskEntryCreatorManagerForAddToList - AppLoggerDataSource
    //---------------------------------------------

    override func getLogDomain() -> String {
        return "TaskEntryCreatorManagerForAddToList"
    }

    /////////////////////////
    // UIPageViewControllerDataSource
    /////////////////////////

    override
    func pageViewControllerAtIndex(_ index: Int) -> TaskEntryCreatorBase? {
        appLog.log(logger, logtype: .enterExit, message: "pageViewControllerAtIndex(index=\(index)")

        guard let s = dataSource?.taskEntryCreatorManager(self, sessionForIndex: index) else {
            appLog.log(logger, logtype: .guard, message: "guard fail in pageViewControllerAtIndex")
            return nil
        }
        
        let storyBoard = UIStoryboard(name: "Main",
            bundle: Bundle.main)
        if let newVC = storyBoard.instantiateViewController(withIdentifier: "TaskEntryCreatorByAddToList") as? TaskEntryCreatorBase {
            newVC.sessionIndex = index
            newVC.numberOfSessions = self.numberOfSessions
            newVC.session = s
            newVC.delegate = self
                            
            return newVC
        }

        return nil
    }

}
