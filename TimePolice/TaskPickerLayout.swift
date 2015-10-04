//
//  TaskPickerLayout.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-02-01.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

/*

TODO

*/

import Foundation
import UIKit

protocol Layout {
    func numberOfSelectionAreas() -> Int
    func getViewRectInfo(parentViewRect: CGRect) -> CGRect
    func getViewRectSignInSignOut(parentViewRect: CGRect) -> CGRect
    func getViewRect(parentViewRect: CGRect, buttonNumber: Int) -> CGRect
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
  
    func getViewRectInfo(parentViewRect: CGRect) -> CGRect {
            let columnWidth = parentViewRect.width
            let rect = CGRectMake(padding, padding, columnWidth-2*padding, toolHeight)
            return rect
    }

    func getViewRectSignInSignOut(parentViewRect: CGRect) -> CGRect {
            let columnWidth = parentViewRect.width
            let rect = CGRectMake(padding, padding*2+toolHeight, columnWidth-2*padding, toolHeight)
            return rect
    }

    func getViewRect(parentViewRect: CGRect, buttonNumber: Int) -> CGRect {
        let row = buttonNumber / columns
        let column = buttonNumber % columns
        let rowHeight = (parentViewRect.height-2*toolHeight-(3+CGFloat(rows))*padding) / CGFloat(rows)
        let columnWidth = (parentViewRect.width - (1+CGFloat(columns))*padding) / CGFloat(columns)
        let x = padding+(columnWidth+padding)*CGFloat(column)
        let y = 2*toolHeight+3*padding+(rowHeight+padding)*CGFloat(row)
        let rect = CGRectMake(x, y, columnWidth, rowHeight)
        
        return rect
    }
}

