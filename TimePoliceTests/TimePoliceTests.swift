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
   
    func testTimePolice() {

        // Create and setup TimePolice and other instances

        let tp = TimePolice()

        let t1 = Task(name: "Test task 1")
        let t2 = Task(name: "Test task 2")
        let t3 = Task(name: "Test task 3")

        let tl1 = [t1, t2, t3]
        let tl2 = [t3, t1]

        let pt1Name = "Test template 1"
        let pt2Name = "Test template 2"

        let pt1 = ProjectTemplate(name: pt1Name, taskList: tl1)
        let pt2 = ProjectTemplate(name: pt2Name, taskList: tl2)

        let p1Name = "Test project 1"
        let p2Name = "Test project 2"

        let tsa = TaskSelectAny()

        let p1 = Project(name: p1Name, taskSelectionStrategy: tsa, taskList: tl1)
        let p2 = Project(name: p2Name, taskSelectionStrategy: tsa, taskList: tl2)

        // Add templates

        XCTAssertEqual(tp.templateList.count, 0, "")
        XCTAssertEqual(tp.projectList.count, 0, "")

        tp.addTemplate(pt1)
        tp.addTemplate(pt2)

        XCTAssertEqual(tp.templateList.count, 2, "\(tp.templateList.count)")
        XCTAssertEqual(tp.projectList.count, 0, "")

        XCTAssertEqual(pt1, tp.templateList[pt1Name]!)
        XCTAssertEqual(pt2, tp.templateList[pt2Name]!)

        // Add projects 

        tp.addProject(p1)
        tp.addProject(p2)

        XCTAssertEqual(tp.templateList.count, 2, "\(tp.templateList.count)")
        XCTAssertEqual(tp.projectList.count, 2, "\(tp.projectList.count)")

        XCTAssertEqual(p1, tp.projectList[p1Name]!)
        XCTAssertEqual(p2, tp.projectList[p2Name]!)

        // Remove existing project

        tp.removeProject(p1)

        XCTAssertEqual(tp.templateList.count, 2, "\(tp.templateList.count)")
        XCTAssertEqual(tp.projectList.count, 1, "\(tp.projectList.count)")

        XCTAssert(tp.projectList[p1Name] == nil)
        XCTAssertEqual(p2, tp.projectList[p2Name]!)

        // Remove nonexisting project

        tp.removeProject(p1)

        XCTAssertEqual(tp.templateList.count, 2, "\(tp.templateList.count)")
        XCTAssertEqual(tp.projectList.count, 1, "\(tp.projectList.count)")

        XCTAssert(tp.projectList[p1Name] == nil)
        XCTAssertEqual(p2, tp.projectList[p2Name]!)

        // Remove existing template

        tp.removeTemplate(pt2)

        XCTAssertEqual(tp.templateList.count, 1, "\(tp.templateList.count)")
        XCTAssertEqual(tp.projectList.count, 1, "\(tp.projectList.count)")

        XCTAssertEqual(pt1, tp.templateList[pt1Name]!)
        XCTAssert(tp.templateList[pt2Name] == nil)

        // Empty TimePolice
        tp.removeProject(p2)
        tp.removeTemplate(pt1)

        XCTAssertEqual(tp.templateList.count, 0, "\(tp.templateList.count)")
        XCTAssertEqual(tp.projectList.count, 0, "\(tp.projectList.count)")
    }

    func testProjectTemplate() {
        // No tests, just a "struct"
        XCTAssert(true)
    }

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
        s1.taskSignOut()
        XCTAssert(s1.currentWork == nil)
        XCTAssert(s1.workDone.count==1)
        XCTAssertEqual(s1.workDone[0].task, t1)
        s1.taskSignIn(t2)
        XCTAssertEqual(s1.currentWork!.task, t2)
        s1.taskSignOut()
        XCTAssert(s1.currentWork == nil)
        XCTAssert(s1.workDone.count==2)
        XCTAssertEqual(s1.workDone[0].task, t1)
        XCTAssertEqual(s1.workDone[1].task, t2)
    }

    func testWork() {
        // No tests, just a "struct"
        XCTAssert(true)
    }
 
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

    func testLayout() {
        let gl1 = GridLayout(rows: 4, columns: 2)
        XCTAssertEqual(gl1.numberOfSelectionAreas(), 8)

        let vr1 = CGRect(x:0, y:0, width:200, height:320)
        let v1 = BackgroundView(frame:vr1)
        let view1 = gl1.getView(v1, selectionArea: 0)
        XCTAssertEqual(view1.frame, CGRect(x:0, y:0, width:100, height:80))
        
        let view2 = gl1.getView(v1, selectionArea: 1)
        XCTAssertEqual(view2.frame, CGRect(x:100, y:0, width:100, height:80))
        
        let view3 = gl1.getView(v1, selectionArea: 2)
        XCTAssertEqual(view3.frame, CGRect(x:0, y:80, width:100, height:80))

        let view4 = gl1.getView(v1, selectionArea: 2)
        XCTAssert(view3 === view4)
    }

    func testTheme() {
        XCTAssert(true)
        let bt1 = BasicTheme()
    }

    class TaskSelectionHelper : TaskPickerTaskSelectionDelegate {
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
            func taskSignOut() {
                taskSignOutList.append(taskSignInList)
            }
    }

    func testTaskPicker1() {
        let view1 = BackgroundView(frame: CGRect(x: 0, y:0, width:200, height:320))
        let layout = GridLayout(rows: 2, columns: 1)
        let theme = BasicTheme()
        let t1 = Task(name:"t1")
        let t2 = Task(name:"t2")
        let t3 = Task(name:"t3")
        let tl1 = [t1, t2, t3]
        let s1Name = "Session 1"
        let s1 = Session(name: s1Name, taskList: tl1)
        let tsa = TaskSelectAny()
        let tp1 = TaskPicker(workspace: view1, layout: layout, theme: theme, taskList: tl1, taskSelectionStrategy: tsa)
        tp1.setup()
        let tsh = TaskSelectionHelper()
        tp1.taskSelectionDelegate = tsh

        for i in 0..<tp1.layout.numberOfSelectionAreas() {
            XCTAssert(tp1.taskIsSelectable(i), "task \(i)")
            let view2 = tp1.layout.getView(tp1.workspace, selectionArea:i)
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
                XCTAssert(false, "No gesture recognizers")
            }
        }

    }


    func testTaskPicker2() {
        let view1 = BackgroundView(frame: CGRect(x: 0, y:0, width:200, height:320))
        let layout = GridLayout(rows: 2, columns: 1)
        let theme = BasicTheme()
        let t1 = Task(name:"t1")
        let t2 = Task(name:"t2")
        let t3 = Task(name:"t3")
        let tl1 = [t1, t2, t3]
        let s1Name = "Session 1"
        let s1 = Session(name: s1Name, taskList: tl1)
        let tsa = TaskSelectAny()
        let tp1 = TaskPicker(workspace: view1, layout: layout, theme: theme, taskList: tl1, taskSelectionStrategy: tsa)
        tp1.setup()
        let tsh = TaskSelectionHelper()
        tp1.taskSelectionDelegate = tsh

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

    func testTaskPicker3() {
        let view1 = BackgroundView(frame: CGRect(x: 0, y:0, width:200, height:320))
        let layout = GridLayout(rows: 2, columns: 1)
        let theme = BasicTheme()
        let t1 = Task(name:"t1")
        let t2 = Task(name:"t2")
        let t3 = Task(name:"t3")
        let tl1 = [t1, t2, t3]
        let s1Name = "Session 1"
        let s1 = Session(name: s1Name, taskList: tl1)
        let tsa = TaskSelectAny()
        let tp1 = TaskPicker(workspace: view1, layout: layout, theme: theme, taskList: tl1, taskSelectionStrategy: tsa)
        tp1.setup()
        let tsh = TaskSelectionHelper()
        tp1.taskSelectionDelegate = tsh

        XCTAssertEqual(tsh.taskSignInList, [])
        XCTAssertEqual(tsh.taskSignOutList, [[]])

        // Simulate "tap" on first item
        let view2 = tp1.layout.getView(tp1.workspace, selectionArea:0)
        if let recognizers = view2.gestureRecognizers {
            if let recognizer = recognizers[0] as? UITapGestureRecognizer {
                tp1.handleTap(recognizer)
            }
        }
        XCTAssertEqual(tsh.taskSignInList, [t1])
        XCTAssertEqual(1, tsh.taskSignOutList.count)
        XCTAssertEqual(tsh.taskSignOutList, [[]])

        // Simulate "tap" on second item
        let view3 = tp1.layout.getView(tp1.workspace, selectionArea:1)
        if let recognizers = view3.gestureRecognizers {
            if let recognizer = recognizers[0] as? UITapGestureRecognizer {
                tp1.handleTap(recognizer)
            }
        }
        XCTAssertEqual(tsh.taskSignInList, [t1, t2],
            "taskSignInList=\(tsh.taskSignInList[1].name)")
        XCTAssertEqual(2, tsh.taskSignOutList.count)
        var signoutlist = tsh.taskSignOutList[1]
        XCTAssertEqual(signoutlist, [t1], "taskSignOutList=\(signoutlist[0].name)")

    }

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
        let v = ViewController()
        
        // assert that the ViewController.view is not nil
        XCTAssertNotNil(v.view, "View Did Not load")
    }
}
