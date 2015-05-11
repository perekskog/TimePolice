//
//  EditWorkScrollableViewCOntroller.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-05-08.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

import UIKit

class EditWorkScrollableViewCOntroller: UIViewController {

    var logger: AppLogger?

    override func viewDidLoad() {
        super.viewDidLoad()

        logger = ApplogLog(locator: "EditWorkScrollableVC")
        
        appLog.log(logger!, logtype: .EnterExit, message: "viewDidLoad")

        var scrollViewRect = self.view.frame
        scrollViewRect.origin.y += 10
        scrollViewRect.origin.x += 10
        scrollViewRect.size.width -= 20
        scrollViewRect.size.height -= 150
        let scrollView = UIScrollView()
        scrollView.frame = scrollViewRect
        scrollView.contentSize = CGSizeMake(scrollViewRect.size.width, 2000)
        self.view.addSubview(scrollView)

        let exitRect2 = CGRect(origin: CGPoint(x: 0, y: 20), size: CGSize(width:scrollViewRect.size.width, height:30))
        let exitButton2 = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        exitButton2.frame = exitRect2
        exitButton2.backgroundColor = UIColor(red: 0.0, green: 0.7, blue: 0.0, alpha: 1.0)
        exitButton2.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        exitButton2.setTitle("EXIT", forState: UIControlState.Normal)
//        exitButton2.addTarget(self, action: "exit:", forControlEvents: UIControlEvents.TouchUpInside)
        scrollView.addSubview(exitButton2)

        let datePicker = UIDatePicker()
        addBelow(scrollView, reference: exitButton2, newView: datePicker)
        
        let exitRect = CGRect(origin: CGPoint(x: self.view.bounds.size.width - 80, y: self.view.bounds.size.height-45), size: CGSize(width:70, height:30))
        let exitButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        exitButton.frame = exitRect
        exitButton.backgroundColor = UIColor(red: 0.0, green: 0.7, blue: 0.0, alpha: 1.0)
        exitButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        exitButton.setTitle("EXIT", forState: UIControlState.Normal)
        exitButton.addTarget(self, action: "exit:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(exitButton)
    }
    
    func addBelow(view: UIView, reference: UIView, newView: UIView) {
        newView.frame.origin.y = reference.frame.origin.y + reference.frame.size.height
        view.addSubview(newView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        appLog.log(logger!, logtype: .EnterExit, message: "didReceiveMemoryWarning")
    }

    //-----------------------------------------
    // WorkListViewController- VC button actions
    //-----------------------------------------


    func exit(sender: UIButton) {
        appLog.log(logger!, logtype: .EnterExit, message: "exit")
        
        performSegueWithIdentifier("Exit", sender: self)
    }


    
    //----------------------------------------------------------------
    // EditWorkScrollableViewController - AppDelegate lazy properties
    //----------------------------------------------------------------
    
    lazy var appLog : AppLog = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.appLog
        }()

}
