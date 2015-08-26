//
//  TaskPickerLayout.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-02-01.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

/*
TODO

- Flytta ViewType till Theme när jag införlivat Layout i TaskPicker (det är bara där den används)

*/

import Foundation
import UIKit

enum ViewType: Int {
    case SignInSignOut, InfoArea, Add, SessionName
}

protocol Layout {
    func numberOfSelectionAreas() -> Int
    func getViewRect(parentViewRect: CGRect, selectionArea: ViewType) -> CGRect
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

    func adjustedFrame(originalFrame: CGRect) -> CGRect {
        let adjustedWidth = (originalFrame.width / CGFloat(columns)) * CGFloat(columns)
        let adjustedHeight = (originalFrame.height / CGFloat(rows)) * CGFloat(rows)
        return CGRectMake(originalFrame.origin.x, originalFrame.origin.y, adjustedWidth, adjustedHeight)
    }
    
    func getViewRect(parentViewRect: CGRect, selectionArea: ViewType) -> CGRect {
        switch selectionArea {
        case .InfoArea:
            let columnWidth = parentViewRect.width
            let rect = CGRectMake(padding, padding, columnWidth-2*padding, toolHeight)
            return rect
        case .SignInSignOut:
            let columnWidth = parentViewRect.width
            let rect = CGRectMake(padding, padding*2+toolHeight, columnWidth-2*padding, toolHeight)
            return rect
        default:
            return CGRectMake(0, 0, 0, 0)
        }
        
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

