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
    case signInSignOut, infoArea, add, sessionName
}


/////////////// --- Views --- //////////////////

class TimePoliceBGView: UIView {

    var theme: Theme?

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else {
            UtilitiesApplog.logDefault("TimePoliceBGView", logtype: .guard, message: "drawRect")
            return
        }
        theme?.drawTimePoliceBG(context, parent: rect)
    }

}

class TaskPickerBGView: UIView {

    var theme: Theme?

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else {
            UtilitiesApplog.logDefault("TaskPickerBGView", logtype: .guard, message: "drawRect")
            return
        }
        theme?.drawTaskPickerBG(context, parent: rect)
    }
}

class TaskEntriesBGView: UIView {

    var theme: Theme?

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else {
            UtilitiesApplog.logDefault("TaskEntriesBGView", logtype: .guard, message: "drawRect")
            return
        }
        theme?.drawTaskEntriesBG(context, parent: rect)
    }
}

class TaskPickerButtonView: UIView {
    
    var taskPosition: Int?
    var selectionAreaInfoDelegate: SelectionAreaInfoDelegate?
    var theme: Theme?

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext(),
                let i = taskPosition,
                let selectionAreaInfo = selectionAreaInfoDelegate?.getSelectionAreaInfo(i) else {
            UtilitiesApplog.logDefault("TaskPickerButtonView", logtype: .guard, message: "drawRect")
            return
        }
        theme?.drawTaskPickerButton(context, parent: rect, taskPosition: i, selectionAreaInfo: selectionAreaInfo)
    }
}

class TaskPickerToolView: UIView {
    
    var tool: ViewType?
    var toolbarInfoDelegate: ToolbarInfoDelegate?
    var theme: Theme?

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext(),
                let i = tool,
                let toolbarInfo = toolbarInfoDelegate?.getToolbarInfo() else {
            UtilitiesApplog.logDefault("TaskPickerToolView", logtype: .guard, message: "drawRect")
            return
        }
        theme?.drawTaskPickerTool(context, parent: rect, viewType: i, toolbarInfo: toolbarInfo)
    }
}

class TaskEntriesToolView: UIView {
    
    var tool: ViewType?
    var toolbarInfoDelegate: ToolbarInfoDelegate?
    var theme: Theme?

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext(),
                let i = tool ,
                let toolbarInfo = toolbarInfoDelegate?.getToolbarInfo() else {
            UtilitiesApplog.logDefault("TaskEntriesToolView", logtype: .guard, message: "drawRect")
            return
        }
        theme?.drawTaskEntriesTool(context, parent: rect, viewType: i, toolbarInfo: toolbarInfo)
    }
}

class TaskPickerPageIndicatorView : UIView {
    var toolbarInfoDelegate: ToolbarInfoDelegate?
    var theme: Theme?

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext(),
            let toolbarInfo = toolbarInfoDelegate?.getToolbarInfo() else {
                UtilitiesApplog.logDefault("TaskEntriesToolView", logtype: .guard, message: "drawRect")
                return
            }
        theme?.drawTaskPickerPageIndicator(context, parent: rect, numberOfPages: toolbarInfo.numberOfPages, currentPage: toolbarInfo.currentPage)
    }
}

class TaskEntriesPageIndicatorView : UIView {
    var toolbarInfoDelegate: ToolbarInfoDelegate?
    var theme: Theme?

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext(),
            let toolbarInfo = toolbarInfoDelegate?.getToolbarInfo() else {
                UtilitiesApplog.logDefault("TaskEntriesToolView", logtype: .guard, message: "drawRect")
                return
            }
        theme?.drawTaskEntriesPageIndicator(context, parent: rect, numberOfPages: toolbarInfo.numberOfPages, currentPage: toolbarInfo.currentPage)
    }
}

/////////////// --- Delegates --- //////////////////


protocol SelectionAreaInfoDelegate {
    func getSelectionAreaInfo(_ selectionArea: Int) -> SelectionAreaInfo
}

