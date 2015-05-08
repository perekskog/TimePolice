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

        
        let exitRect = CGRect(origin: CGPoint(x: self.view.bounds.size.width - 80, y: self.view.bounds.size.height-45), size: CGSize(width:70, height:30))
        let exitButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        exitButton.frame = exitRect
        exitButton.backgroundColor = UIColor(red: 0.0, green: 0.7, blue: 0.0, alpha: 1.0)
        exitButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        exitButton.setTitle("EXIT", forState: UIControlState.Normal)
        exitButton.addTarget(self, action: "exit:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(exitButton)
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
