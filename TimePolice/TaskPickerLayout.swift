//
//  TaskPickerLayout.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-02-01.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

import Foundation
import UIKit

let SignInSignOut = -1	// Active button for signing in/out of a session
let InfoArea = -2		// Display area for ongoing work
let Settings = -3		// Segue to settings, configurations etc
let SessionName = -4    // Display of current sessionname


protocol Layout {
    func numberOfSelectionAreas() -> Int
    func getViewRect(parentViewRect: CGRect, selectionArea: Int) -> CGRect
}

class GridLayout : Layout {
    var rows: Int
    var columns: Int
    var padding: Int
    var toolHeight: Int
    
    init(rows: Int, columns: Int, padding: Int, toolHeight: Int) {
        self.rows = rows
        self.columns = columns
        self.padding = padding
        self.toolHeight = toolHeight
    }
    
    func numberOfSelectionAreas() -> Int {
        return rows * columns;
    }
    
    func getViewRect(parentViewRect: CGRect, selectionArea: Int) -> CGRect {
        switch selectionArea {
        case SessionName:
            let column = 0
            let columnWidth = Int(parentViewRect.width)
            let rect = CGRect(x:70, y:padding, width:columnWidth-70, height:toolHeight)
            return rect
        case SignInSignOut:
            let column = 0
            let columnWidth = Int(parentViewRect.width) / columns
            let rect = CGRect(x:column*columnWidth+padding, y:padding*2+toolHeight, width:columnWidth-padding, height:toolHeight)
            return rect
        case InfoArea:
            let column = 1
            let columnWidth = Int(parentViewRect.width) / columns
            let rect = CGRect(x:column*columnWidth+padding, y:padding*2+toolHeight, width:columnWidth-padding, height:toolHeight)
            return rect
        case Settings:
            let column = 2
            let columnWidth = Int(parentViewRect.width) / columns
            let rect = CGRect(x:column*columnWidth+padding, y:padding*2+toolHeight, width:columnWidth-padding, height:toolHeight)
            return rect
        default:
            // A button
            let row = selectionArea / columns
            let column = selectionArea % columns
            let rowHeight = (Int(parentViewRect.height)-2*toolHeight-padding) / rows
            let columnWidth = Int(parentViewRect.width) / columns
            let rect = CGRect(x:column*columnWidth+padding, y:row*rowHeight+2*toolHeight+3*padding, width:columnWidth-padding, height:rowHeight-padding)
            
            return rect
        }
    }
}

