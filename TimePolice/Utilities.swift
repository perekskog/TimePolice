//
//  Utilities.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-02-03.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

/*

TODO

*/


import Foundation
import UIKit
import CoreData

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

// AppLog helper

func logDefault(logdomain: String, logtype: AppLogEntryType, message: String) {
	let appdelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
 	var logger = appdelegate.defaultLogger
 	logger.datasource = DefaultLogHelper(logdomain: logdomain)
    (UIApplication.sharedApplication().delegate as! AppDelegate).appLog.log(logger, logtype: .Guard, message: message)
}

class DefaultLogHelper: AppLoggerDataSource {
	var logDomain: String
	init(logdomain: String) {
		self.logDomain = logdomain
	}
    func getLogDomain() -> String {
        return self.logDomain
    }
}

