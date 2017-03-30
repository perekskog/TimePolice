//
//  SessionManagerPageViewController.swift
//  TimePolice
//
//  Created by Per Ekskog on 2015-09-13.
//  Copyright (c) 2015 Per Ekskog. All rights reserved.
//

/*

TODO

- If it doesn't work with setting self.edgesForExtendedLayout here, 
this class can be removed, and some other things can be simplified (in other classes).

*/

import UIKit

class TaskEntryCreatorManagerPageViewController: UIPageViewController {

    init() {
        super.init(transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = UIRectEdge()        
    }

}
