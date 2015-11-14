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

class SessionTemplate {
    var session: (String, [String: String]) = ("", [:])
    var tasks: [(String, [String: String])] = []

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

    func getString(session: (String, [String: String]), tasks: [(String, [String: String])]) -> String {
		var s = ""

		let (sessionName, sessionProps) = session
		s += "\(sessionName)"
		if sessionProps.count > 0 {
			s += "#"
			s += UtilitiesString.getStringFromProperties(sessionProps)
		}

		for (taskName, taskProperties) in tasks {
			s += "\n\(taskName)"
			if taskProperties.count > 0 {
				s += "#"
				s += UtilitiesString.getStringFromProperties(taskProperties)
			}
		}
		return s
	}
  }
