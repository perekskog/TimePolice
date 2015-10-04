//
//  TimePoliceTheme.swift
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


enum ViewType: Int {
    case SignInSignOut, InfoArea, Add, SessionName
}


/////////////// --- Views --- //////////////////

class TimePoliceBGView: UIView {

    var theme: Theme?

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        guard let context = UIGraphicsGetCurrentContext() else {
            logDefault("TimePoliceBGView", logtype: .Guard, message: "drawRect")
            return
        }
        theme?.drawTimePoliceBG(context, parent: rect)
    }

}

class TaskPickerBGView: UIView {

    var theme: Theme?

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        guard let context = UIGraphicsGetCurrentContext() else {
            logDefault("TaskPickerBGView", logtype: .Guard, message: "drawRect")
            return
        }
        theme?.drawTaskPickerBG(context, parent: rect)
    }
}

class WorkListBGView: UIView {

    var theme: Theme?

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        guard let context = UIGraphicsGetCurrentContext() else {
            logDefault("WorkListBGView", logtype: .Guard, message: "drawRect")
            return
        }
        theme?.drawWorkListBG(context, parent: rect)
    }
}

class TaskPickerButtonView: UIView {
    
    var taskPosition: Int?
    var selectionAreaInfoDelegate: SelectionAreaInfoDelegate?
    var theme: Theme?

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        guard let context = UIGraphicsGetCurrentContext(),
                i = taskPosition,
                selectionAreaInfo = selectionAreaInfoDelegate?.getSelectionAreaInfo(i) else {
            logDefault("TaskPickerButtonView", logtype: .Guard, message: "drawRect")
            return
        }
        theme?.drawTaskPickerButton(context, parent: rect, taskPosition: i, selectionAreaInfo: selectionAreaInfo)
    }
}

class TaskPickerToolView: UIView {
    
    var tool: ViewType?
    var toolbarInfoDelegate: ToolbarInfoDelegate?
    var theme: Theme?

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        guard let context = UIGraphicsGetCurrentContext(),
                i = tool,
                toolbarInfo = toolbarInfoDelegate?.getToolbarInfo() else {
            logDefault("TaskPickerToolView", logtype: .Guard, message: "drawRect")
            return
        }
        theme?.drawTaskPickerTool(context, parent: rect, viewType: i, toolbarInfo: toolbarInfo)
    }
}

class WorkListToolView: UIView {
    
