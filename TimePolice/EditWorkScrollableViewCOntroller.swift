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
        
        var lastView: UIView

        let width = CGRectGetWidth(self.view.frame)

        var scrollViewRect = self.view.frame
        scrollViewRect.origin.y += 10
        scrollViewRect.size.height -= 150
        let scrollView = UIScrollView()
        scrollView.frame = scrollViewRect
        scrollView.contentSize = CGSizeMake(width, 2000)
        self.view.addSubview(scrollView)

//        let exitRect2 = CGRect(origin: CGPoint(x: 0, y: 20), size: CGSize(width:scrollViewRect.size.width, height:30))
        let exitRect2 = CGRectMake(0, 20, width, 30)
        let exitButton2 = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        exitButton2.frame = exitRect2
        exitButton2.backgroundColor = UIColor(red: 0.0, green: 0.7, blue: 0.0, alpha: 1.0)
        exitButton2.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        exitButton2.setTitle("EXIT", forState: UIControlState.Normal)
        scrollView.addSubview(exitButton2)
        lastView = exitButton2

        // Title - change

        let labelTitle = UILabel()
        labelTitle.text = "Change workitem"
        lastview = labelTitle

        // Starttime

        let labelStart = UILabel()
        labelStart.text = "Start"
        lastview = addViewCenteredBelow(scrollView, lastview: lastview, newView: labelStart)

        let datepickerStart = UIDatePicker()
        lastview = addViewCenteredBelow(scrollView, lastView: lastView, newView: datepickerStart)
        
        // Stoptime

        let labelStop = UILabel()
        labelStop.text = "Stop"
        lastview = addViewCenteredBelow(scrollView, lastview: lastview, newView: labelStop)

        let datepickerStart = UIDatePicker()
        addViewBelow(scrollView, lastView: lastView, newView: datepickerStop)

        // Task

        let labelTask = UILabel()
        labelTask.text = "New task"
        lastview = addViewCenteredBelow(scrollView, lastview: lastview, newView: labelTask)

        // A table



        // Title - delete

        let labelDelete = UILabel()
        labelDelete.text = "Delete workitem"
        lastview = addViewCenteredBelow(scrollView, lastview: lastview, newView: labelDelete)

    }
    
    func addViewCenteredBelow(view: UIView, lastView: UIView, newView: UIView) {
        newView.frame.origin.y = CGRectGetMaxY(reference.frame)
        newView.center.x = CGRectGetWidth(view.frame)/2
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
