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
    TaskEntryCreatorManager,
    TaskEntryCreatorDelegate {
    
    var dataSource: TaskEntryCreatorManagerDataSource?
    var delegate: TaskEntryCreatorManagerDelegate?
    
    let pageViewController: UIPageViewController = TaskEntryCreatorManagerPageViewController()

    var currentSessionIndex: Int?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        println("TaskEntryManagerBase viewDidLoad")
        
        pageViewController.dataSource = self
        
        if let i = currentSessionIndex {
            if let initialVC: TaskEntryCreatorBase = pageViewControllerAtIndex(i) {
                let viewControllers: NSArray = [initialVC]
                pageViewController.setViewControllers(viewControllers as [AnyObject],
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
        println("TaskEntryManagerBase viewWillAppear")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println("TaskEntryManagerBase viewDidAppear")
    }
    
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        println("TaskEntryManagerBase viewWillDisappear")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        println("TaskEntryManagerBase viewDidDisappear")
    }
    
    
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        println("TaskEntryManagerBase viewWillLayoutSubviews")
        
        pageViewController.view.frame = self.view.bounds
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        println("TaskEntryManagerBase viewDidLayoutSubviews")
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        println("TaskEntryManagerBase didReceiveMemoryWarning")
    }

    /////////////////////////
    // SessionManager public API
    /////////////////////////

    func switchTo(newSessionIndex: Int) {
        println("TaskEntryCreatorManagerBase.switchTo(new=\(newSessionIndex), current=\(currentSessionIndex)")
        if newSessionIndex != currentSessionIndex {
            if let newVC: TaskEntryCreatorBase = pageViewControllerAtIndex(newSessionIndex) {
                currentSessionIndex = newSessionIndex
                let viewControllers: NSArray = [newVC]
                pageViewController.setViewControllers(viewControllers as [AnyObject],
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
        println("TaskEntryCreatorManagerBase:willViewSessionIndex{willview=\(willViewSessionIndex), current=\(currentSessionIndex)")
        if willViewSessionIndex != currentSessionIndex {
            delegate?.taskEntryCreatorManager(self, willChangeActiveSession: willViewSessionIndex)
        }
    }

}
