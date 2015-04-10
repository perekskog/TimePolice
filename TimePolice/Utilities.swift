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

class TextViewLogger {
	class func log(textview: UITextView, message: String) {
        textview.text! += message
        let numberOfElements = count(textview.text)
        let range:NSRange = NSMakeRange(numberOfElements-1, 1)
        textview.scrollRangeToVisible(range)
        print(message)
	}
    class func reset(textview: UITextView) {
        textview.text = ""
    }
}