    var tool: ViewType?
    var toolbarInfoDelegate: ToolbarInfoDelegate?
    var theme: Theme?

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        guard let context = UIGraphicsGetCurrentContext(),
                i = tool ,
                toolbarInfo = toolbarInfoDelegate?.getToolbarInfo() else {
            logDefault("WorkListToolView", logtype: .Guard, message: "drawRect")
            return
        }
        theme?.drawWorkListTool(context, parent: rect, viewType: i, toolbarInfo: toolbarInfo)
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
        let colors = [CGColorCreate(colorSpaceRGB, [0.4, 0.4, 0.6, 1.0])!,
            CGColorCreate(colorSpaceRGB, [0.6, 0.6, 0.9, 1.0])!]
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
            startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
        
    }
    


    func drawWorkListBG(context: CGContextRef, parent: CGRect) {
        drawTaskPickerBG(context, parent: parent)
    }

    func drawTaskPickerBG(context: CGContextRef, parent: CGRect) {
        // Gradient
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        let colors = [CGColorCreate(colorSpaceRGB, [0.0, 1.0, 0.0, 1.0])!,
            CGColorCreate(colorSpaceRGB, [0.8, 1.0, 0.8, 1.0])!]
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
            startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
    }



    func drawWorkListTool(context: CGContextRef, parent: CGRect, viewType: ViewType, toolbarInfo: ToolbarInfo) {
        drawTaskPickerTool(context, parent: parent, viewType: viewType, toolbarInfo: toolbarInfo)
    }
    
    func drawTaskPickerTool(context: CGContextRef, parent: CGRect, viewType: ViewType, toolbarInfo: ToolbarInfo) {
        // Gradient
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        
        let foregroundColorWhite = UIColor(white: 1.0, alpha: 1.0).CGColor
        let foregroundColorBlack = UIColor(white: 0.0, alpha: 1.0).CGColor
        let backgroundColorsGrey = [CGColorCreate(colorSpaceRGB, [1.0, 1.0, 1.0, 1.0])!,
            CGColorCreate(colorSpaceRGB, [0.6, 0.6, 0.6, 1.0])!]
        let backgroundColorsRed = [CGColorCreate(colorSpaceRGB, [1.0, 1.0, 1.0, 1.0])!,
            CGColorCreate(colorSpaceRGB, [0.8, 0.0, 0.0, 1.0])!]
        let backgroundColorsGreen = [CGColorCreate(colorSpaceRGB, [1.0, 1.0, 1.0, 1.0])!,
            CGColorCreate(colorSpaceRGB, [0.0, 0.8, 0.0, 1.0])!]
        
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
            startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
        
        ThemeUtilities.addText(context, text: text, origin: CGPoint(x:parent.width/2, y:parent.height/2), fontSize: bigSize, withFrame: false, foregroundColor: foregroundColor)
    }



    func drawTaskPickerButton(context: CGContextRef, parent: CGRect, taskPosition: Int, selectionAreaInfo: SelectionAreaInfo) {
        // Gradient
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        var colors = [CGColorCreate(colorSpaceRGB, [1.0, 1.0, 1.0, 1.0])!,
            CGColorCreate(colorSpaceRGB, [0.5, 0.5, 1.0, 1.0])!]
        if let a = selectionAreaInfo.active {
            if a==true {
                colors = [CGColorCreate(colorSpaceRGB, [1.0, 1.0, 1.0, 1.0])!,
                    CGColorCreate(colorSpaceRGB, [1.0, 1.0, 1.0, 1.0])!]
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
            startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
        
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
        let colors1 = [CGColorCreate(colorSpaceRGB, [0.3, 0.3, 0.3, 1.0])!,
            CGColorCreate(colorSpaceRGB, [0.5, 0.75, 0.5, 1.0])!]
        let gradient1 = CGGradientCreateWithColors(colorSpaceRGB,
            colors1, locations1)
        let startPoint1 = CGPoint(x:0.0, y:0.0)
        let endPoint1 =  CGPoint(x:0.0, y:25.0)
        CGContextDrawLinearGradient(context, gradient1,
            startPoint1, endPoint1, CGGradientDrawingOptions(rawValue: 0))

        // Gradient
        let locations2: [CGFloat] = [ 0.0, 1.0 ]
        let colors2 = [CGColorCreate(colorSpaceRGB, [0.0, 0.0, 0.0, 1.0])!,
            CGColorCreate(colorSpaceRGB, [0.0, 0.0, 0.0, 1.0])!]
        let gradient2 = CGGradientCreateWithColors(colorSpaceRGB,
            colors2, locations2)
        let startPoint2 = CGPoint(x:0.0, y:25.0)
        let endPoint2 =  CGPoint(x:0.0, y:parent.height)
        CGContextDrawLinearGradient(context, gradient2,
            startPoint2, endPoint2, CGGradientDrawingOptions(rawValue: 0))
    }
    


    func drawWorkListBG(context: CGContextRef, parent: CGRect) {
        drawTaskPickerBG(context, parent: parent)
    }
    
    func drawTaskPickerBG(context: CGContextRef, parent: CGRect) {
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()

        // Gradient
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        let colors = [CGColorCreate(colorSpaceRGB, [0.0, 0.8, 0.0, 1.0])!,
            CGColorCreate(colorSpaceRGB, [0.0, 0.8, 0.0, 1.0])!]
        let gradient = CGGradientCreateWithColors(colorSpaceRGB,
            colors, locations)
        let startPoint = CGPoint(x:0.0, y:0.0)
        let endPoint =  CGPoint(x:0.0, y:parent.height)
        CGContextDrawLinearGradient(context, gradient,
            startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
    }




    func drawWorkListTool(context: CGContextRef, parent: CGRect, viewType: ViewType, toolbarInfo: ToolbarInfo) {
        drawTaskPickerTool(context, parent: parent, viewType: viewType, toolbarInfo: toolbarInfo)
    }
    
    func drawTaskPickerTool(context: CGContextRef, parent: CGRect, viewType: ViewType, toolbarInfo: ToolbarInfo) {
        // Gradient
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        
        let foregroundColorWhite = UIColor(white: 1.0, alpha: 1.0).CGColor
        _ = UIColor(white: 0.0, alpha: 1.0).CGColor

        let backgroundColorsNeutral = [CGColorCreate(colorSpaceRGB, [0.3, 0.3, 0.3, 1.0])!,
            CGColorCreate(colorSpaceRGB, [0.2, 0.2, 0.2, 1.0])!]

        let backgroundColorsRed = [CGColorCreate(colorSpaceRGB, [0.7, 0.7, 0.7, 1.0])!,
            CGColorCreate(colorSpaceRGB, [0.4, 0.0, 0.0, 1.0])!]

        let backgroundColorsGreen = [CGColorCreate(colorSpaceRGB, [0.7, 0.7, 0.7, 1.0])!,
            CGColorCreate(colorSpaceRGB, [0.0, 0.4, 0.0, 1.0])!]
        
        let colorspace = CGColorSpaceCreateDeviceRGB()
        var gradient = CGGradientCreateWithColors(colorspace, backgroundColorsNeutral, locations)
        let foregroundColor = foregroundColorWhite
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
        }
        
        var startPoint = CGPoint()
        var endPoint =  CGPoint()
        startPoint.x = 0.0
        startPoint.y = 0.0
        endPoint.x = 0
        endPoint.y = parent.height
        CGContextDrawLinearGradient(context, gradient,
            startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
        
        ThemeUtilities.addText(context, text: text, origin: CGPoint(x:parent.width/2, y:parent.height/2), fontSize: bigSize, withFrame: false, foregroundColor: foregroundColor)
    }


    
    func drawTaskPickerButton(context: CGContextRef, parent: CGRect, taskPosition: Int, selectionAreaInfo: SelectionAreaInfo) {
        // Gradient
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        var colors = [CGColorCreate(colorSpaceRGB, [0.3, 0.3, 0.3, 1.0])!,
            CGColorCreate(colorSpaceRGB, [0.2, 0.2, 0.2, 1.0])!]
        if let active = selectionAreaInfo.active {
            if active {
                if let ongoing = selectionAreaInfo.ongoing {
                    if ongoing {
                        colors = [CGColorCreate(colorSpaceRGB, [0.5, 0.6, 0.5, 1.0])!,
                            CGColorCreate(colorSpaceRGB, [0.5, 0.6, 0.5, 1.0])!]
                    } else {
                        colors = [CGColorCreate(colorSpaceRGB, [0.6, 0.5, 0.5, 1.0])!,
                            CGColorCreate(colorSpaceRGB, [0.6, 0.5, 0.5, 1.0])!]
                    }
                }
            }
        }
        let gradient = CGGradientCreateWithColors(colorSpaceRGB,
            colors, locations)
        let startPoint = CGPoint(x: 0.0, y:0.0)
        let endPoint =  CGPoint(x:0, y:parent.height)
        CGContextDrawLinearGradient(context, gradient,
            startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
        
        let color = UIColor(white: 1.0, alpha: 1.0).CGColor
        if let task = selectionAreaInfo.task {
            if let comment = ThemeUtilities.getComment(task.name) {
                if let colorString = ThemeUtilities.getValue(comment, forTag: "color") {
                    let colorSquare = ThemeUtilities.string2color(colorString).CGColor
                    let colorsSquare = [colorSquare, colorSquare]
                    let locationSquare: [CGFloat] = [ 0.0, 1.0 ]
                    let gradientSquare = CGGradientCreateWithColors(colorSpaceRGB, colorsSquare, locationSquare)
                    let startPointSquare = CGPoint(x: 4, y: 4)
                    let endPointSquare = CGPoint(x: 8, y: 8)
                    CGContextSaveGState(context)
                    //            CGContextClipToRect(context, CGRectMake(3, 3, 7, 7))
                    CGContextDrawLinearGradient(context, gradientSquare, startPointSquare, endPointSquare, CGGradientDrawingOptions(rawValue: 0))
                    CGContextRestoreGState(context)
                }
            } else {
                // Do nothing
            }
            let withoutComment = ThemeUtilities.getWithoutComment(task.name)
            if withoutComment != "" {
                ThemeUtilities.addText(context, text: withoutComment, origin: CGPoint(x:parent.width/2, y:parent.height/4), fontSize: bigSize, withFrame: false, foregroundColor: color)
            }
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
        let attributes: [String: AnyObject] = [
            NSForegroundColorAttributeName : foregroundColor,
            NSFontAttributeName : UIFont.systemFontOfSize(fontSize)
        ]
        //let font = attributes[NSFontAttributeName] as! UIFont
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
    
    class func getComment(source: String) -> String? {
        var comment: String?
        let x = source.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "#"))
        if x.count==2 {
            comment = x[1]
        }
        return comment
    }
    
    class func getWithoutComment(source: String) -> String {
        var text = ""
        let x = source.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "#"))
        if x.count>=1 {
            text = x[0]
        }
        return text
    }
    
    class func getValue(source: String, forTag: String) -> String? {
        let props=source.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: ","))
        var value: String?
        for s in props {
            if s.hasPrefix("color") {
                let part = s.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "="))
                if part.count == 2 {
                    value = part[1]
                }
            }
        }
        return value
    }
    
    class func string2color(text: String) -> UIColor {
        //var color: UIColor?
        let r = text[text.startIndex.advancedBy(0)]
        let red = hexchar2value(r)
        let g = text[text.startIndex.advancedBy(1)]
        let green = hexchar2value(g)
        let b = text[text.startIndex.advancedBy(2)]
        let blue = hexchar2value(b)
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    class func hexchar2value(ch: Character) -> CGFloat {
        switch ch {
        case "0": return 0.0
        case "1": return 1.0/16.0
        case "2": return 2.0/16.0
        case "3": return 3.0/16.0
        case "4": return 4.0/16.0
        case "5": return 5.0/16.0
        case "6": return 6.0/16.0
        case "7": return 7.0/16.0
        case "8": return 8.0/16.0
        case "9": return 9.0/16.0
        case "a": return 10.0/16.0
        case "b": return 11.0/16.0
        case "c": return 12.0/16.0
        case "d": return 13.0/16.0
        case "e": return 14.0/16.0
        case "f": return 15.0/16.0
        default: return 0.0
        }
    }

    class func getImageWithColor(color: UIColor, width: CGFloat, height: CGFloat) -> UIImage {                    
        let rect = CGRectMake(0.0, 0.0, width, height);
        UIGraphicsBeginImageContext(rect.size);
        let context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return image
    }
}

