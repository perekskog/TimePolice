//
//  TimePoliceTheme.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-02-01.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

import Foundation
import UIKit


enum ViewType: Int {
    case SignInSignOut, InfoArea, Add, SessionName
}


/////////////// --- Views --- //////////////////

class TimePoliceBGView: UIView {

    var theme: Theme?

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let context = UIGraphicsGetCurrentContext()
        theme?.drawTimePoliceBG(context, parent: rect)
    }
}

class TaskPickerBGView: UIView {

    var theme: Theme?

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let context = UIGraphicsGetCurrentContext()
        theme?.drawTaskPickerBG(context, parent: rect)
    }
}

class WorkListBGView: UIView {

    var theme: Theme?

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let context = UIGraphicsGetCurrentContext()
        theme?.drawWorkListBG(context, parent: rect)
    }
}

class TaskPickerButtonView: UIView {
    
    var taskPosition: Int?
    var selectionAreaInfoDelegate: SelectionAreaInfoDelegate?
    var theme: Theme?

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let context = UIGraphicsGetCurrentContext()
        if let i = taskPosition {
            if let selectionAreaInfo = selectionAreaInfoDelegate?.getSelectionAreaInfo(i) {
                theme?.drawTaskPickerButton(context, parent: rect, taskPosition: i, selectionAreaInfo: selectionAreaInfo)
            }
        }
    }
}

class TaskPickerToolView: UIView {
    
    var tool: ViewType?
    var toolbarInfoDelegate: ToolbarInfoDelegate?
    var theme: Theme?

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let context = UIGraphicsGetCurrentContext()
        if let i = tool {
            if let toolbarInfo = toolbarInfoDelegate?.getToolbarInfo() {
                theme?.drawTaskPickerTool(context, parent: rect, viewType: i, toolbarInfo: toolbarInfo)
            }
        }
    }
}

class WorkListToolView: UIView {
    
    var tool: ViewType?
    var toolbarInfoDelegate: ToolbarInfoDelegate?
    var theme: Theme?

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let context = UIGraphicsGetCurrentContext()
        if let i = tool {
            if let toolbarInfo = toolbarInfoDelegate?.getToolbarInfo() {
                theme?.drawWorkListTool(context, parent: rect, viewType: i, toolbarInfo: toolbarInfo)
            }
        }
    }
}

/////////////// --- Delegates --- //////////////////


protocol SelectionAreaInfoDelegate {
    func getSelectionAreaInfo(selectionArea: Int) -> SelectionAreaInfo
}

class SelectionAreaInfo {
    var task: Task?
    var numberOfTimesActivated: Int?
    var totalTimeActive: NSTimeInterval?
    var active: Bool?
    var activatedAt: NSDate?
    var ongoing: Bool?
}

protocol ToolbarInfoDelegate {
    func getToolbarInfo() -> ToolbarInfo
}

class ToolbarInfo {
    var signedIn: Bool
    var totalTimesActivatedForSession: Int
    var totalTimeActiveForSession: NSTimeInterval
    var sessionName: String
    init(signedIn: Bool, totalTimesActivatedForSession: Int, totalTimeActiveForSession: NSTimeInterval, sessionName: String) {
        self.signedIn = signedIn
        self.totalTimesActivatedForSession = totalTimesActivatedForSession
        self.totalTimeActiveForSession = totalTimeActiveForSession
        self.sessionName = sessionName
    }
}

/////////////// --- Visuals --- //////////////////

protocol Theme {
    func drawTimePoliceBG(context: CGContextRef, parent: CGRect)

    func drawTaskPickerBG(context: CGContextRef, parent: CGRect)
    func drawTaskPickerTool(context: CGContextRef, parent: CGRect, viewType: ViewType, toolbarInfo: ToolbarInfo)
    func drawTaskPickerButton(context: CGContextRef, parent: CGRect, taskPosition: Int, selectionAreaInfo: SelectionAreaInfo)
    
    func drawWorkListBG(context: CGContextRef, parent: CGRect)
    func drawWorkListTool(context: CGContextRef, parent: CGRect, viewType: ViewType, toolbarInfo: ToolbarInfo)
}











class BasicTheme : Theme {
    
    let bigSize:CGFloat = 13.0
    let smallSize:CGFloat = 11.0
    

    func drawTimePoliceBG(context: CGContextRef, parent: CGRect) {
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        
        // Gradient
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        let colors = [CGColorCreate(colorSpaceRGB, [0.4, 0.4, 0.6, 1.0]),
            CGColorCreate(colorSpaceRGB, [0.6, 0.6, 0.9, 1.0])]
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradientCreateWithColors(colorspace,
            colors, locations)
        var startPoint = CGPoint()
        var endPoint =  CGPoint()
        startPoint.x = 0.0
        startPoint.y = 0.0
        endPoint.x = 0
        endPoint.y = 700
        CGContextDrawLinearGradient(context, gradient,
            startPoint, endPoint, 0)
        
    }
    


