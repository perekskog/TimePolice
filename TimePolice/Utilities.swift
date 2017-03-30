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

	class func getString(_ timeInterval: TimeInterval) -> String {
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

	class func getString(_ date: Date) -> String {
		let formatter = DateFormatter();
	    formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMddhhmmss", options: 0, locale: Locale.current)
		let timeString = formatter.string(from: date)
		return timeString
	}

	class func getStringNoDate(_ date: Date) -> String {
		let formatter = DateFormatter();
	    formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "hhmmss", options: 0, locale: Locale.current)
		let timeString = formatter.string(from: date)
		return timeString
	}

	class func getStringOnlyDay(_ date: Date) -> String {
		let formatter = DateFormatter();
	    formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "dd", options: 0, locale: Locale.current)
		let timeString = formatter.string(from: date)
		return timeString
	}

	class func getStringWithFormat(_ date: Date, format: String) -> String {
		let formatter = DateFormatter();
	    formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: format, options: 0, locale: Locale.current)
		let timeString = formatter.string(from: date)
		return timeString
	}
}


// AppLog helper

class UtilitiesApplog {

	class func logDefault(_ logdomain: String, logtype: AppLogEntryType, message: String) {
		let appdelegate = (UIApplication.shared.delegate as! AppDelegate)
	 	var logger = appdelegate.defaultLogger
	 	logger.datasource = DefaultLogHelper(logdomain: logdomain)
	    (UIApplication.shared.delegate as! AppDelegate).appLog.log(logger, logtype: .guard, message: message)
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

    class func getWithoutProperties(_ source: String) -> String {
        var text = ""
        let x = source.components(separatedBy: CharacterSet(charactersIn: "#"))
        if x.count>=1 {
            text = x[0]
        }
        return text
    }
    
    class func getProperties(_ source: String) -> [String: String] {
        var propString: String?
        let parts = source.components(separatedBy: CharacterSet(charactersIn: "#"))
        if parts.count==2 {
            propString = parts[1]
        } else {
            return [:]
        }

        let propstring=propString!.components(separatedBy: CharacterSet(charactersIn: ","))
        var props = [String: String]()
        for s in propstring {
        	let parts = s.components(separatedBy: CharacterSet(charactersIn: "="))
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

    class func getStringFromProperties(_ props: [String: String]) -> String {
        var s = ""
        for (key, value) in props {
            s += "\(key)=\(value),"
        }
        s.remove(at: s.characters.index(before: s.endIndex))
        return s
    }

    class func get2Parts(_ s: String, separator: CharacterSet) -> (String, String) {
        let strings = s.components(separatedBy: separator)
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

    class func dumpProperties(_ props: [String: String]) -> String {
    	var s = ""
    	for (key,value) in props {
    		s += "\n\(key) = \(value)"
    	}
    	return s
    }
}



class UtilitiesColor {
    
    class func string2color(_ text: String) -> UIColor {
        //var color: UIColor?
        let r = text[text.characters.index(text.startIndex, offsetBy: 0)]
        let red = hexchar2value(r)
        let g = text[text.characters.index(text.startIndex, offsetBy: 1)]
        let green = hexchar2value(g)
        let b = text[text.characters.index(text.startIndex, offsetBy: 2)]
        let blue = hexchar2value(b)
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    class func hexchar2value(_ ch: Character) -> CGFloat {
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

    class func getImageWithColor(_ color: UIColor, width: CGFloat, height: CGFloat) -> UIImage {                    
        let rect = CGRect(x: 0.0, y: 0.0, width: width, height: height);
        UIGraphicsBeginImageContext(rect.size);
        let context = UIGraphicsGetCurrentContext();
        context!.setFillColor(color.cgColor)
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return image!
    }

}

