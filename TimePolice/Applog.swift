//
//  Applog.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-09-23.
//  Copyright © 2015 Per Ekskog. All rights reserved.
//

import Foundation
import UIKit


enum AppLogEntryType {
    case EnterExit
    case CoreDataSnapshot
    case Debug
    case iOS
    case Resource
    case PeriodicCallback
    case AppLifecycle
    case ViewLifecycle
    case Guard
    case GUIAction
}

let allTracesIncluded: Set<AppLogEntryType> = [
    .EnterExit,
    .CoreDataSnapshot,
    .Debug,
    .iOS,
    .Resource,
    .PeriodicCallback,
    .AppLifecycle,
    .ViewLifecycle,
    .Guard,
    .GUIAction
]

let defaultTraces: Set<AppLogEntryType> = [
    .EnterExit,
    .CoreDataSnapshot,
    .Debug,
    .iOS,
    .Resource,
    .AppLifecycle,
    .ViewLifecycle,
    .Guard,
    .GUIAction
]

let noTraces: Set<AppLogEntryType> = [
]

protocol AppLogger {
    var datasource: AppLoggerDataSource? { get set }
    func localize(sender: AppLoggerDelegate, message: String)
    func appendEntry(entry: String)
    func getContent() -> String
    func reset()
    func getId() -> String
}

protocol AppLoggerDataSource {
    func getLogDomain() -> String
}

protocol AppLoggerDelegate {
    func entryLocalized(sender: AppLogger, localizedEntry: String)
}



protocol AppLogDelegate {
    func includeEntry(loggerId: String, logtype: AppLogEntryType) -> Bool
}



class AppLog: AppLoggerDelegate {

    var delegate: AppLogDelegate?

    var logString: String

    init() {
        logString = String()
    }

    func log(logger: AppLogger, logtype: AppLogEntryType, message: String) {
        guard let toBeIncluded = delegate?.includeEntry(logger.getId(), logtype: logtype) else {
            return
        }
        if toBeIncluded {
            doLog(logger, message: message)
        }
    }

    func log(logger: AppLogger, logtype: AppLogEntryType, message: () -> String) {
        guard let toBeIncluded = delegate?.includeEntry(logger.getId(), logtype: logtype) else {
            return
        }

        if toBeIncluded {
            doLog(logger, message: message())
        }
    }

    func doLog(logger: AppLogger, message: String) {
        logger.localize(self, message: message)
    }

    func entryLocalized(sender: AppLogger, localizedEntry: String) {
        let now = NSDate()
        let logEntry = "\(UtilitiesDate.getString(now)): \(localizedEntry)"
        sender.appendEntry(logEntry)
    }

}


class BasicLogger: AppLogger {

    var datasource: AppLoggerDataSource?
    
	func localize(sender: AppLoggerDelegate, message: String) {
        var entry = ""
        if let domain = datasource?.getLogDomain() {
            entry = "\(domain): \(message)"
        } else {
            entry = "(no domain): \(message)"
        }
        sender.entryLocalized(self, localizedEntry: entry)
	}

	func appendEntry(entry: String) {
		// Do nothing
	}

	func getContent() -> String {
		return ""
	}

	func reset() {
		// Do nothing
	}

	func getId() -> String {
		return "default"
	}
}

class TextViewLogger: BasicLogger {

	var textview: UITextView?

    override
	func appendEntry(entry: String) {
        guard let t = self.textview else {
            return
        }

        t.text! += "\n\(entry)"
        let numberOfElements = t.text.characters.count
        let range:NSRange = NSMakeRange(numberOfElements-1, 1)
        t.scrollRangeToVisible(range)
	}

    override
	func getContent() -> String {
        guard let t = self.textview else {
            return ""
        }

        return t.text
	}

    override
    func reset() {
        textview?.text = ""
    }

}

class StringLogger: BasicLogger {

	var logstring = String()

    override
	func appendEntry(entry: String) {
        logstring += "\n\(entry)"
	}

    override
	func getContent() -> String {
		return logstring
	}

    override
	func reset() {
        logstring = ""
    }

}

class AppLogLogger: BasicLogger {

    override
	func appendEntry(entry: String) {
        appLog.logString += "\n\(entry)"
	}

    override
	func getContent() -> String {
		return appLog.logString
	}

    override
	func reset() {
        appLog.logString = ""
    }

    lazy var appLog : AppLog = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.appLog        
    }()
}

class ConsoleLogger: BasicLogger {

    override
    func appendEntry(entry: String) {
        print("\(entry)")
    }

    override
    func getContent() -> String {
        return ""
    }

    override
    func reset() {
        // Do nothing
    }
}

class MultiLogger: AppLogger {
    
    var datasource: AppLoggerDataSource? {
        didSet {
            logger1.datasource = datasource
            logger2.datasource = datasource
            logger3.datasource = datasource
        }
    }
    
    var logger1 = BasicLogger()
    var logger2 = BasicLogger()
    var logger3 = BasicLogger()

    func localize(sender: AppLoggerDelegate, message: String) {
        logger1.localize(sender, message: message)
        logger2.localize(sender, message: message)
        logger3.localize(sender, message: message)
    }
    
    func appendEntry(entry: String) {
        logger1.appendEntry(entry)
        logger2.appendEntry(entry)
        logger3.appendEntry(entry)
    }
    
    func getContent() -> String {
        return ""
    }
    
    func reset() {
        logger1.reset()
        logger2.reset()
        logger3.reset()
    }
    
    func getId() -> String {
        return "default"
    }
}






