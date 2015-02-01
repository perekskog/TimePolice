//
//  Layout.swift
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


protocol Layout {
    func numberOfSelectionAreas() -> Int
    func getViewRect(parentViewRect: CGRect, selectionArea: Int) -> CGRect
}

class GridLayout : Layout {
    var rows: Int
    var columns: Int
    let toolbarHeight = 40
    let padding = 2
    
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
    }
    
    func numberOfSelectionAreas() -> Int {
        return rows * columns;
    }
    
    func getViewRect(parentViewRect: CGRect, selectionArea: Int) -> CGRect {
        switch selectionArea {
        case SignInSignOut:
            let column = 0
            let columnWidth = Int(parentViewRect.width) / columns
            let rect = CGRect(x:column*columnWidth+padding, y:padding, width:columnWidth-padding, height:toolbarHeight)
            return rect
        case InfoArea:
            let column = 1
            let columnWidth = Int(parentViewRect.width) / columns
            let rect = CGRect(x:column*columnWidth+padding, y:padding, width:columnWidth-padding, height:toolbarHeight)
            return rect
        case Settings:
            let column = 2
            let columnWidth = Int(parentViewRect.width) / columns
            let rect = CGRect(x:column*columnWidth+padding, y:padding, width:columnWidth-padding, height:toolbarHeight)
            return rect
        default:
            let row = selectionArea / columns
            let column = selectionArea % columns
            let rowHeight = (Int(parentViewRect.height)-toolbarHeight) / rows
            let columnWidth = Int(parentViewRect.width) / columns
            let rect = CGRect(x:column*columnWidth+padding, y:row*rowHeight+toolbarHeight+2*padding, width:columnWidth-padding, height:rowHeight-padding)
            
            return rect
        }
    }
}

