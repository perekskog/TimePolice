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
    var padding: CGFloat
    var toolHeight: CGFloat
    
    init(rows: Int, columns: Int, padding: CGFloat, toolHeight: CGFloat) {
        self.rows = rows
        self.columns = columns
        self.padding = padding
        self.toolHeight = toolHeight
    }
    
    func numberOfSelectionAreas() -> Int {
        return rows * columns;
    }

    func adjustedFrame(originalFrame: CGRect) -> CGRect {
        let adjustedWidth = (originalFrame.width / CGFloat(columns)) * CGFloat(columns)
        let adjustedHeight = (originalFrame.height / CGFloat(rows)) * CGFloat(rows)
        return CGRectMake(originalFrame.origin.x, originalFrame.origin.y, adjustedWidth, adjustedHeight)
    }
    
    func getViewRect(parentViewRect: CGRect, selectionArea: Int) -> CGRect {
        switch selectionArea {
        /*
        case SessionName:
            let column = 0
            let columnWidth = parentViewRect.width
            let rect = CGRect(x:70, y:padding, width:columnWidth-70, height:toolHeight)
            return rect
        */
        case InfoArea:
            let columnWidth = parentViewRect.width
            let rect = CGRectMake(padding, padding, columnWidth-2*padding, toolHeight)
            return rect
        case SignInSignOut:
            let columnWidth = parentViewRect.width
            let rect = CGRectMake(padding, padding*2+toolHeight, columnWidth-2*padding, toolHeight)
            return rect
        /*
        case Settings:
            let column: CGFloat = 2
            let columnWidth = parentViewRect.width / CGFloat(columns)
            let rect = CGRect(x:column*columnWidth+padding, y:padding*2+toolHeight, width:columnWidth-padding, height:toolHeight)
            return rect
        */
        default:
            // A button
            let row = selectionArea / columns
            let column = selectionArea % columns
            /*
            let rowHeight = (parentViewRect.height-2*toolHeight-padding) / CGFloat(rows)
            let columnWidth = parentViewRect.width / CGFloat(columns)
            let rect = CGRect(x:CGFloat(column)*columnWidth+padding, y:CGFloat(row)*rowHeight+2*toolHeight+3*padding, width:columnWidth-padding, height:rowHeight-padding)
            */
            let rowHeight = (parentViewRect.height-2*toolHeight-(3+CGFloat(rows))*padding) / CGFloat(rows)
            let columnWidth = (parentViewRect.width - (1+CGFloat(columns))*padding) / CGFloat(columns)
            let x = padding+(columnWidth+padding)*CGFloat(column)
            let y = 2*toolHeight+3*padding+(rowHeight+padding)*CGFloat(row)
            let rect = CGRectMake(x, y, columnWidth, rowHeight)
            
            return rect
        }
    }
}

