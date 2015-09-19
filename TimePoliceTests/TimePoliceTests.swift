//
//  TimePoliceTests.swift
//  TimePoliceTests
//
//  Created by Per Ekskog on 2014-11-04.
//  Copyright (c) 2014 Per Ekskog. All rights reserved.
//

import UIKit
import XCTest

class TimePoliceProjectTemplateManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
   
    /*
     func testProject() {
        let t1 = Task(name:"t1")
        let t2 = Task(name:"t1")
        let t3 = Task(name:"t2")
        let tl1 = [t1, t2, t3]
        let p1Name = "Project 1"
        let s1Name = "Session 1"
        let s2Name = "Session 2"
        let tss = TaskSelectAny()
        let p1 = Project(name: p1Name, taskSelectionStrategy: tss, taskList: tl1)
        let s1 = Session(name: s1Name, taskList: tl1)
        let s2 = Session(name: s2Name, taskList: tl1)

        p1.addSession(s1)
        XCTAssertEqual(1, p1.sessionList.count)
        XCTAssertEqual(s1Name, p1.sessionList[s1Name]!.name)

        p1.addSession(s2)
        XCTAssertEqual(2, p1.sessionList.count)
        XCTAssertEqual(s2Name, p1.sessionList[s2Name]!.name)        

        p1.removeSession(s1)
        XCTAssertEqual(1, p1.sessionList.count)
        XCTAssertEqual(s2Name, p1.sessionList[s2Name]!.name)
        XCTAssert(nil==p1.sessionList[s1Name])
    }
*/
    /*
    func testSession() {
        let t1 = Task(name:"t1")
        let t2 = Task(name:"t1")
        let t3 = Task(name:"t2")
        let tl1 = [t1, t2, t3]
        let s1Name = "Session 1"
        let s1 = Session(name: s1Name, taskList: tl1)
        XCTAssert(s1.workDone.count==0)
        s1.taskSignIn(t1)
        XCTAssertEqual(s1.currentWork!.task, t1)
        s1.taskSignOut(t1)
        XCTAssert(s1.currentWork == nil)
        XCTAssert(s1.workDone.count==1)
        XCTAssertEqual(s1.workDone[0].task, t1)
        s1.taskSignIn(t2)
        XCTAssertEqual(s1.currentWork!.task, t2)
        s1.taskSignOut(t2)
        XCTAssert(s1.currentWork == nil)
        XCTAssert(s1.workDone.count==2)
        XCTAssertEqual(s1.workDone[0].task, t1)
        XCTAssertEqual(s1.workDone[1].task, t2)
    }
*/

    func testWork() {
        // No tests, just a "struct"
        XCTAssert(true)
    }
 /*
    func testTask() {
        let t1 = Task(name:"t1")
        let t2 = Task(name:"t1")
        let t3 = Task(name:"t2")
        XCTAssertNotEqual(t1, t2, "\(t1.id) - \(t2.id)")
        XCTAssertNotEqual(t1, t3, "\(t1.id) - \(t3.id)")
        XCTAssertNotEqual(t2, t3, "\(t2.id) - \(t3.id)")
        XCTAssertEqual(t1.name, t2.name, "\(t1.name) - \(t2.name)")
        XCTAssertNotEqual(t2.name, t3.name, "\(t2.name),\(t3.name)")
        XCTAssertNotEqual(t1.name, t3.name, "\(t1.name),\(t3.name)")
    }
*/
    /*
    func testTaskSelectAny() {
        let t1 = Task(name:"t1")
        let t2 = Task(name:"t2")
        let t3 = Task(name:"t3")
        let tl = [t1, t2, t3]
        let tsa = TaskSelectAny()
        XCTAssertEqual(tl, tsa.selectableTasks(tl))
        tsa.taskSelected(t1)
        XCTAssertEqual(tl, tsa.selectableTasks(tl))
        tsa.taskUnselected(t1)
    }
*/
    /*
    func testTaskSelectInSequence() {
        let t1 = Task(name:"t1")
        let t2 = Task(name:"t2")
        let t3 = Task(name:"t3")
        let tl1 = [t1, t2, t3]
        let tl2 = [t2, t3]
        let tl3 = [t3]
        let tsa = TaskSelectInSequence()

        
        XCTAssertEqual(tl1, tsa.selectableTasks(tl1))

        tsa.taskSelected(t1)
        let x = tsa.selectableTasks(tl1)
        XCTAssertEqual(tl2, tsa.selectableTasks(tl1), "\(tsa.selectableTasks(tl1))")

        tsa.taskUnselected(t1)
        XCTAssertEqual(tl1, tsa.selectableTasks(tl1))

        tsa.taskSelected(t2)
        XCTAssertEqual(tl3, tsa.selectableTasks(tl1), "\(tsa.selectableTasks(tl1))")

        tsa.taskSelected(t3)
        XCTAssertEqual([], tsa.selectableTasks(tl1), "\(tsa.selectableTasks(tl1))")

        tsa.taskUnselected(t2)
        XCTAssertEqual([], tsa.selectableTasks(tl1), "\(tsa.selectableTasks(tl1))")

        tsa.taskUnselected(t3)
        XCTAssertEqual(tl1, tsa.selectableTasks(tl1), "\(tsa.selectableTasks(tl1))")
}
*/
    /*
    func testLayout() {
        let gl1 = GridLayout(rows: 4, columns: 2)
        XCTAssertEqual(gl1.numberOfSelectionAreas(), 8)

        let vr1 = CGRect(x:0, y:0, width:200, height:320)
        let v1 = TaskPickerBackgroundView(frame:vr1)
        let view1Frame = gl1.getViewRect(v1.frame, selectionArea: 0)
        XCTAssertEqual(view1Frame, CGRect(x:0, y:0, width:100, height:80))
        
        let view2Frame = gl1.getViewRect(v1.frame, selectionArea: 1)
        XCTAssertEqual(view2Frame, CGRect(x:100, y:0, width:100, height:80))
        
        let view3Frame = gl1.getViewRect(v1.frame, selectionArea: 2)
        XCTAssertEqual(view3Frame, CGRect(x:0, y:80, width:100, height:80))
    }
*/

    func testTheme() {
        XCTAssert(true)
        _ = BasicTheme()
    }

    /*
    class TaskSelectionHelper : SelectionAreaInfoDelegate {
            var taskSignInList: [Task]
            var taskSignOutList: [[Task]]
            init() {
                taskSignInList = []
                taskSignOutList = [[]]
            }
            func reset() {
                taskSignInList = []
                taskSignOutList = [[]]
            }
            func taskSignIn(task: Task) {
                taskSignInList.append(task)
            }
        func taskSignOut(task: Task) {
                taskSignOutList.append(taskSignInList)
            }
            func getSelectionAreaInfo(selectionArea: Int) -> SelectionAreaInfo {
                let dummy = Task(name: "dummy")
                let selectionAreaInfo = SelectionAreaInfo(
                    task: dummy,
                    numberOfTimesActivated: 13,
                    totalTimeActive: 120,
                    active: true,
                    activatedAt: NSDate())
                return selectionAreaInfo
            }
    }
*/
    /*
    func testTaskPicker1() {
        let view1 = TaskPickerBackgroundView(frame: CGRect(x: 0, y:0, width:200, height:320))
        let layout = GridLayout(rows: 2, columns: 1)
        let theme = BasicTheme()
        let t1 = Task(name:"t1")
        let t2 = Task(name:"t2")
        let t3 = Task(name:"t3")
        let tl1 = [t1, t2, t3]
        let s1Name = "Session 1"
        let s1 = Session(name: s1Name, taskList: tl1)
        let tsa = TaskSelectAny()
        let tsh = TaskSelectionHelper()
        let tp1 = TaskPicker(statustext: UITextView(), workspace: view1, layout: layout, theme: theme,  taskSelectionStrategy: tsa, taskList: tl1, totalTimeActive: [:], numberOfTimesActivated: [:])
        tp1.setup()

        for i in 0..<tp1.layout.numberOfSelectionAreas() {
            XCTAssert(tp1.taskIsSelectable(i), "task \(i)")
            if let view2 = tp1.views[i] {
                if let recognizers = view2.gestureRecognizers {
                    XCTAssertEqual(1, recognizers.count)
                    if let recognizer = recognizers[0] as? UITapGestureRecognizer {
                        if let taskIndex = tp1.recognizers[recognizer] {
                            XCTAssertEqual(i, taskIndex, "taskIndex=\(taskIndex), i=\(i)")
                        } else {
                            XCTAssert(false, "Gesture recognizer not found in TaskPicker")
                        }
                    } else {
                        XCTAssert(false, "First regonizer in view is not a GestureRecognizer")
                    }
                } else {
                    XCTAssert(false, "No gesture recognizer")
                }
            } else {
                XCTAssert(false, "No view")
            }
        }

    }
*/
/*
    func testTaskPicker2() {
        let view1 = TaskPickerBackgroundView(frame: CGRect(x: 0, y:0, width:200, height:320))
        let layout = GridLayout(rows: 2, columns: 1)
        let theme = BasicTheme()
        let t1 = Task(name:"t1")
        let t2 = Task(name:"t2")
        let t3 = Task(name:"t3")
        let tl1 = [t1, t2, t3]
        let s1Name = "Session 1"
        let s1 = Session(name: s1Name, taskList: tl1)
        let tsa = TaskSelectAny()
        let tsh = TaskSelectionHelper()
        let tp1 = TaskPicker(statustext: UITextView(), workspace: view1, layout: layout, theme: theme, taskSelectionStrategy: tsa, taskList: tl1, totalTimeActive: [:], numberOfTimesActivated: [:])
        
        tp1.setup()

        tp1.signIn()
        XCTAssertEqual(tsh.taskSignInList, [])
        XCTAssertEqual(tsh.taskSignOutList, [[]])

        tp1.signOut()
        XCTAssertEqual(tsh.taskSignInList, [])
        XCTAssertEqual(tsh.taskSignOutList, [[]])

        tp1.taskSelected(0)
        XCTAssertEqual(tsh.taskSignInList, [t1])
        XCTAssertEqual(1, tsh.taskSignOutList.count)
        XCTAssertEqual(tsh.taskSignOutList, [[]])

        tp1.taskSelected(2)
        XCTAssertEqual(tsh.taskSignInList, [t1, t3],
            "taskSignInList=\(tsh.taskSignInList[1].name)")
        XCTAssertEqual(2, tsh.taskSignOutList.count)
        var signoutlist = tsh.taskSignOutList[1]
        XCTAssertEqual(signoutlist, [t1], "taskSignOutList=\(signoutlist[0].name)")

        tp1.taskSelected(1)
        XCTAssertEqual(tsh.taskSignInList, [t1, t3, t2],
            "taskSignInList=\(tsh.taskSignInList[2].name)")
        XCTAssertEqual(3, tsh.taskSignOutList.count)
        signoutlist = tsh.taskSignOutList[2]
        XCTAssertEqual(signoutlist, [t1, t3], "taskSignOutList=\(signoutlist[1].name)")

        tp1.signOut()
        XCTAssertEqual(tsh.taskSignInList, [t1, t3, t2])
        XCTAssertEqual(4, tsh.taskSignOutList.count)
        signoutlist = tsh.taskSignOutList[3]
        XCTAssertEqual(signoutlist, [t1, t3, t2])

    }
*/
    /*
    func testTaskPicker3() {
        let view1 = TaskPickerBackgroundView(frame: CGRect(x: 0, y:0, width:200, height:320))
        let layout = GridLayout(rows: 2, columns: 1)
        let theme = BasicTheme()
        let t1 = Task(name:"t1")
        let t2 = Task(name:"t2")
        let t3 = Task(name:"t3")
        let tl1 = [t1, t2, t3]
        let s1Name = "Session 1"
        let s1 = Session(name: s1Name, taskList: tl1)
        let tsa = TaskSelectAny()
        let tsh = TaskSelectionHelper()
        let tp1 = TaskPicker(statustext: UITextView(), workspace: view1, layout: layout, theme: theme, taskSelectionStrategy: tsa, taskList: tl1, totalTimeActive: [:], numberOfTimesActivated: [:])
        tp1.setup()

        XCTAssertEqual(tsh.taskSignInList, [])
        XCTAssertEqual(tsh.taskSignOutList, [[]])

        // Simulate "tap" on first item
        if let view2 = tp1.views[0] {
            if let recognizers = view2.gestureRecognizers {
                if let recognizer = recognizers[0] as? UITapGestureRecognizer {
                    tp1.handleTap(recognizer)
                }
            }
        }
        XCTAssertEqual(tsh.taskSignInList, [t1])
        XCTAssertEqual(1, tsh.taskSignOutList.count)
        XCTAssertEqual(tsh.taskSignOutList, [[]])

        // Simulate "tap" on second item
        if let view3 = tp1.views[1] {
            if let recognizers = view3.gestureRecognizers {
                if let recognizer = recognizers[0] as? UITapGestureRecognizer {
                    tp1.handleTap(recognizer)
                }
            }
        }
        XCTAssertEqual(tsh.taskSignInList, [t1, t2],
            "taskSignInList=\(tsh.taskSignInList[1].name)")
        XCTAssertEqual(2, tsh.taskSignOutList.count)
        var signoutlist = tsh.taskSignOutList[1]
        XCTAssertEqual(signoutlist, [t1], "taskSignOutList=\(signoutlist[0].name)")

    }
*/
/*

    func testWorkSpace() {
        XCTAssert(true)
    }
*/
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}

class Unit_Test_ExampleTests: XCTestCase
{
    // we can't do much  without a view on our root View Controller
    func testViewDidLoad2()
    {
        // we only have access to this if we import our project above
        let v = TaskEntryCreatorByPickTaskVC()
        
        // assert that the ViewController.view is not nil
        XCTAssertNotNil(v.view, "View Did Not load")
    }
}
