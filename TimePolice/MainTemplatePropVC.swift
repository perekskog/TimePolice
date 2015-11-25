//
//  MainTemplatePropVC.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-11-16.
//  Copyright © 2015 Per Ekskog. All rights reserved.
//

import UIKit
import CoreData

class MainTemplatePropVC: UIViewController,
    AppLoggerDataSource {

    // Input data
    var template: String?
    var segue: String?

    // Output data
    var updatedTemplate: String?
    
    // Internal
    let textTemplate = UITextView(frame: CGRectZero)
    var spaceAtBottom = 0


    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }

    //---------------------------------------
    // MainSettingsVC - Lazy properties
    //---------------------------------------

    lazy var moc : NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
        }()

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
    // MainSettingsVC - AppLoggerDataSource
    //---------------------------------------------

    func getLogDomain() -> String {
        return "MainTemplatePropVC"
    }



    //---------------------------------------------
    // MainSettingsVC - View lifecycle
    //---------------------------------------------

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewWillDisappear")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewDidAppear")
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewDidDisappear")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewDidLoad")

        self.edgesForExtendedLayout = .None

        if let s = segue {
            switch s {
                case "AddTemplate": 
                    self.title = "Add template"
                case "EditTemplate": 
                    self.title = "Edit template"
                default:
                    self.title = "???"
            }
        }

        let buttonCancel = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancel:")
        self.navigationItem.leftBarButtonItem = buttonCancel
        let buttonSave = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: "save:")
        self.navigationItem.rightBarButtonItem = buttonSave

        textTemplate.text = "Lorem ipsum"
        if let t = template {
            textTemplate.text = t
        }
        textTemplate.textColor = UIColor.blackColor()
        textTemplate.backgroundColor = UIColor.whiteColor()
        textTemplate.font = UIFont(name: textTemplate.font!.fontName, size: 16)
        self.view.addSubview(textTemplate)

        self.view.backgroundColor = UIColor.grayColor()

        spaceAtBottom = 20

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewWillAppear")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewWillLayoutSubviews")

        let width = CGRectGetWidth(self.view.frame)
        let height = CGRectGetHeight(self.view.frame)

        textTemplate.frame = CGRectMake(10, 10, width-20, height-CGFloat(spaceAtBottom))
        // lastview = textTemplate


    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appLog.log(logger, logtype: .ViewLifecycle, message: "viewDidLayoutSubviews")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        appLog.log(logger, logtype: .ViewLifecycle, message: "didReceiveMemoryWarning")
    }

    // GUI actions

    func cancel(sender: UIButton) {
        performSegueWithIdentifier("CancelTemplateProp", sender: self)
    }
    
    func save(sender: UIButton) {
        updatedTemplate = textTemplate.text
        performSegueWithIdentifier("SaveTemplateProp", sender: self)
    }

    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            appLog.log(logger, logtype: .Debug, message: "will show keyboard, height=\(keyboardSize.height), textheight is \(self.textTemplate.frame.size.height)")
//            self.textTemplate.frame.size.height -= keyboardSize.height
            spaceAtBottom = 20 + Int(keyboardSize.height)
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            appLog.log(logger, logtype: .Debug, message: "will hide keyboard, height=\(keyboardSize.height), textheight is \(self.textTemplate.frame.size.height)")
//            self.textTemplate.frame.size.height += keyboardSize.height
            spaceAtBottom = 20
        }
    }
}

