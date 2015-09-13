//
//  SessionManagerForAddToList.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-09-13.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

import UIKit

class TaskEntryCreatorManagerForAddToList: TaskEntryCreatorManagerBase {

    /////////////////////////
    // UIPageViewControllerDataSource
    /////////////////////////

    override
    func pageViewControllerAtIndex(index: Int) -> TaskEntryCreatorBase? {
        if let s = dataSource?.taskEntryCreatorManager(self, sessionForIndex: index) {
        
            let storyBoard = UIStoryboard(name: "Main",
                bundle: NSBundle.mainBundle())
            if let newVC = storyBoard.instantiateViewControllerWithIdentifier("TaskEntryCreatorByAddToList") as? TaskEntryCreatorByAddToListVC {
                newVC.sessionIndex = index
                newVC.session = s
                newVC.delegate = self
                            
                return newVC
            }
        }

        return nil
    }

}
