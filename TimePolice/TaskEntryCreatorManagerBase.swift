//
//  SessionManagerBase.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-09-13.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

import UIKit

protocol TaskEntryCreatorManagerDelegate {
    func taskEntryCreatorManager(taskEntryCreatorManager: TaskEntryCreatorManager, willChangeActiveSession: Int)    
}

protocol TaskEntryCreatorManagerDataSource {
    func taskEntryCreatorManager(taskEntryCreatorManager: TaskEntryCreatorManager, sessionForIndex: Int) -> Session?
}

protocol TaskEntryCreatorManager {
    func switchTo(newSessionIndex: Int)
}

class TaskEntryCreatorManagerBase: UIViewController,
    UIPageViewControllerDataSource,
    UIPageViewControllerDelegate,
    AppLoggerDataSource,
    TaskEntryCreatorManager,
    TaskEntryCreatorDelegate {
    
    var dataSource: TaskEntryCreatorManagerDataSource?
    var delegate: TaskEntryCreatorManagerDelegate?
    
    let pageViewController: UIPageViewController = TaskEntryCreatorManagerPageViewController()

    var currentSessionIndex: Int?

    //--------------------------------------------------------
    // TaskEntryCreatorManagerBase - Lazy properties
    //--------------------------------------------------------

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
    // TaskEntryCreatorManagerBase - AppLoggerDataSource
    //---------------------------------------------

    func getLogDomain() -> String {
        return "TaskEntryCreatorManagerBase"
    }

    
    //---------------------------------------------
    // TaskEntryCreatorManagerBase - View lifecycle
    //---------------------------------------------

  
    override func viewDidLoad() {
        super.viewDidLoad()
        logger.datasource = self

        appLog.log(logger, logtype: .iOS, message: "TaskEntryManagerBase viewDidLoad")
        
        pageViewController.dataSource = self
        
        if let i = currentSessionIndex {
            if let initialVC: TaskEntryCreatorBase = pageViewControllerAtIndex(i) {
                pageViewController.setViewControllers([initialVC],
                    direction: .Forward,
                    animated: false,
                    completion: nil)
                pageViewController.delegate = self
                
                self.addChildViewController(pageViewController)
                self.view.addSubview(self.pageViewController.view)
                pageViewController.didMoveToParentViewController(self)
            }
        }
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger, logtype: .iOS, message: "TaskEntryManagerBase viewWillAppear")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        appLog.log(logger, logtype: .iOS, message: "TaskEntryManagerBase viewDidAppear")
    }
    
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        appLog.log(logger, logtype: .iOS, message: "TaskEntryManagerBase viewWillDisappear")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        appLog.log(logger, logtype: .iOS, message: "TaskEntryManagerBase viewDidDisappear")
    }
    
    
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        appLog.log(logger, logtype: .iOS, message: "TaskEntryManagerBase viewWillLayoutSubviews")
        
        pageViewController.view.frame = self.view.bounds
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appLog.log(logger, logtype: .iOS, message: "TaskEntryManagerBase viewDidLayoutSubviews")
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        appLog.log(logger, logtype: .iOS, message: "TaskEntryManagerBase didReceiveMemoryWarning")
    }

    /////////////////////////
    // SessionManager public API
    /////////////////////////

    func switchTo(newSessionIndex: Int) {
        appLog.log(logger, logtype: .iOS, message: "TaskEntryCreatorManagerBase.switchTo(new=\(newSessionIndex), current=\(currentSessionIndex)")
        if newSessionIndex != currentSessionIndex {
            if let newVC: TaskEntryCreatorBase = pageViewControllerAtIndex(newSessionIndex) {
                currentSessionIndex = newSessionIndex
                pageViewController.setViewControllers([newVC],
                    direction: .Forward,
                    animated: false,
                    completion: nil)
            }
        }
    }
    
    
    /////////////////////////
    // UIPageViewControllerDataSource
    /////////////////////////
    
    // Will be overridden by subclass
    func pageViewControllerAtIndex(index: Int) -> TaskEntryCreatorBase? {
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let vc = viewController as? TaskEntryCreatorBase {
            if let index = vc.sessionIndex {
                return pageViewControllerAtIndex(index-1)
            }
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let vc = viewController as? TaskEntryCreatorBase {
            if let index = vc.sessionIndex {
                return pageViewControllerAtIndex(index+1)
            }
        }
        return nil
    }

    /////////////////////////
    // TaskEntryCreatorDelegate
    /////////////////////////

    func taskEntryCreator(taskEntryCreator: TaskEntryCreator, willViewSessionIndex: Int) {
        appLog.log(logger, logtype: .iOS, message: "TaskEntryCreatorManagerBase:willViewSessionIndex{willview=\(willViewSessionIndex), current=\(currentSessionIndex)")
        if willViewSessionIndex != currentSessionIndex {
            delegate?.taskEntryCreatorManager(self, willChangeActiveSession: willViewSessionIndex)
        }
    }

}
