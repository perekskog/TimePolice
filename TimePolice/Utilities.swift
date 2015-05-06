//
//  Utilities.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-02-03.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

import Foundation
import UIKit

func getString(timeInterval: NSTimeInterval) -> String {
    let h = Int(timeInterval / 3600)
	let m = (Int(timeInterval) - h*3600) / 60
	let s = Int(timeInterval) - h*3600 - m*60
	var time: String = "\(h):"
	if m < 10 {
		time += "0\(m):"
	} else {
		time += "\(m):"
	}
	if s < 10 {
		time += "0\(s)"
	} else {
		time += "\(s)"
	}
    return time
}

func getString(date: NSDate) -> String {
	let formatter = NSDateFormatter();
    formatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("yyyyMMddhhmmss", options: 0, locale: NSLocale.currentLocale())
	let timeString = formatter.stringFromDate(date)
	return timeString
}

func getStringNoDate(date: NSDate) -> String {
	let formatter = NSDateFormatter();
    formatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("hhmmss", options: 0, locale: NSLocale.currentLocale())
	let timeString = formatter.stringFromDate(date)
	return timeString
}


class TextViewLogger {
	class func log(statusView: UITextView, message: String) {
		statusView.text! += "\n\(message)"
        let numberOfElements = count(statusView.text)
        let range:NSRange = NSMakeRange(numberOfElements-1, 1)
        statusView.scrollRangeToVisible(range)
	    UIPasteboard.generalPasteboard().string = statusView.text
	}
}



var appLogString = String()

enum AppLogType {
	case EnterExit
	case CoreData
	case Debug
}

class AppLog: AppLoggerDelegate {

	var logString: String!

    init() {
    	logString = String()
	}

	func log(logger: AppLogger, loglevel: AppLogType, message: String) {
		if excludeEntry(logger.getId(), loglevel: loglevel) {
			return
		}

		doLog(logger, message: message)
	}

	func log(logger: AppLogger, loglevel: AppLogType, message: () -> String) {
		if excludeEntry(logger.getId(), loglevel: loglevel) {
			return
		}

		doLog(logger, message: message())
	}

	func doLog(logger: AppLogger, message: String) {
		logger.localize(self, message: message)
	}

	func entryLocalized(sender: AppLogger, localizedEntry: String) {
		let now = NSDate()
		let logEntry = "\(getString(now)): \(localizedEntry)"
		sender.appendEntry(logEntry)

		if sender.copyToConsole() {
			println(logEntry)
		}

		if sender.copyToPasteboard() {
	        UIPasteboard.generalPasteboard().string = sender.getContent()
		}		
	}


	func excludeEntry(loggerId: String, loglevel: AppLogType) -> Bool {
		return !includeEntry(loggerId, loglevel: loglevel)
	}

	func includeEntry(loggerId: String, loglevel: AppLogType) -> Bool {
		return true
	}

}

/*

From playground:
func log(prefix: String, message: () -> String) {
    let msg = message()
    println("\(prefix): \(msg)")
}

log("pre") { "hej hopp" }
let s1 = "god"
log("pre") { "hej \(s1) hopp" }

Examples:
        appLog.log(logger!, loglevel: .Debug, message: "viewDidLoad")
        appLog.log(logger!, loglevel: .Debug) { "viewDidLoad2" }


*/

protocol AppLoggerDelegate {
	func entryLocalized(sender: AppLogger, localizedEntry: String)
}

protocol AppLogger {
	func localize(sender: AppLoggerDelegate, message: String)
	func appendEntry(entry: String)
	func getContent() -> String
	func reset()
	func copyToConsole() -> Bool
	func copyToPasteboard() -> Bool
	func getId() -> String
}

class BasicLogger: AppLogger {
	func localize(sender: AppLoggerDelegate, message: String) {
        sender.entryLocalized(self, localizedEntry: message)
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

	func copyToConsole() -> Bool {
		return false
	}

	func copyToPasteboard() -> Bool {
		return false
	}

	func getId() -> String {
		return "default"
	}
}

class TextViewLog: BasicLogger {

	var textview: UITextView!
	var locator: String!

	init(textview: UITextView, locator: String)
	{
		self.textview = textview
		self.locator = locator
	}

    override
	func localize(sender: AppLoggerDelegate, message: String) {
		let entry = "\(locator): \(message)"
		sender.entryLocalized(self, localizedEntry: entry)
	}

    override
	func appendEntry(entry: String) {
		textview.text! += "\n\(entry)"
        let numberOfElements = count(textview.text)
        let range:NSRange = NSMakeRange(numberOfElements-1, 1)
        textview.scrollRangeToVisible(range)
	}

    override
	func getContent() -> String {
		return textview.text
	}

    override
    func reset() {
        textview.text = ""
    }

}

class StringLog: BasicLogger {

	var logstring: String!
	var locator: String!

	init(locator: String)
	{
		self.logstring = String()
		self.locator = locator
	}

    override
	func localize(sender: AppLoggerDelegate, message: String) {
		let entry = "\(locator): \(message)"
		sender.entryLocalized(self, localizedEntry: entry)
	}

    override
	func appendEntry(entry: String) {
        logstring! += "\n\(entry)"
        println()
        println("entry=\(entry)")
        println("logstring=\(logstring)")
        println()
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

class ApplogLog: BasicLogger {

	var locator: String!

	init(locator: String)
	{
		self.locator = locator
	}

    override
	func localize(sender: AppLoggerDelegate, message: String) {
		let entry = "\(locator): \(message)"
		sender.entryLocalized(self, localizedEntry: entry)
	}

    override
	func appendEntry(entry: String) {
        appLogString += "\n\(entry)"
        println()
        println("entry=\(entry)")
        println("appLogString=\(appLogString)")
        println()
	}

    override
	func getContent() -> String {
		return appLogString
	}

    override
	func reset() {
        appLogString = ""
    }

}

class MultiLog: BasicLogger {
	var logger1: AppLogger?
	var logger2: AppLogger?

	var locator: String!

	init(locator: String) {
		self.locator = locator
	}

	override
	func localize(sender: AppLoggerDelegate, message: String) {
		logger1?.localize(sender, message: message)
		logger2?.localize(sender, message: message)
	}

    override
	func appendEntry(entry: String) {
        logger1?.appendEntry(entry)
        logger2?.appendEntry(entry)
	}

    override
	func reset() {
        logger1?.reset()
        logger2?.reset()
    }

}

