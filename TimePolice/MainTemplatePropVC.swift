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
    let textTemplate = UITextView(frame: CGRect.zero)
    var spaceAtBottom = 0
    let padding = 10
    let buttonInstructions = UIButton(type: UIButtonType.system)


    deinit {
        NotificationCenter.default.removeObserver(self);
    }

    //---------------------------------------
    // MainTemplatePropVC - Lazy properties
    //---------------------------------------

    lazy var moc : NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
        }()

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
    // MainTemplatePropVC - AppLoggerDataSource
    //---------------------------------------------

    func getLogDomain() -> String {
        return "MainTemplatePropVC"
    }



    //---------------------------------------------
    // MainTemplatePropVC - View lifecycle
    //---------------------------------------------

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewWillDisappear")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidAppear")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidDisappear")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidLoad")

        self.edgesForExtendedLayout = UIRectEdge()

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

        let buttonCancel = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(MainTemplatePropVC.cancel(_:)))
        self.navigationItem.leftBarButtonItem = buttonCancel
        let buttonSave = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(MainTemplatePropVC.save(_:)))
        self.navigationItem.rightBarButtonItem = buttonSave
        

        textTemplate.text = ""
        if let t = template {
            textTemplate.text = t
        }
        textTemplate.textColor = UIColor.black
        textTemplate.backgroundColor = UIColor.white
        textTemplate.font = UIFont.systemFont(ofSize: 16)
        self.view.addSubview(textTemplate)
        
        buttonInstructions.setTitleColor(UIColor.blue, for: UIControlState())
        buttonInstructions.setTitle("How to write a template", for: UIControlState())
        buttonInstructions.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(themeBigTextSize))
        buttonInstructions.addTarget(self, action: #selector(MainTemplatePropVC.displayTemplateInstructions(_:)), for: UIControlEvents.touchUpInside)

        self.view.addSubview(buttonInstructions)

        self.view.backgroundColor = UIColor.lightGray

        spaceAtBottom = 20

        NotificationCenter.default.addObserver(self, selector: #selector(MainTemplatePropVC.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(MainTemplatePropVC.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewWillAppear")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        appLog.log(logger, logtype: .viewLifecycle, message: "viewWillLayoutSubviews")

        let width = self.view.frame.width
        let height = self.view.frame.height

        let textTemplateHeight = height - CGFloat(spaceAtBottom) - 30
        appLog.log(logger, logtype: .debug, message: "textTemplateHeight=\(textTemplateHeight)")
        textTemplate.frame = CGRect(x: 10, y: 10, width: width-20, height: textTemplateHeight)
        
        buttonInstructions.frame.origin.y = textTemplate.frame.maxY
        buttonInstructions.frame.size.height = 30
        buttonInstructions.frame.size.width = width - 20
        buttonInstructions.center.x = width/2
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidLayoutSubviews")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        appLog.log(logger, logtype: .viewLifecycle, message: "didReceiveMemoryWarning")
    }

    // GUI actions

    func cancel(_ sender: UIButton) {
        appLog.log(logger, logtype: .enterExit, message: "cancel")
        appLog.log(logger, logtype: .guiAction, message: "cancel")

        performSegue(withIdentifier: "CancelTemplateProp", sender: self)
    }
    
    func save(_ sender: UIButton) {
        appLog.log(logger, logtype: .enterExit, message: "save")
        appLog.log(logger, logtype: .guiAction, message: "save")

        let st = SessionTemplate()
        st.parseTemplate(textTemplate.text)
        if(st.templateOk) {
            appLog.log(logger, logtype: .debug, message: "Syntax check ok")
            updatedTemplateSrc = textTemplate.text
            parsedUpdatedTemplate = st
            performSegue(withIdentifier: "SaveTemplateProp", sender: self)
        } else {
            appLog.log(logger, logtype: .debug, message: "Check template NOT ok (\(st.errorMessage))")
            // Display alert with error message, only have an "Ok" or "dismiss" button.
            let alertController = getSyntaxErrorAlert("Problems with template", errorMessage: st.errorMessage)
            present(alertController, animated: true, completion: nil)
        }
    }

    func getSyntaxErrorAlert(_ prompt: String, errorMessage: String) -> UIAlertController
    {
        let alertContoller = UIAlertController(title: "\(prompt)?", message: errorMessage,
            preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertContoller.addAction(ok)
        return alertContoller
    }

    func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            appLog.log(logger, logtype: .debug, message: "will show keyboard, height=\(keyboardSize.height), textheight is \(self.textTemplate.frame.size.height)")
            spaceAtBottom = 20 + Int(keyboardSize.height)
        }
        let width = self.view.frame.width
        let height = self.view.frame.height
        let textTemplateHeight = height-CGFloat(spaceAtBottom)
        appLog.log(logger, logtype: .debug, message: "textTemplateHeight=\(textTemplateHeight)")
        textTemplate.frame = CGRect(x: 10, y: 10, width: width-20, height: textTemplateHeight)
    }

    func keyboardWillHide(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            appLog.log(logger, logtype: .debug, message: "will hide keyboard, height=\(keyboardSize.height), textheight is \(self.textTemplate.frame.size.height)")
            spaceAtBottom = 20
        }
        let width = self.view.frame.width
        let height = self.view.frame.height
        let textTemplateHeight = height-CGFloat(spaceAtBottom)
        appLog.log(logger, logtype: .debug, message: "textTemplateHeight=\(textTemplateHeight)")
        textTemplate.frame = CGRect(x: 10, y: 10, width: width-20, height: textTemplateHeight)
    }
    
    func displayTemplateInstructions(_ sender: UIButton)
    {
        appLog.log(logger, logtype: .enterExit, message: "displayTemplateInstructions")
        appLog.log(logger, logtype: .guiAction, message: "displayTemplateInstructions")
        
        if let u = URL(string: "http://timepolice.perekskog.se/getstarted.html#templates")
        {
            UIApplication.shared.openURL(u)
        }
    }
}

