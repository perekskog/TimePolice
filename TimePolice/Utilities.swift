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

class UtilitiesDate {

	class func getString(timeInterval: NSTimeInterval) -> String {
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

	class func getString(date: NSDate) -> String {
		let formatter = NSDateFormatter();
	    formatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("yyyyMMddhhmmss", options: 0, locale: NSLocale.currentLocale())
		let timeString = formatter.stringFromDate(date)
		return timeString
	}

	class func getStringNoDate(date: NSDate) -> String {
		let formatter = NSDateFormatter();
	    formatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("hhmmss", options: 0, locale: NSLocale.currentLocale())
		let timeString = formatter.stringFromDate(date)
		return timeString
	}

	class func getStringOnlyDay(date: NSDate) -> String {
		let formatter = NSDateFormatter();
	    formatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("dd", options: 0, locale: NSLocale.currentLocale())
		let timeString = formatter.stringFromDate(date)
		return timeString
	}

	class func getStringWithFormat(date: NSDate, format: String) -> String {
		let formatter = NSDateFormatter();
	    formatter.dateFormat = NSDateFormatter.dateFormatFromTemplate(format, options: 0, locale: NSLocale.currentLocale())
		let timeString = formatter.stringFromDate(date)
		return timeString
	}
}


// AppLog helper

class UtilitiesApplog {

	class func logDefault(logdomain: String, logtype: AppLogEntryType, message: String) {
		let appdelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
	 	var logger = appdelegate.defaultLogger
	 	logger.datasource = DefaultLogHelper(logdomain: logdomain)
	    (UIApplication.sharedApplication().delegate as! AppDelegate).appLog.log(logger, logtype: .Guard, message: message)
	}
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



class UtilitiesString {

    class func getWithoutProperties(source: String) -> String {
        var text = ""
        let x = source.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "#"))
        if x.count>=1 {
            text = x[0]
        }
        return text
    }
    
    class func getProperties(source: String) -> [String: String] {
        var propString: String?
        let parts = source.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "#"))
        if parts.count==2 {
            propString = parts[1]
        } else {
            return [:]
        }

        let propstring=propString!.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: ","))
        var props = [String: String]()
        for s in propstring {
        	let parts = s.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "="))
        	if parts.count == 2 {
        		props[parts[0]] = parts[1]
        	}
        }
        if props.count > 0 {
            return props
        } else {
            return [:]
        }
    }

    class func getStringFromProperties(props: [String: String]) -> String {
        var s = ""
        for (key, value) in props {
            s += "\(key)=\(value),"
        }
        s.removeAtIndex(s.endIndex.predecessor())
        return s
    }

    class func get2Parts(s: String, separator: NSCharacterSet) -> (String, String) {
        let strings = s.componentsSeparatedByCharactersInSet(separator)
        var s1 = ""
        var s2 = ""
        if strings.count >= 1 {
            s1 = strings[0]
        }
        if strings.count >= 2 {
            s2 = strings[1]
        }
        return (s1, s2)
    }

    class func dumpProperties(props: [String: String]) -> String {
    	var s = ""
    	for (key,value) in props {
    		s += "\n\(key) = \(value)"
    	}
    	return s
    }
}



class UtilitiesColor {
    
    class func string2color(text: String) -> UIColor {
        //var color: UIColor?
        let r = text[text.startIndex.advancedBy(0)]
        let red = hexchar2value(r)
        let g = text[text.startIndex.advancedBy(1)]
        let green = hexchar2value(g)
        let b = text[text.startIndex.advancedBy(2)]
        let blue = hexchar2value(b)
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    class func hexchar2value(ch: Character) -> CGFloat {
        switch ch {
        case "0": return 0.0
        case "1": return 1.0/16.0
        case "2": return 2.0/16.0
        case "3": return 3.0/16.0
        case "4": return 4.0/16.0
        case "5": return 5.0/16.0
        case "6": return 6.0/16.0
        case "7": return 7.0/16.0
        case "8": return 8.0/16.0
        case "9": return 9.0/16.0
        case "a": return 10.0/16.0
        case "b": return 11.0/16.0
        case "c": return 12.0/16.0
        case "d": return 13.0/16.0
        case "e": return 14.0/16.0
        case "f": return 15.0/16.0
        default: return 0.0
        }
    }
}

class UtilitiesImage {

    class func getImageWithColor(color: UIColor, width: CGFloat, height: CGFloat) -> UIImage {                    
        let rect = CGRectMake(0.0, 0.0, width, height);
        UIGraphicsBeginImageContext(rect.size);
        let context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context!, color.CGColor)
        CGContextFillRect(context!, rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return image!
    }

}

