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

class SystemLog {
	var logger: Logger!
	var copyToConsole: Bool!
	var copyToPasteboard: Bool!

    init(logger: Logger, copyToConsole: Bool, copyToPasteboard: Bool) {
		self.logger = logger
		self.copyToConsole = copyToConsole
		self.copyToPasteboard = copyToPasteboard
	}

	func log(message: String) {
		let now = NSDate()
		let logEntry = "\(getStringNoDate(now)): logger.getEntry(message)"
		logger.appendEntry(logEntry)

		if copyToConsole==true {
			println(logEntry)
		}

		if copyToPasteboard==true {
	        UIPasteboard.generalPasteboard().string = logger.getContent()
		}
	}

	func reset() {
        logger.reset()
    }
}

protocol Logger {
	func getEntry(message: String) -> String
	func appendEntry(entry: String)
	func getContent() -> String
	func reset()
}

class TextViewLog {

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

class StringLog {

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

