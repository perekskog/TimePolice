//
//  MainVC.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-11-16.
//  Copyright © 2015 Per Ekskog. All rights reserved.
//

import UIKit
import CoreData

class MainVC: UIViewController,
    AppLoggerDataSource {

    let theme = BlackGreenTheme()


    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var templatesButton: UIButton!
    @IBOutlet var sessionsButton: UIButton!
    
    @IBOutlet var arrowView: UIImageView!
    @IBOutlet var exportButton: UIButton!
    @IBOutlet var settingsButton: UIButton!

    let label = UILabel()
    
    //---------------------------------------
    // MainVC - Lazy properties
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
    // MainVC - AppLoggerDataSource
    //---------------------------------------------

    func getLogDomain() -> String {
        return "MainVC"
    }


    //---------------------------------------------
    // MainVC - View lifecycle
    //---------------------------------------------

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewWillAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewWillDisappear")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidAppear")

        let (shouldPopupAlert, message) = TimePoliceModelUtils.verifyConstraints(moc)
        if shouldPopupAlert == true {
            let alertController = TimePoliceModelUtils.getConsistencyAlert(message, moc: moc)
            present(alertController, animated: true, completion: nil)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidDisappear")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        appLog.log(logger, logtype: .viewLifecycle, message: "viewWillLayoutSubviews")

        let width = self.view.frame.width
        let height = self.view.frame.height

        var textRect = CGRect(x: 0, y: height/4, width: width, height: 50)
        titleLabel.frame = textRect

        textRect.origin.y += height/5
        templatesButton.frame = textRect
        templatesButton.frame.origin.x -= arrowView.frame.size.width*1.2
        
        arrowView.frame.origin.x = templatesButton.frame.origin.x + (templatesButton.frame.size.width / 2)
        arrowView.frame.origin.y = templatesButton.frame.origin.y + templatesButton.frame.size.height

        textRect.origin.y += arrowView.frame.size.height*1.1
        sessionsButton.frame = textRect
        sessionsButton.frame.origin.x += arrowView.frame.size.width*1.2
        

        let padding = width * 0.05

        settingsButton.frame.origin.y = height - settingsButton.frame.size.height - padding
        settingsButton.frame.origin.x = padding

        exportButton.frame.origin.y = height - exportButton.frame.size.height - padding
        exportButton.frame.origin.x = width - exportButton.frame.size.width - padding

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidLayoutSubviews")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        appLog.log(logger, logtype: .viewLifecycle, message: "viewDidLoad")

        (self.view as! TimePoliceBGView).theme = theme
        
        label.text = "Hello, world!!!"
        self.view.addSubview(label)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        appLog.log(logger, logtype: .viewLifecycle, message: "didReceiveMemoryWarning")
    }



    //---------------------------------------------
    // MainVC - Segue handling
    //---------------------------------------------

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        appLog.log(logger, logtype: .enterExit, message: "prepareForSegue")

        if segue.identifier == "Exit" {
            // Nothing to prepare
        }
        if segue.identifier == "Templates" {
            if let vc = segue.destination as? MainTemplateListVC {
                vc.templateProjectName = templateProjectName
            }
        }
        if segue.identifier == "Sessions" {
            if let vc = segue.destination as? MainSessionListVC {
                vc.templateProjectName = templateProjectName
            }
        }
    }


    @IBAction func mainVC(_ unwindSegue: UIStoryboardSegue ) {
        appLog.log(logger, logtype: .enterExit, message: "mainVC")

    }
    
}
