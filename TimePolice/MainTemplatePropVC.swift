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
    var updatedTemplateSrc: String?
    var parsedUpdatedTemplate: SessionTemplate?
    
    // Internal
    let textTemplate = UITextView(frame: CGRectZero)
    var spaceAtBottom = 0


    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }

    //---------------------------------------
    // MainTemplatePropVC - Lazy properties
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
    // MainTemplatePropVC - AppLoggerDataSource
    //---------------------------------------------

    func getLogDomain() -> String {
        return "MainTemplatePropVC"
    }



    //---------------------------------------------
    // MainTemplatePropVC - View lifecycle
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

        let buttonCancel = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MainTemplatePropVC.cancel(_:)))
        self.navigationItem.leftBarButtonItem = buttonCancel
        let buttonSave = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MainTemplatePropVC.save(_:)))
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

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainTemplatePropVC.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainTemplatePropVC.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
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

        let textTemplateHeight = height-CGFloat(spaceAtBottom)
        appLog.log(logger, logtype: .Debug, message: "textTemplateHeight=\(textTemplateHeight)")
        textTemplate.frame = CGRectMake(10, 10, width-20, textTemplateHeight)

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
        appLog.log(logger, logtype: .EnterExit, message: "cancel")
        appLog.log(logger, logtype: .GUIAction, message: "cancel")

        performSegueWithIdentifier("CancelTemplateProp", sender: self)
    }
    
    func save(sender: UIButton) {
        appLog.log(logger, logtype: .EnterExit, message: "save")
        appLog.log(logger, logtype: .GUIAction, message: "save")

        let st = SessionTemplate()
        st.parseTemplate(textTemplate.text)
        if(st.templateOk) {
            appLog.log(logger, logtype: .Debug, message: "Syntax check ok")
            updatedTemplateSrc = textTemplate.text
            parsedUpdatedTemplate = st
            performSegueWithIdentifier("SaveTemplateProp", sender: self)
        } else {
            appLog.log(logger, logtype: .Debug, message: "Check template NOT ok (\(st.errorMessage))")
            // Display alert with error message, only have an "Ok" or "dismiss" button.
            let alertController = getSyntaxErrorAlert("Problems with template", errorMessage: st.errorMessage)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }

    func getSyntaxErrorAlert(prompt: String, errorMessage: String) -> UIAlertController
    {
        let alertContoller = UIAlertController(title: "\(prompt)?", message: errorMessage,
            preferredStyle: .Alert)
        let ok = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertContoller.addAction(ok)
        return alertContoller
    }

    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            appLog.log(logger, logtype: .Debug, message: "will show keyboard, height=\(keyboardSize.height), textheight is \(self.textTemplate.frame.size.height)")
            spaceAtBottom = 20 + Int(keyboardSize.height)
        }
        let width = CGRectGetWidth(self.view.frame)
        let height = CGRectGetHeight(self.view.frame)
        let textTemplateHeight = height-CGFloat(spaceAtBottom)
        appLog.log(logger, logtype: .Debug, message: "textTemplateHeight=\(textTemplateHeight)")
        textTemplate.frame = CGRectMake(10, 10, width-20, textTemplateHeight)
    }

    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            appLog.log(logger, logtype: .Debug, message: "will hide keyboard, height=\(keyboardSize.height), textheight is \(self.textTemplate.frame.size.height)")
            spaceAtBottom = 20
        }
        let width = CGRectGetWidth(self.view.frame)
        let height = CGRectGetHeight(self.view.frame)
        let textTemplateHeight = height-CGFloat(spaceAtBottom)
        appLog.log(logger, logtype: .Debug, message: "textTemplateHeight=\(textTemplateHeight)")
        textTemplate.frame = CGRectMake(10, 10, width-20, textTemplateHeight)
    }
}

