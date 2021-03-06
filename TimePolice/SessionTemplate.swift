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
    var session: (String, String, [String: String]) = ("", "", [:])
    var tasks: [(String, [String: String])] = []
    var errorMessage = ""
    var templateOk = true

    /**
    Parse a string to be able to store a session template.
    - parameter string: A string defining the template
    */
	func parseTemplate(_ string: String) {
        tasks = []
        var lines: [String] = string.components(separatedBy: "\n")
		if lines.count == 0 {
			return
		}

		let sessionNameVersion = UtilitiesString.getWithoutProperties(lines[0])
        let (sessionName, sessionVersion) = UtilitiesString.get2Parts(sessionNameVersion, separator: CharacterSet(charactersIn: "."))
        let sessionProps = UtilitiesString.getProperties(lines[0])

        if sessionName==templateProjectName {
            errorMessage += "Template name \"\(sessionName)\" can't be used.\n"
            templateOk = false
        }
        for propKey in sessionProps.keys {
            if propKey != "extension" && propKey != "columns" {
                errorMessage += "Session propery \"\(propKey)\" is undefined.\n"
                templateOk = false
            }
        }

        session = (sessionName, sessionVersion, sessionProps)

		lines.removeFirst()
        
        var usedTasks = [String]()
		for s in lines {
			let name = UtilitiesString.getWithoutProperties(s)
            let props = UtilitiesString.getProperties(s)
            if name=="" || name.hasPrefix("=") {
                // OK to have these strings several times in the same template
            } else if usedTasks.contains(name) {
                errorMessage += "Task name \"\(name)\" used more than once in the same template.\n"
                templateOk = false
            }
            for tag in props.keys {
                if tag != "color" {
                    errorMessage += "Task property \"\(tag)\" for task \"\(name)\" is undefined.\n"
                    templateOk = false
                }
            }
            usedTasks.append(name)
			tasks.append((name, props))
		}
	}
  }
