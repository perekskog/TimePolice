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
    func taskEntryCreatorManager(_ taskEntryCreatorManager: TaskEntryCreatorManager, willChangeActiveSessionTo: Int)
}

protocol TaskEntryCreatorManagerDataSource {
    func taskEntryCreatorManager(_ taskEntryCreatorManager: TaskEntryCreatorManager, sessionForIndex: Int) -> Session?
}

protocol TaskEntryCreatorManager {
    var dataSource: TaskEntryCreatorManagerDataSource? {get set}
    var delegate: TaskEntryCreatorManagerDelegate? {get set}
    var currentSessionIndex: Int? {get set}
    var numberOfSessions: Int? {get set}

    func switchTo(_ newSessionIndex: Int)
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
        appLog.log(logger, logtype: .viewLifecycle, message: "(...Base) viewDidLoad")
        
        pageViewController.dataSource = self
        
        guard let i = currentSessionIndex,
                let initialVC: TaskEntryCreatorBase = pageViewControllerAtIndex(i) else {
            appLog.log(logger, logtype: .guard, message: "(...Base) guard fail in viewDidLoad")
            return
        }

        pageViewController.setViewControllers([initialVC],
            direction: .forward,
            animated: false,
            completion: nil)
        pageViewController.delegate = self
        
        self.addChildViewController(pageViewController)
        self.view.addSubview(self.pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "(...Base) viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "(...Base) viewDidAppear")
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "(...Base) viewWillDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "(...Base) viewDidDisappear")
    }
    
    
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        appLog.log(logger, logtype: .viewLifecycle, message: "(...Base) viewWillLayoutSubviews")
        
        pageViewController.view.frame = self.view.bounds
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appLog.log(logger, logtype: .viewLifecycle, message: "(...Base) viewDidLayoutSubviews")
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        appLog.log(logger, logtype: .viewLifecycle, message: "(...Base) didReceiveMemoryWarning")
    }

    /////////////////////////
    // TaskEntryCreator public API
    /////////////////////////

    func switchTo(_ newSessionIndex: Int) {
        appLog.log(logger, logtype: .enterExit, message: "(...Base) switchTo(new=\(newSessionIndex), current=\(String(describing: currentSessionIndex))")
        if newSessionIndex == currentSessionIndex {
            return
        }
        guard let newVC: TaskEntryCreatorBase = pageViewControllerAtIndex(newSessionIndex) else {
            appLog.log(logger, logtype: .guard, message: "(...Base) guard fail in switchTo")
            return
        }
        currentSessionIndex = newSessionIndex
        pageViewController.setViewControllers([newVC],
            direction: .forward,
            animated: false,
            completion: nil)
    }
    
    
    /////////////////////////
    // UIPageViewControllerDataSource
    /////////////////////////
    
    // Will be overridden by subclass
    func pageViewControllerAtIndex(_ index: Int) -> TaskEntryCreatorBase? {
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        appLog.log(logger, logtype: .enterExit, message: "(...Base) viewControllerBeforeViewController")
        if let vc = viewController as? TaskEntryCreator {
            if let index = vc.sessionIndex {
                return pageViewControllerAtIndex(index-1)
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        appLog.log(logger, logtype: .enterExit, message: "(...Base) viewControllerAfterViewController")
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

    func taskEntryCreator(_ taskEntryCreator: TaskEntryCreator, willViewSessionIndex: Int) {
        appLog.log(logger, logtype: .iOS, message: "(...Base) willViewSessionIndex{willview=\(willViewSessionIndex), current=\(String(describing: currentSessionIndex))")
        if willViewSessionIndex != currentSessionIndex {
            delegate?.taskEntryCreatorManager(self, willChangeActiveSessionTo: willViewSessionIndex)
        }
    }

}