class SelectionAreaInfo {
    var task: Task?
    var numberOfTimesActivated: Int?
    var totalTimeActive: TimeInterval?
    var active: Bool?
    var activatedAt: Date?
    var ongoing: Bool?
}

protocol ToolbarInfoDelegate {
    func getToolbarInfo() -> ToolbarInfo
}

class ToolbarInfo {
    var signedIn: Bool
    var totalTimesActivatedForSession: Int
    var totalTimeActiveForSession: TimeInterval
    var sessionName: String
    var numberOfPages: Int
    var currentPage: Int
    init(signedIn: Bool, totalTimesActivatedForSession: Int, totalTimeActiveForSession: TimeInterval, sessionName: String,
        numberOfPages: Int, currentPage: Int) {
        self.signedIn = signedIn
        self.totalTimesActivatedForSession = totalTimesActivatedForSession
        self.totalTimeActiveForSession = totalTimeActiveForSession
        self.sessionName = sessionName
        self.numberOfPages = numberOfPages
        self.currentPage = currentPage
    }
}

/////////////// --- Visuals --- //////////////////

protocol Theme {
    func drawTimePoliceBG(_ context: CGContext, parent: CGRect)

    func drawTaskPickerBG(_ context: CGContext, parent: CGRect)
    func drawTaskPickerTool(_ context: CGContext, parent: CGRect, viewType: ViewType, toolbarInfo: ToolbarInfo)
    func drawTaskPickerButton(_ context: CGContext, parent: CGRect, taskPosition: Int, selectionAreaInfo: SelectionAreaInfo)
    func drawTaskPickerPageIndicator(_ context: CGContext, parent: CGRect, numberOfPages: Int, currentPage: Int)
    
    func drawTaskEntriesBG(_ context: CGContext, parent: CGRect)
    func drawTaskEntriesTool(_ context: CGContext, parent: CGRect, viewType: ViewType, toolbarInfo: ToolbarInfo)
    func drawTaskEntriesPageIndicator(_ context: CGContext, parent: CGRect, numberOfPages: Int, currentPage: Int)
}











class BasicTheme : Theme {
    
    let bigSize:CGFloat = CGFloat(themeBigTextSize)
    let smallSize:CGFloat = CGFloat(themeSmallTextSize)
    

    func drawTimePoliceBG(_ context: CGContext, parent: CGRect) {
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        
        // Gradient
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        let colors = [CGColor(colorSpace: colorSpaceRGB, components: [0.4, 0.4, 0.6, 1.0])!,
            CGColor(colorSpace: colorSpaceRGB, components: [0.6, 0.6, 0.9, 1.0])!]
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorspace,
            colors: colors as CFArray, locations: locations)
        var startPoint = CGPoint()
        var endPoint =  CGPoint()
        startPoint.x = 0.0
        startPoint.y = 0.0
        endPoint.x = 0
        endPoint.y = 700
        context.drawLinearGradient(gradient!,
            start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        
    }
    


    func drawTaskEntriesBG(_ context: CGContext, parent: CGRect) {
        drawTaskPickerBG(context, parent: parent)
    }

    func drawTaskPickerBG(_ context: CGContext, parent: CGRect) {
        // Gradient
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        let colors = [CGColor(colorSpace: colorSpaceRGB, components: [0.0, 1.0, 0.0, 1.0])!,
            CGColor(colorSpace: colorSpaceRGB, components: [0.8, 1.0, 0.8, 1.0])!]
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorspace,
            colors: colors as CFArray, locations: locations)
        var startPoint = CGPoint()
        var endPoint =  CGPoint()
        startPoint.x = 0.0
        startPoint.y = 0.0
        endPoint.x = 0
        endPoint.y = parent.height
        context.drawLinearGradient(gradient!,
            start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
    }



    func drawTaskEntriesTool(_ context: CGContext, parent: CGRect, viewType: ViewType, toolbarInfo: ToolbarInfo) {
        drawTaskPickerTool(context, parent: parent, viewType: viewType, toolbarInfo: toolbarInfo)
    }
    
