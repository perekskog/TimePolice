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

/*

- Skicka med ett closure isf "message", då kan väl meddelandet byggas enbart när det behövs?

*/

enum LogType {
	EnterExit,
	CoreData
}

class SystemLog {

    init() {
	}

	func log(logger: Logger, loglevel: LogType, message: String) {
		if excludeEntry(logger.getId(), loglevel) {
			return
		}

		let now = NSDate()
		let logEntry = "\(getStringNoDate(now)): \(logger.getEntry(message))"
		logger.appendEntry(logEntry)

		if logger.copyToConsole() {
			println(logEntry)
		}

		if logger.copyToPasteboard() {
	        UIPasteboard.generalPasteboard().string = logger.getContent()
		}
	}

	func excludeEntry(logger: Logger, loglevel: LogType) {
		return !includeEntry(logger, loglevel)
	}

	func includeEntry(logger: Logger, loglevel: LogeType) {
		return true
	}

}

/*

func log(prefix: String, message: () -> String) {
	let msg = message()
	println("\(prefix): \(msg))
}

log("pre") { "hej hopp" }
log("pre") { () in "hej hopp"}
let s1 = "god"
log("pre") { "hej \(s1) hopp" }

func log(prefix: String, message: String) {
	let msg = message()
	println("\(prefix): \(msg))
}

log("pre", "hej hopp")

*/

protocol Logger {
	func getEntry(message: String) -> String
	func appendEntry(entry: String)
	func getContent() -> String
	func reset()
	func copyToConsole() -> Bool
	func copyToPasteboard() -> Bool
	func getId() -> String
}

class BasicLogger: Logger {
	func getEntry(message: String) -> String {
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

	func getEntry(message: String) -> String {
		let entry = "\(locator): \(message)"
		return entry
	}

	func appendEntry(entry: String) {
		textview.text! += "\n\(entry)"
        let numberOfElements = count(textview.text)
        let range:NSRange = NSMakeRange(numberOfElements-1, 1)
        textview.scrollRangeToVisible(range)
	}

	func getContent() -> String {
		return textview.text
	}

    func reset() {
        textview.text = ""
    }

}

class StringLog: BasicLogger {

	var logString: String!
	var locator: String!

	init(logString: String, locator: String)
	{
		self.logString = logString
		self.locator = locator
	}

	func getEntry(message: String) -> String {
		let entry = "\(locator): \(message)"
		return entry
	}

	func appendEntry(entry: String) {
//        logString += "\n\(entry)"
	}

	func getContent() -> String {
		return logString
	}

	func reset() {
        logString = ""
    }

}

