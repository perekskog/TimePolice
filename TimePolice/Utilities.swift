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





enum LogType {
	case EnterExit
	case CoreData
	case Debug
}

class SystemLog {

    init() {
	}

	func log(logger: Logger, loglevel: LogType, message: String) {
		if excludeEntry(logger.getId(), loglevel: loglevel) {
			return
		}

		doLog(logger, message: message)
	}

	func log(logger: Logger, loglevel: LogType, message: () -> String) {
		if excludeEntry(logger.getId(), loglevel: loglevel) {
			return
		}

		doLog(logger, message: message())
	}

	func doLog(logger: Logger, message: String) {
		let now = NSDate()
		let logEntry = "\(getString(now)): \(logger.localize(message))"
		logger.appendEntry(logEntry)

		if logger.copyToConsole() {
			println(logEntry)
		}

		if logger.copyToPasteboard() {
	        UIPasteboard.generalPasteboard().string = logger.getContent()
		}
	}


	func excludeEntry(loggerId: String, loglevel: LogType) -> Bool {
		return !includeEntry(loggerId, loglevel: loglevel)
	}

	func includeEntry(loggerId: String, loglevel: LogType) -> Bool {
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


*/

protocol Logger {
	func localize(message: String) -> String
	func appendEntry(entry: String)
	func getContent() -> String
	func reset()
	func copyToConsole() -> Bool
	func copyToPasteboard() -> Bool
	func getId() -> String
}

class BasicLogger: Logger {
	func localize(message: String) -> String {
		return ""
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
	func localize(message: String) -> String {
		let entry = "\(locator): \(message)"
		return entry
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

	init(logstring: String, locator: String)
	{
		self.logstring = logstring
		self.locator = locator
	}

    override
	func localize(message: String) -> String {
		let entry = "\(locator): \(message)"
		return entry
	}

    override
	func appendEntry(entry: String) {
        logstring! += "\n\(entry)"
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