    func drawTaskPickerTool(_ context: CGContext, parent: CGRect, viewType: ViewType, toolbarInfo: ToolbarInfo) {
        // Gradient
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        
        let foregroundColorWhite = UIColor(white: 1.0, alpha: 1.0).cgColor
        let foregroundColorBlack = UIColor(white: 0.0, alpha: 1.0).cgColor
        let backgroundColorsGrey = [CGColor(colorSpace: colorSpaceRGB, components: [1.0, 1.0, 1.0, 1.0])!,
            CGColor(colorSpace: colorSpaceRGB, components: [0.6, 0.6, 0.6, 1.0])!]
        let backgroundColorsRed = [CGColor(colorSpace: colorSpaceRGB, components: [1.0, 1.0, 1.0, 1.0])!,
            CGColor(colorSpace: colorSpaceRGB, components: [0.8, 0.0, 0.0, 1.0])!]
        let backgroundColorsGreen = [CGColor(colorSpace: colorSpaceRGB, components: [1.0, 1.0, 1.0, 1.0])!,
            CGColor(colorSpace: colorSpaceRGB, components: [0.0, 0.8, 0.0, 1.0])!]
        
        let colorspace = CGColorSpaceCreateDeviceRGB()
        var gradient = CGGradient(colorsSpace: colorspace, colors: backgroundColorsGrey as CFArray, locations: locations)
        var foregroundColor = foregroundColorBlack
        var text: String
        switch viewType {
        case .sessionName:
            text = toolbarInfo.sessionName
        case .signInSignOut:
            if toolbarInfo.signedIn {
                text = "Stop"
                gradient = CGGradient(colorsSpace: colorspace, colors: backgroundColorsGreen as CFArray, locations: locations)
            } else {
                text = "Start"
                gradient = CGGradient(colorsSpace: colorspace, colors: backgroundColorsRed as CFArray, locations: locations)
                foregroundColor = foregroundColorWhite
            }
        case .infoArea:
            text = "\(toolbarInfo.totalTimesActivatedForSession)    \(UtilitiesDate.getString(toolbarInfo.totalTimeActiveForSession))"
        case .add:
            text = "Add"
        }
        
        var startPoint = CGPoint()
        var endPoint =  CGPoint()
        startPoint.x = 0.0
        startPoint.y = 0.0
        endPoint.x = 0
        endPoint.y = parent.height
        context.drawLinearGradient(gradient!,
            start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        
        ThemeUtilities.addText(context, text: text, origin: CGPoint(x:parent.width/2, y:parent.height/2), fontSize: bigSize, withFrame: false, foregroundColor: foregroundColor)
    }



    func drawTaskPickerButton(_ context: CGContext, parent: CGRect, taskPosition: Int, selectionAreaInfo: SelectionAreaInfo) {
        // Gradient
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        var colors = [CGColor(colorSpace: colorSpaceRGB, components: [1.0, 1.0, 1.0, 1.0])!,
            CGColor(colorSpace: colorSpaceRGB, components: [0.5, 0.5, 1.0, 1.0])!]
        if let a = selectionAreaInfo.active {
            if a==true {
                colors = [CGColor(colorSpace: colorSpaceRGB, components: [1.0, 1.0, 1.0, 1.0])!,
                    CGColor(colorSpace: colorSpaceRGB, components: [1.0, 1.0, 1.0, 1.0])!]
            }
        }
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorspace,
            colors: colors as CFArray, locations: locations)
        var startPoint = CGPoint()
        var endPoint =  CGPoint()
        startPoint.x = 0.0
        startPoint.y = 0.0
        endPoint.x = 0
        endPoint.y = parent.height
        context.drawLinearGradient(gradient!,
            start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        
        let color = UIColor(white: 0.0, alpha: 1.0).cgColor
        if let t = selectionAreaInfo.task {
            // TODO: If task.name ends with #RGB, add small square to the left of the name
            ThemeUtilities.addText(context, text: t.name, origin: CGPoint(x:parent.width/2, y:parent.height/4), fontSize: bigSize, withFrame: false, foregroundColor: color)
        }
        if let active = selectionAreaInfo.active {
            if active == true {
                if let activatedAt = selectionAreaInfo.activatedAt {
                    let now = Date()
                    let activeTime = now.timeIntervalSince(activatedAt)
                    ThemeUtilities.addText(context, text: UtilitiesDate.getString(activeTime), origin: CGPoint(x:parent.width/2, y:parent.height/4*3), fontSize: smallSize, withFrame: false, foregroundColor: color)
                }
            } else {
                if let numberOfTimesActivated = selectionAreaInfo.numberOfTimesActivated {
                    ThemeUtilities.addText(context, text: String(numberOfTimesActivated), origin: CGPoint(x:parent.width/4, y:parent.height/4*3), fontSize: smallSize, withFrame: false, foregroundColor: color)
                }
                if let totalTimeActive = selectionAreaInfo.totalTimeActive {
                    ThemeUtilities.addText(context, text: UtilitiesDate.getString(totalTimeActive), origin: CGPoint(x:parent.width/4*3, y:parent.height/4*3), fontSize: smallSize, withFrame: false, foregroundColor: color)
                }
            
            }
        }
    }

    func drawTaskEntriesPageIndicator(_ context: CGContext, parent: CGRect, numberOfPages: Int, currentPage: Int) {
        drawTaskPickerPageIndicator(context, parent: parent, numberOfPages: numberOfPages, currentPage: currentPage)
    }

    func drawTaskPickerPageIndicator(_ context: CGContext, parent: CGRect, numberOfPages: Int, currentPage: Int) {
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        let colorsCurrent = [CGColor(colorSpace: colorSpaceRGB, components: [1.0, 1.0, 1.0, 1.0])!,
            CGColor(colorSpace: colorSpaceRGB, components: [1.0, 1.0, 1.0, 1.0])!]
        let gradientCurrent = CGGradient(colorsSpace: colorSpaceRGB,
            colors: colorsCurrent as CFArray, locations: locations)
        let colorsNotCurrent = [CGColor(colorSpace: colorSpaceRGB, components: [0.5, 0.5, 0.5, 1.0])!,
            CGColor(colorSpace: colorSpaceRGB, components: [0.5, 0.5, 0.5, 1.0])!]
        let gradientNotCurrent = CGGradient(colorsSpace: colorSpaceRGB,
            colors: colorsNotCurrent as CFArray, locations: locations)

        let indicatorWidth = parent.size.width / CGFloat(numberOfPages)
        for i in 0...numberOfPages-1 {
            let startPoint = CGPoint(x: CGFloat(i)*indicatorWidth + 1, y: 0.0)
            let endPoint = CGPoint(x: CGFloat(i+1)*indicatorWidth - 1, y: 0.0)
            if i == currentPage {
                context.drawLinearGradient(gradientCurrent!,
                    start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
            } else {
                context.drawLinearGradient(gradientNotCurrent!,
                    start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
            }
        }
    }

}











class BlackGreenTheme : Theme {
    
    let bigSize:CGFloat = CGFloat(themeBigTextSize)
    let smallSize:CGFloat = CGFloat(themeSmallTextSize)
    

    func drawTimePoliceBG(_ context: CGContext, parent: CGRect) {
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        
        // Top area
//        let locations1: [CGFloat] = [ 0.0, 1.0 ]
//        let colors1 = [CGColor(colorSpace: colorSpaceRGB, components: [0.3, 0.3, 0.3, 1.0])!,
//            CGColor(colorSpace: colorSpaceRGB, components: [0.5, 0.75, 0.5, 1.0])!]
//        let gradient1 = CGGradient(colorsSpace: colorSpaceRGB,
//            colors: colors1 as CFArray, locations: locations1)
//        let startPoint1 = CGPoint(x:0.0, y:0.0)
//        let endPoint1 =  CGPoint(x:0.0, y:30.0)
//        context.drawLinearGradient(gradient1!,
//            start: startPoint1, end: endPoint1, options: CGGradientDrawingOptions(rawValue: 0))

        // Gradient
        let locations2: [CGFloat] = [ 0.0, 1.0 ]
        let colors2 = [CGColor(colorSpace: colorSpaceRGB, components: [0.0, 0.0, 0.0, 1.0])!,
            CGColor(colorSpace: colorSpaceRGB, components: [0.0, 0.0, 0.0, 1.0])!]
        let gradient2 = CGGradient(colorsSpace: colorSpaceRGB,
            colors: colors2 as CFArray, locations: locations2)
        let startPoint2 = CGPoint(x:0.0, y:30.0)
        let endPoint2 =  CGPoint(x:0.0, y:parent.height)
        context.drawLinearGradient(gradient2!,
            start: startPoint2, end: endPoint2, options: CGGradientDrawingOptions(rawValue: 0))
    }
    


    func drawTaskEntriesBG(_ context: CGContext, parent: CGRect) {
        drawTaskPickerBG(context, parent: parent)
    }
    
    func drawTaskPickerBG(_ context: CGContext, parent: CGRect) {
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()

        // Gradient
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        let colors = [CGColor(colorSpace: colorSpaceRGB, components: [0.0, 0.8, 0.0, 1.0])!,
            CGColor(colorSpace: colorSpaceRGB, components: [0.0, 0.8, 0.0, 1.0])!]
        let gradient = CGGradient(colorsSpace: colorSpaceRGB,
            colors: colors as CFArray, locations: locations)
        let startPoint = CGPoint(x:0.0, y:0.0)
        let endPoint =  CGPoint(x:0.0, y:parent.height)
        context.drawLinearGradient(gradient!,
            start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
    }




    func drawTaskEntriesTool(_ context: CGContext, parent: CGRect, viewType: ViewType, toolbarInfo: ToolbarInfo) {
        drawTaskPickerTool(context, parent: parent, viewType: viewType, toolbarInfo: toolbarInfo)
    }
    
    func drawTaskPickerTool(_ context: CGContext, parent: CGRect, viewType: ViewType, toolbarInfo: ToolbarInfo) {
        // Gradient
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        
        let foregroundColorWhite = UIColor(white: 1.0, alpha: 1.0).cgColor
        _ = UIColor(white: 0.0, alpha: 1.0).cgColor

//        let backgroundColorsNeutral = [CGColor(colorSpace: colorSpaceRGB, components: [0.3, 0.3, 0.3, 1.0])!,
//            CGColor(colorSpace: colorSpaceRGB, components: [0.2, 0.2, 0.2, 1.0])!]
        let backgroundColorsNeutral = [CGColor(colorSpace: colorSpaceRGB, components: [0.0, 0.0, 0.0, 1.0])!,
                                       CGColor(colorSpace: colorSpaceRGB, components: [0.0, 0.0, 0.0, 1.0])!]

        let backgroundColorsRed = [CGColor(colorSpace: colorSpaceRGB, components: [0.7, 0.7, 0.7, 1.0])!,
            CGColor(colorSpace: colorSpaceRGB, components: [0.4, 0.0, 0.0, 1.0])!]

        let backgroundColorsGreen = [CGColor(colorSpace: colorSpaceRGB, components: [0.7, 0.7, 0.7, 1.0])!,
            CGColor(colorSpace: colorSpaceRGB, components: [0.0, 0.4, 0.0, 1.0])!]
        
        let colorspace = CGColorSpaceCreateDeviceRGB()
        var gradient = CGGradient(colorsSpace: colorspace, colors: backgroundColorsNeutral as CFArray, locations: locations)
        let foregroundColor = foregroundColorWhite
        var text: String

        switch viewType {
        case .sessionName:
            text = toolbarInfo.sessionName
        case .signInSignOut:
            if toolbarInfo.signedIn {
                text = "Stop"
                gradient = CGGradient(colorsSpace: colorspace, colors: backgroundColorsGreen as CFArray, locations: locations)
            } else {
                text = "Continue"
                gradient = CGGradient(colorsSpace: colorspace, colors: backgroundColorsRed as CFArray, locations: locations)
            }
        case .infoArea:
            text = "Completed: \(toolbarInfo.totalTimesActivatedForSession)    Total time: \(UtilitiesDate.getString(toolbarInfo.totalTimeActiveForSession))"
        case .add:
            text = "Add"
        }
        
        var startPoint = CGPoint()
        var endPoint =  CGPoint()
        startPoint.x = 0.0
        startPoint.y = 0.0
        endPoint.x = 0
        endPoint.y = parent.height
        context.drawLinearGradient(gradient!,
            start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        
        ThemeUtilities.addText(context, text: text, origin: CGPoint(x:parent.width/2, y:parent.height/2), fontSize: bigSize, withFrame: false, foregroundColor: foregroundColor)
    }


    
    func drawTaskPickerButton(_ context: CGContext, parent: CGRect, taskPosition: Int, selectionAreaInfo: SelectionAreaInfo) {
        // Gradient
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [ 0.0, 1.0 ]
//        var colors = [CGColor(colorSpace: colorSpaceRGB, components: [0.3, 0.3, 0.3, 1.0])!,
//            CGColor(colorSpace: colorSpaceRGB, components: [0.2, 0.2, 0.2, 1.0])!]
        var colors = [CGColor(colorSpace: colorSpaceRGB, components: [0.0, 0.0, 0.0, 1.0])!,
                      CGColor(colorSpace: colorSpaceRGB, components: [0.0, 0.0, 0.0, 1.0])!]
        if let active = selectionAreaInfo.active {
            if active {
                if let ongoing = selectionAreaInfo.ongoing {
                    if ongoing {
                        colors = [CGColor(colorSpace: colorSpaceRGB, components: [0.5, 0.6, 0.5, 1.0])!,
                            CGColor(colorSpace: colorSpaceRGB, components: [0.5, 0.6, 0.5, 1.0])!]
                    } else {
                        colors = [CGColor(colorSpace: colorSpaceRGB, components: [0.6, 0.5, 0.5, 1.0])!,
                            CGColor(colorSpace: colorSpaceRGB, components: [0.6, 0.5, 0.5, 1.0])!]
                    }
                }
            }
        }
        let gradient = CGGradient(colorsSpace: colorSpaceRGB,
            colors: colors as CFArray, locations: locations)
        let startPoint = CGPoint(x: 0.0, y:0.0)
        let endPoint =  CGPoint(x:0, y:parent.height)
        context.drawLinearGradient(gradient!,
            start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        
        let color = UIColor(white: 1.0, alpha: 1.0).cgColor
        if let task = selectionAreaInfo.task {
            if task.name != spacerName {
                if let colorString = task.getProperty("color") {
                    let colorSquare = UtilitiesColor.string2color(colorString).cgColor
                    let colorsSquare = [colorSquare, colorSquare]
                    let locationSquare: [CGFloat] = [ 0.0, 1.0 ]
                    let gradientSquare = CGGradient(colorsSpace: colorSpaceRGB, colors: colorsSquare as CFArray, locations: locationSquare)
                    let startPointSquare = CGPoint(x: 4, y: 4)
                    let endPointSquare = CGPoint(x: 8, y: 8)
                    context.saveGState()
                    //            CGContextClipToRect(context, CGRectMake(3, 3, 7, 7))
                    context.drawLinearGradient(gradientSquare!, start: startPointSquare, end: endPointSquare, options: CGGradientDrawingOptions(rawValue: 0))
                    context.restoreGState()
                }
                ThemeUtilities.addText(context, text: task.name, origin: CGPoint(x:parent.width/2, y:parent.height/4), fontSize: bigSize, withFrame: false, foregroundColor: color)
            }
        }
        
        if let ongoing = selectionAreaInfo.ongoing {
            if ongoing {
                if let activatedAt = selectionAreaInfo.activatedAt {
                    let now = Date()
                    let activeTime = now.timeIntervalSince(activatedAt)
                    ThemeUtilities.addText(context, text: UtilitiesDate.getString(activeTime), origin: CGPoint(x:parent.width/2, y:parent.height/4*3), fontSize: smallSize, withFrame: false, foregroundColor: color)
                }
            } else {
                if let numberOfTimesActivated = selectionAreaInfo.numberOfTimesActivated {
                    ThemeUtilities.addText(context, text: String(numberOfTimesActivated), origin: CGPoint(x:parent.width/4, y:parent.height/4*3), fontSize: smallSize, withFrame: false, foregroundColor: color)
                }
                if let totalTimeActive = selectionAreaInfo.totalTimeActive {
                    ThemeUtilities.addText(context, text: UtilitiesDate.getString(totalTimeActive), origin: CGPoint(x:parent.width/4*3, y:parent.height/4*3), fontSize: smallSize, withFrame: false, foregroundColor: color)
                }
            }
        }
    }
    
    func drawTaskEntriesPageIndicator(_ context: CGContext, parent: CGRect, numberOfPages: Int, currentPage: Int) {
        drawTaskPickerPageIndicator(context, parent: parent, numberOfPages: numberOfPages, currentPage: currentPage)
    }

    func drawTaskPickerPageIndicator(_ context: CGContext, parent: CGRect, numberOfPages: Int, currentPage: Int) {
        let locations: [CGFloat] = [ 0.0, 1.0 ]
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        let colorsCurrent = [CGColor(colorSpace: colorSpaceRGB, components: [0.5, 0.5, 0.5, 1.0])!,
            CGColor(colorSpace: colorSpaceRGB, components: [0.5, 0.5, 0.5, 1.0])!]
        let gradientCurrent = CGGradient(colorsSpace: colorSpaceRGB,
            colors: colorsCurrent as CFArray, locations: locations)
        let colorsNotCurrent = [CGColor(colorSpace: colorSpaceRGB, components: [0.3, 0.3, 0.3, 1.0])!,
            CGColor(colorSpace: colorSpaceRGB, components: [0.3, 0.3, 0.3, 1.0])!]
        let gradientNotCurrent = CGGradient(colorsSpace: colorSpaceRGB,
            colors: colorsNotCurrent as CFArray, locations: locations)

        let indicatorWidth = parent.size.width / CGFloat(numberOfPages)
        for i in 0...numberOfPages-1 {
            let startPoint = CGPoint(x: CGFloat(i)*indicatorWidth + 1, y: 0.0)
            let endPoint = CGPoint(x: CGFloat(i+1)*indicatorWidth - 1, y: 0.0)
            if i == currentPage {
                context.drawLinearGradient(gradientCurrent!,
                    start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
            } else {
                context.drawLinearGradient(gradientNotCurrent!,
                    start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
            }
        }
    }

}



/////////////// --- Helpers --- //////////////////

class ThemeUtilities {
    
    class func addText(_ context: CGContext, text: String, origin: CGPoint, fontSize: CGFloat, withFrame: Bool, foregroundColor: CGColor) {
        context.saveGState()
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor : foregroundColor,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize)
        ]
        //let font = attributes[NSFontAttributeName] as! UIFont
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = text.size(withAttributes: attributes)
        context.textMatrix = CGAffineTransform(scaleX: 1.0, y: -1.0);
        let size = CGSize(width:Int(textSize.width+0.5)+1, height:Int(textSize.height+0.5))
        let textRect = CGRect(
            origin: CGPoint(x: origin.x-textSize.width/2, y:origin.y),
            size: size)
        let textPath    = CGPath(rect: textRect, transform: nil)
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedString)
        let frame       = CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: 0), textPath, nil)
        CTFrameDraw(frame, context)
        context.restoreGState()
        
        // Rectangle
        if(withFrame) {
            context.setLineWidth(1.0)
            context.setStrokeColor(UIColor.blue.cgColor)
            let rect = CGRect(x:origin.x-textSize.width/2, y: origin.y-textSize.height/2, width: textSize.width, height: textSize.height)
            context.addRect(rect)
            context.strokePath()
        }
    }
    
}

