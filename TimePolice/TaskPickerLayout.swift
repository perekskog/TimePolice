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
    var toolbarHeight: Int
    
    init(rows: Int, columns: Int, padding: Int, toolbarHeight: Int) {
        self.rows = rows
        self.columns = columns
        self.padding = padding
        self.toolbarHeight = toolbarHeight
    }
    
    func numberOfSelectionAreas() -> Int {
        return rows * columns;
    }
    
    func getViewRect(parentViewRect: CGRect, selectionArea: Int) -> CGRect {
        switch selectionArea {
        case SessionName:
            let column = 0
            let columnWidth = Int(parentViewRect.width)
            let rect = CGRect(x:0, y:padding, width:columnWidth, height:toolbarHeight)
            return rect
        case SignInSignOut:
            let column = 0
            let columnWidth = Int(parentViewRect.width) / columns
            let rect = CGRect(x:column*columnWidth+padding, y:padding*2+toolbarHeight, width:columnWidth-padding, height:toolbarHeight)
            return rect
        case InfoArea:
            let column = 1
            let columnWidth = Int(parentViewRect.width) / columns
            let rect = CGRect(x:column*columnWidth+padding, y:padding*2+toolbarHeight, width:columnWidth-padding, height:toolbarHeight)
            return rect
        case Settings:
            let column = 2
            let columnWidth = Int(parentViewRect.width) / columns
            let rect = CGRect(x:column*columnWidth+padding, y:padding*2+toolbarHeight, width:columnWidth-padding, height:toolbarHeight)
            return rect
        default:
            // A button
            let row = selectionArea / columns
            let column = selectionArea % columns
            let rowHeight = (Int(parentViewRect.height)-2*toolbarHeight-padding) / rows
            let columnWidth = Int(parentViewRect.width) / columns
            let rect = CGRect(x:column*columnWidth+padding, y:row*rowHeight+2*toolbarHeight+3*padding, width:columnWidth-padding, height:rowHeight-padding)
            
            return rect
        }
    }
}

