//
//  SessionTemplate.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-11-10.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

/*

TODO


*/

import UIKit

/**
Utility function to parse a string defining a template.
 - todo:
*/

class SessionTemplate {
    var session: (String, [String: String]) = ("", [:])
    var tasks: [(String, [String: String])] = []

    /**
    Parse a string to be able to store a session template.
    - parameter string: A string defining the template
    */
	func parseTemplate(string: String) {
        tasks = []
        var lines: [String] = string.componentsSeparatedByString("\n")
		if lines.count == 0 {
			return
		}

		let sessionName = UtilitiesString.getWithoutProperties(lines[0])
        let sessionProps = UtilitiesString.getProperties(lines[0])
        session = (sessionName, sessionProps)

		lines.removeFirst()
        
		for s in lines {
			let name = UtilitiesString.getWithoutProperties(s)
            let props = UtilitiesString.getProperties(s)
			tasks.append((name, props))
		}
	}
  }