    func drawWorkListBG(context: CGContextRef, parent: CGRect) {
        drawTaskPickerBG(context, parent: parent)
    }

    func drawTaskPickerBG(context: CGContextRef, parent: CGRect) {
        // Gradient
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        let colors = [CGColorCreate(colorSpaceRGB, [0.0, 1.0, 0.0, 1.0]),
            CGColorCreate(colorSpaceRGB, [0.8, 1.0, 0.8, 1.0])]
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



    func drawWorkListTool(context: CGContextRef, parent: CGRect, viewType: ViewType, toolbarInfo: ToolbarInfo) {
        drawTaskPickerTool(context, parent: parent, viewType: viewType, toolbarInfo: toolbarInfo)
    }
    
    func drawTaskPickerTool(context: CGContextRef, parent: CGRect, viewType: ViewType, toolbarInfo: ToolbarInfo) {
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
        switch viewType {
        case .SessionName:
            text = toolbarInfo.sessionName
        case .SignInSignOut:
            if toolbarInfo.signedIn {
                text = "Stop"
                gradient = CGGradientCreateWithColors(colorspace, backgroundColorsGreen, locations)
            } else {
                text = "Start"
                gradient = CGGradientCreateWithColors(colorspace, backgroundColorsRed, locations)
                foregroundColor = foregroundColorWhite
            }
        case .InfoArea:
            text = "\(toolbarInfo.totalTimesActivatedForSession)    \(getString(toolbarInfo.totalTimeActiveForSession))"
        case .Add:
            text = "Add"
        }
        
        var startPoint = CGPoint()
        var endPoint =  CGPoint()
        startPoint.x = 0.0
        startPoint.y = 0.0
        endPoint.x = 0
        endPoint.y = parent.height
        CGContextDrawLinearGradient(context, gradient,
            startPoint, endPoint, 0)
        
        ThemeUtilities.addText(context, text: text, origin: CGPoint(x:parent.width/2, y:parent.height/2), fontSize: bigSize, withFrame: false, foregroundColor: foregroundColor)
    }



    func drawTaskPickerButton(context: CGContextRef, parent: CGRect, taskPosition: Int, selectionAreaInfo: SelectionAreaInfo) {
        // Gradient
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        var colors = [CGColorCreate(colorSpaceRGB, [1.0, 1.0, 1.0, 1.0]),
            CGColorCreate(colorSpaceRGB, [0.5, 0.5, 1.0, 1.0])]
        if let a = selectionAreaInfo.active {
            if a==true {
                colors = [CGColorCreate(colorSpaceRGB, [1.0, 1.0, 1.0, 1.0]),
                    CGColorCreate(colorSpaceRGB, [1.0, 1.0, 1.0, 1.0])]
            }
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
        if let t = selectionAreaInfo.task {
            // TODO: If task.name ends with #RGB, add small square to the left of the name
            ThemeUtilities.addText(context, text: t.name, origin: CGPoint(x:parent.width/2, y:parent.height/4), fontSize: bigSize, withFrame: false, foregroundColor: color)
        }
        if let active = selectionAreaInfo.active {
            if active == true {
                if let activatedAt = selectionAreaInfo.activatedAt {
                    let now = NSDate()
                    let activeTime = now.timeIntervalSinceDate(activatedAt)
                    ThemeUtilities.addText(context, text: getString(activeTime), origin: CGPoint(x:parent.width/2, y:parent.height/4*3), fontSize: smallSize, withFrame: false, foregroundColor: color)
                }
            } else {
                if let numberOfTimesActivated = selectionAreaInfo.numberOfTimesActivated {
                    ThemeUtilities.addText(context, text: String(numberOfTimesActivated), origin: CGPoint(x:parent.width/4, y:parent.height/4*3), fontSize: smallSize, withFrame: false, foregroundColor: color)
                }
                if let totalTimeActive = selectionAreaInfo.totalTimeActive {
                    ThemeUtilities.addText(context, text: getString(totalTimeActive), origin: CGPoint(x:parent.width/4*3, y:parent.height/4*3), fontSize: smallSize, withFrame: false, foregroundColor: color)
                }
            
            }
        }
    }
}











class BlackGreenTheme : Theme {
    
    let bigSize:CGFloat = 13.0
    let smallSize:CGFloat = 11.0
    

    func drawTimePoliceBG(context: CGContextRef, parent: CGRect) {
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        
        // Top area
        let locations1: [CGFloat] = [ 0.0, 1.0 ]
        let colors1 = [CGColorCreate(colorSpaceRGB, [0.3, 0.3, 0.3, 1.0]),
            CGColorCreate(colorSpaceRGB, [0.5, 0.75, 0.5, 1.0])]
        let gradient1 = CGGradientCreateWithColors(colorSpaceRGB,
            colors1, locations1)
        var startPoint1 = CGPoint(x:0.0, y:0.0)
        var endPoint1 =  CGPoint(x:0.0, y:25.0)
        CGContextDrawLinearGradient(context, gradient1,
            startPoint1, endPoint1, 0)

        // Gradient
        let locations2: [CGFloat] = [ 0.0, 1.0 ]
        let colors2 = [CGColorCreate(colorSpaceRGB, [0.0, 0.0, 0.0, 1.0]),
            CGColorCreate(colorSpaceRGB, [0.0, 0.0, 0.0, 1.0])]
        let gradient2 = CGGradientCreateWithColors(colorSpaceRGB,
            colors2, locations2)
        var startPoint2 = CGPoint(x:0.0, y:25.0)
        var endPoint2 =  CGPoint(x:0.0, y:parent.height)
        CGContextDrawLinearGradient(context, gradient2,
            startPoint2, endPoint2, 0)
    }
    


    func drawWorkListBG(context: CGContextRef, parent: CGRect) {
        drawTaskPickerBG(context, parent: parent)
    }
    
    func drawTaskPickerBG(context: CGContextRef, parent: CGRect) {
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()

        // Gradient
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        let colors = [CGColorCreate(colorSpaceRGB, [0.0, 0.8, 0.0, 1.0]),
            CGColorCreate(colorSpaceRGB, [0.0, 0.8, 0.0, 1.0])]
        let gradient = CGGradientCreateWithColors(colorSpaceRGB,
            colors, locations)
        var startPoint = CGPoint(x:0.0, y:0.0)
        var endPoint =  CGPoint(x:0.0, y:parent.height)
        CGContextDrawLinearGradient(context, gradient,
            startPoint, endPoint, 0)
    }




    func drawWorkListTool(context: CGContextRef, parent: CGRect, viewType: ViewType, toolbarInfo: ToolbarInfo) {
        drawTaskPickerTool(context, parent: parent, viewType: viewType, toolbarInfo: toolbarInfo)
    }
    
    func drawTaskPickerTool(context: CGContextRef, parent: CGRect, viewType: ViewType, toolbarInfo: ToolbarInfo) {
        // Gradient
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        
        var foregroundColorWhite = UIColor(white: 1.0, alpha: 1.0).CGColor
        var foregroundColorBlack = UIColor(white: 0.0, alpha: 1.0).CGColor

        var backgroundColorsNeutral = [CGColorCreate(colorSpaceRGB, [0.3, 0.3, 0.3, 1.0]),
            CGColorCreate(colorSpaceRGB, [0.2, 0.2, 0.2, 1.0])]

        var backgroundColorsRed = [CGColorCreate(colorSpaceRGB, [0.7, 0.7, 0.7, 1.0]),
            CGColorCreate(colorSpaceRGB, [0.4, 0.0, 0.0, 1.0])]

        var backgroundColorsGreen = [CGColorCreate(colorSpaceRGB, [0.7, 0.7, 0.7, 1.0]),
            CGColorCreate(colorSpaceRGB, [0.0, 0.4, 0.0, 1.0])]
        
        let colorspace = CGColorSpaceCreateDeviceRGB()
        var gradient = CGGradientCreateWithColors(colorspace, backgroundColorsNeutral, locations)
        var foregroundColor = foregroundColorWhite
        var text: String

        switch viewType {
        case .SessionName:
            text = toolbarInfo.sessionName
        case .SignInSignOut:
            if toolbarInfo.signedIn {
                text = "Stop"
                gradient = CGGradientCreateWithColors(colorspace, backgroundColorsGreen, locations)
            } else {
                text = "Continue"
                gradient = CGGradientCreateWithColors(colorspace, backgroundColorsRed, locations)
            }
        case .InfoArea:
            text = "Completed: \(toolbarInfo.totalTimesActivatedForSession)    Total time: \(getString(toolbarInfo.totalTimeActiveForSession))"
        case .Add:
            text = "Add"
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
        
        ThemeUtilities.addText(context, text: text, origin: CGPoint(x:parent.width/2, y:parent.height/2), fontSize: bigSize, withFrame: false, foregroundColor: foregroundColor)
    }


    
    func drawTaskPickerButton(context: CGContextRef, parent: CGRect, taskPosition: Int, selectionAreaInfo: SelectionAreaInfo) {
        // Gradient
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        var colors = [CGColorCreate(colorSpaceRGB, [0.3, 0.3, 0.3, 1.0]),
            CGColorCreate(colorSpaceRGB, [0.2, 0.2, 0.2, 1.0])]
        if let active = selectionAreaInfo.active {
            if active {
                if let ongoing = selectionAreaInfo.ongoing {
                    if ongoing {
                        colors = [CGColorCreate(colorSpaceRGB, [0.5, 0.6, 0.5, 1.0]),
                            CGColorCreate(colorSpaceRGB, [0.5, 0.6, 0.5, 1.0])]
                    } else {
                        colors = [CGColorCreate(colorSpaceRGB, [0.6, 0.5, 0.5, 1.0]),
                            CGColorCreate(colorSpaceRGB, [0.6, 0.5, 0.5, 1.0])]
                    }
                }
            }
        }
        let gradient = CGGradientCreateWithColors(colorSpaceRGB,
            colors, locations)
        var startPoint = CGPoint(x: 0.0, y:0.0)
        var endPoint =  CGPoint(x:0, y:parent.height)
        CGContextDrawLinearGradient(context, gradient,
            startPoint, endPoint, 0)
        
        let color = UIColor(white: 1.0, alpha: 1.0).CGColor
        if let task = selectionAreaInfo.task {
            let comment = ThemeUtilities.getComment(task.name)
            let colorString = ThemeUtilities.getColorTag(comment)
            let colorSquare = ThemeUtilities.getColor(colorString).CGColor
            let colorsSquare = [colorSquare, colorSquare]
            let locationSquare: [CGFloat] = [ 0.0, 1.0 ]
            let gradientSquare = CGGradientCreateWithColors(colorSpaceRGB, colorsSquare, locationSquare)
            let startPointSquare = CGPoint(x: 5, y: 5)
            let endPointSquare = CGPoint(x: 10, y: 10)
            CGContextSaveGState(context)
//            CGContextClipToRect(context, CGRectMake(3, 3, 7, 7))
            CGContextDrawLinearGradient(context, gradientSquare, startPointSquare, endPointSquare, 0)
            CGContextRestoreGState(context)
            // TODO: If task.name ends with #RGB, add small square to the left of the name
           ThemeUtilities.addText(context, text: task.name, origin: CGPoint(x:parent.width/2, y:parent.height/4), fontSize: bigSize, withFrame: false, foregroundColor: color)
        }
        
        if let ongoing = selectionAreaInfo.ongoing {
            if ongoing {
                if let activatedAt = selectionAreaInfo.activatedAt {
                    let now = NSDate()
                    let activeTime = now.timeIntervalSinceDate(activatedAt)
                    ThemeUtilities.addText(context, text: getString(activeTime), origin: CGPoint(x:parent.width/2, y:parent.height/4*3), fontSize: smallSize, withFrame: false, foregroundColor: color)
                }
            } else {
                if let numberOfTimesActivated = selectionAreaInfo.numberOfTimesActivated {
                    ThemeUtilities.addText(context, text: String(numberOfTimesActivated), origin: CGPoint(x:parent.width/4, y:parent.height/4*3), fontSize: smallSize, withFrame: false, foregroundColor: color)
                }
                if let totalTimeActive = selectionAreaInfo.totalTimeActive {
                    ThemeUtilities.addText(context, text: getString(totalTimeActive), origin: CGPoint(x:parent.width/4*3, y:parent.height/4*3), fontSize: smallSize, withFrame: false, foregroundColor: color)
                }
            }
        }
    }

    
}













/////////////// --- Helpers --- //////////////////

class ThemeUtilities {
    
    class func addText(context: CGContextRef, text: String, origin: CGPoint, fontSize: CGFloat, withFrame: Bool, foregroundColor: CGColor) {
        CGContextSaveGState(context)
        var attributes: [String: AnyObject] = [
            NSForegroundColorAttributeName : foregroundColor,
            NSFontAttributeName : UIFont.systemFontOfSize(fontSize)
        ]
        /*1.2*/let font = attributes[NSFontAttributeName] as! UIFont
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
    
    class func getComment(text: String) -> String {
        return ""
    }
    
    class func getColorTag(text: String) -> String {
        return ""
    }
    
    class func getColor(text: String) -> UIColor {
        return UIColor(red: 0.6, green: 0.4, blue: 0.4, alpha: 1.0)
    }
}

