//
//  Themes.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-02-01.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

import Foundation
import UIKit

protocol Theme {
    func drawBackground(context: CGContextRef, parent: CGRect, numberOfTasks: Int)
    func drawButton(context: CGContextRef, parent: CGRect, taskPosition: Int, selectionAreaInfo: SelectionAreaInfo)
    func drawTool(context: CGContextRef, parent: CGRect, tool: Int, toolbarInfo: ToolbarInfo)
}

class BasicTheme : Theme {
    
    let bigSize:CGFloat = 13.0
    let smallSize:CGFloat = 11.0
    
    func drawBackground(context: CGContextRef, parent: CGRect, numberOfTasks: Int) {
        // Gradient
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        let colors = [CGColorCreate(colorSpaceRGB, [0.0, 1.0, 0.0, 1.0]),
            CGColorCreate(colorSpaceRGB, [1.0, 1.0, 1.0, 1.0])]
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradientCreateWithColors(colorspace,
            colors, locations)
        var startPoint = CGPoint()
        var endPoint =  CGPoint()
        startPoint.x = 0.0
        startPoint.y = 0.0
        endPoint.x = 0
        endPoint.y = parent.height
        CGContextDrawLinearGradient(context, gradient,
            startPoint, endPoint, 0)
    }
    
    func addText(context: CGContextRef, text: String, origin: CGPoint, fontSize: CGFloat, withFrame: Bool, foregroundColor: CGColor) {
        CGContextSaveGState(context)
        var attributes: [String: AnyObject] = [
            NSForegroundColorAttributeName : foregroundColor,
            NSFontAttributeName : UIFont.systemFontOfSize(fontSize)
        ]
        let font = attributes[NSFontAttributeName] as UIFont
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = text.sizeWithAttributes(attributes)
        CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
        let size = CGSize(width:Int(textSize.width+0.5)+1, height:Int(textSize.height+0.5))
        let textRect = CGRect(
            origin: CGPoint(x: origin.x-textSize.width/2, y:origin.y),
            size: size)
        let textPath    = CGPathCreateWithRect(textRect, nil)
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedString)
        let frame       = CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: attributedString.length), textPath, nil)
        CTFrameDraw(frame, context)
        CGContextRestoreGState(context)
        
        // Rectangle
        if(withFrame) {
            CGContextSetLineWidth(context, 1.0)
            CGContextSetStrokeColorWithColor(context,
                UIColor.blueColor().CGColor)
            let rect = CGRect(x:origin.x-textSize.width/2, y: origin.y-textSize.height/2, width: textSize.width, height: textSize.height)
            CGContextAddRect(context, rect)
            CGContextStrokePath(context)
        }
    }
    
    func drawButton(context: CGContextRef, parent: CGRect, taskPosition: Int, selectionAreaInfo: SelectionAreaInfo) {
        // Gradient
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        var colors = [CGColorCreate(colorSpaceRGB, [1.0, 1.0, 1.0, 1.0]),
            CGColorCreate(colorSpaceRGB, [0.3, 0.3, 1.0, 1.0])]
        if selectionAreaInfo.active {
            colors = [CGColorCreate(colorSpaceRGB, [1.0, 1.0, 1.0, 1.0]),
                CGColorCreate(colorSpaceRGB, [1.0, 1.0, 1.0, 1.0])]
        }
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradientCreateWithColors(colorspace,
            colors, locations)
        var startPoint = CGPoint()
        var endPoint =  CGPoint()
        startPoint.x = 0.0
        startPoint.y = 0.0
        endPoint.x = 0
        endPoint.y = parent.height
        CGContextDrawLinearGradient(context, gradient,
            startPoint, endPoint, 0)
        
        let color = UIColor(white: 0.0, alpha: 1.0).CGColor
        addText(context, text: selectionAreaInfo.task.name, origin: CGPoint(x:parent.width/2, y:parent.height/4), fontSize: bigSize, withFrame: false, foregroundColor: color)
        if selectionAreaInfo.active {
            let now = NSDate()
            let activeTime = now.timeIntervalSinceDate(selectionAreaInfo.activatedAt)
            addText(context, text: getString(activeTime), origin: CGPoint(x:parent.width/2, y:parent.height/4*3), fontSize: smallSize, withFrame: false, foregroundColor: color)
        } else {
            addText(context, text: String(selectionAreaInfo.numberOfTimesActivated), origin: CGPoint(x:parent.width/4, y:parent.height/4*3), fontSize: smallSize, withFrame: false, foregroundColor: color)
            addText(context, text: getString(selectionAreaInfo.totalTimeActive), origin: CGPoint(x:parent.width/4*3, y:parent.height/4*3), fontSize: smallSize, withFrame: false, foregroundColor: color)
        }
    }
    
    func drawTool(context: CGContextRef, parent: CGRect, tool: Int, toolbarInfo: ToolbarInfo) {
        // Gradient
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        
        var foregroundColorWhite = UIColor(white: 1.0, alpha: 1.0).CGColor
        var foregroundColorBlack = UIColor(white: 0.0, alpha: 1.0).CGColor
        var backgroundColorsGrey = [CGColorCreate(colorSpaceRGB, [1.0, 1.0, 1.0, 1.0]),
            CGColorCreate(colorSpaceRGB, [0.6, 0.6, 0.6, 1.0])]
        var backgroundColorsRed = [CGColorCreate(colorSpaceRGB, [1.0, 1.0, 1.0, 1.0]),
            CGColorCreate(colorSpaceRGB, [0.8, 0.0, 0.0, 1.0])]
        var backgroundColorsGreen = [CGColorCreate(colorSpaceRGB, [1.0, 1.0, 1.0, 1.0]),
            CGColorCreate(colorSpaceRGB, [0.0, 0.8, 0.0, 1.0])]
        
        let colorspace = CGColorSpaceCreateDeviceRGB()
        var gradient = CGGradientCreateWithColors(colorspace, backgroundColorsGrey, locations)
        var foregroundColor = foregroundColorBlack
        var text: String
        switch tool {
        case SignInSignOut:
            if toolbarInfo.signedIn {
                text = "Sign out"
                gradient = CGGradientCreateWithColors(colorspace, backgroundColorsGreen, locations)
            } else {
                text = "Sign in"
                gradient = CGGradientCreateWithColors(colorspace, backgroundColorsRed, locations)
                foregroundColor = foregroundColorWhite
            }
        case InfoArea:
            text = "\(toolbarInfo.totalTimesActivatedForSession)    \(getString(toolbarInfo.totalTimeActiveForSession))"
        case Settings:
            text = "Settings"
        default:
            text = "---"
        }
        
        var startPoint = CGPoint()
        var endPoint =  CGPoint()
        startPoint.x = 0.0
        startPoint.y = 0.0
        endPoint.x = 0
        endPoint.y = parent.height
        CGContextDrawLinearGradient(context, gradient,
            startPoint, endPoint, 0)
        
        addText(context, text: text, origin: CGPoint(x:parent.width/2, y:parent.height/2), fontSize: bigSize, withFrame: false, foregroundColor: foregroundColor)
    }
    
}

