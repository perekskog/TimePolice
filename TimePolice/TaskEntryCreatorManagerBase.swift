//
//  TaskEntryCreatorManagerBase.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-09-13.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

/* 

TODO

*/

import UIKit

protocol TaskEntryCreatorManagerDelegate {
    func taskEntryCreatorManager(taskEntryCreatorManager: TaskEntryCreatorManager, willChangeActiveSessionTo: Int)
}

protocol TaskEntryCreatorManagerDataSource {
    func taskEntryCreatorManager(taskEntryCreatorManager: TaskEntryCreatorManager, sessionForIndex: Int) -> Session?
}

protocol TaskEntryCreatorManager {
    var dataSource: TaskEntryCreatorManagerDataSource? {get set}
    var delegate: TaskEntryCreatorManagerDelegate? {get set}
    var currentSessionIndex: Int? {get set}
    var numberOfSessions: Int? {get set}

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
    var currentSessionIndex: Int?
    var numberOfSessions: Int?
    
    let pageViewController: UIPageViewController = TaskEntryCreatorManagerPageViewController()


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
        appLog.log(logger, logtype: .ViewLifecycle, message: "(...Base) viewDidLoad")
        
        pageViewController.dataSource = self
        
        guard let i = currentSessionIndex,
                let initialVC: TaskEntryCreatorBase = pageViewControllerAtIndex(i) else {
            appLog.log(logger, logtype: .Guard, message: "(...Base) guard fail in viewDidLoad")
            return
        }

        pageViewController.setViewControllers([initialVC],
            direction: .Forward,
            animated: false,
            completion: nil)
        pageViewController.delegate = self
        
        self.addChildViewController(pageViewController)
        self.view.addSubview(self.pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "(...Base) viewWillAppear")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "(...Base) viewDidAppear")
    }
    
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "(...Base) viewWillDisappear")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "(...Base) viewDidDisappear")
    }
    
    
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        appLog.log(logger, logtype: .ViewLifecycle, message: "(...Base) viewWillLayoutSubviews")
        
        pageViewController.view.frame = self.view.bounds
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appLog.log(logger, logtype: .ViewLifecycle, message: "(...Base) viewDidLayoutSubviews")
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        appLog.log(logger, logtype: .ViewLifecycle, message: "(...Base) didReceiveMemoryWarning")
    }

    /////////////////////////
    // TaskEntryCreator public API
    /////////////////////////

    func switchTo(newSessionIndex: Int) {
        appLog.log(logger, logtype: .EnterExit, message: "(...Base) switchTo(new=\(newSessionIndex), current=\(currentSessionIndex)")
        if newSessionIndex == currentSessionIndex {
            return
        }
        guard let newVC: TaskEntryCreatorBase = pageViewControllerAtIndex(newSessionIndex) else {
            appLog.log(logger, logtype: .Guard, message: "(...Base) guard fail in switchTo")
            return
        }
        currentSessionIndex = newSessionIndex
        pageViewController.setViewControllers([newVC],
            direction: .Forward,
            animated: false,
            completion: nil)
    }
    
    
    /////////////////////////
    // UIPageViewControllerDataSource
    /////////////////////////
    
    // Will be overridden by subclass
    func pageViewControllerAtIndex(index: Int) -> TaskEntryCreatorBase? {
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        appLog.log(logger, logtype: .EnterExit, message: "(...Base) viewControllerBeforeViewController")
        if let vc = viewController as? TaskEntryCreator {
            if let index = vc.sessionIndex {
                return pageViewControllerAtIndex(index-1)
            }
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        appLog.log(logger, logtype: .EnterExit, message: "(...Base) viewControllerAfterViewController")
        if let vc = viewController as? TaskEntryCreator {
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
        appLog.log(logger, logtype: .iOS, message: "(...Base) willViewSessionIndex{willview=\(willViewSessionIndex), current=\(currentSessionIndex)")
        if willViewSessionIndex != currentSessionIndex {
            delegate?.taskEntryCreatorManager(self, willChangeActiveSessionTo: willViewSessionIndex)
        }
    }

}
